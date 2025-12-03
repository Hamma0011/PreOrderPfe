import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/banner/banner_repository.dart';
import '../../../data/repositories/product/produit_repository.dart';
import '../../../utils/popups/loaders.dart';
import '../../profil/controllers/liste_etablissement_controller.dart';
import '../models/banner_model.dart';
import '../models/etablissement_model.dart';
import '../models/produit_model.dart';
import '../../profil/controllers/user_controller.dart';

class BannerController extends GetxController {
  // Repository
  final _bannerRepository = Get.find<BannerRepository>();
  final produitRepository = Get.find<ProduitRepository>();

  final _userController = Get.find<UserController>();
  final etablissementController = Get.find<ListeEtablissementController>();
  final _db = Supabase.instance.client;

  // Realtime channel
  RealtimeChannel? _bannersChannel;

  // Timer pour vérifier les bannières expirées
  Timer? _expirationCheckTimer;

  // Observable variables
  final RxList<BannerModel> allBanners = <BannerModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedTabIndex = 0.obs; // 0: en_attente, 1: publiee, 2: refusee

  // Form variables
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final Rx<XFile?> pickedImage = Rx<XFile?>(null);
  final RxString imageUrl = ''.obs;
  final RxString selectedStatus =
      'en_attente'.obs; // 'en_attente', 'publiee', 'refusee'
  final RxString selectedLinkType = ''.obs; // 'product', 'establishment'
  final RxString selectedLinkId = ''.obs;

  // Dropdown options
  final RxList<ProduitModel> products = <ProduitModel>[].obs;
  final RxList<Etablissement> establishments = <Etablissement>[].obs;

  // Selected banner for editing
  final Rx<BannerModel?> selectedBanner = Rx<BannerModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchAllBanners();
    _subscribeToRealtimeBanners();
    _startExpirationCheckTimer();
  }

  @override
  void onClose() {
    _unsubscribeFromRealtimeBanners();
    _expirationCheckTimer?.cancel();
    super.onClose();
  }

  bool canApprove(BannerModel banner) {
    return isAdmin &&
        banner.status == 'publiee' &&
        banner.pendingChanges != null;
  }

  bool canEdit(BannerModel banner) {
    return isGerant;
  }

  Future<void> loadInitialData(bool isAdminView, BannerModel banner) async {
    await loadProducts();
    await loadEstablishments(isAdminView, banner);
    loadBannerForEditing(banner);
  }

  Future<void> loadProducts() async {
    try {
      if (_userController.userRole == 'Gérant') {
        final gerantEtablissement =
            await etablissementController.getEtablissementUtilisateurConnecte();
        if (gerantEtablissement != null && (gerantEtablissement.id?.isNotEmpty ?? false)) {
          final list = await produitRepository
              .getProductsByEtablissement(gerantEtablissement.id!);
          products.assignAll(list);
        } else {
          products.clear();
        }
      } else {
        final list = await produitRepository.getAllProducts();
        products.assignAll(list);
      }
    } catch (e) {
      debugPrint('Erreur chargement produits: $e');
    }
  }

  Future<void> loadEstablishments(bool isAdminView, BannerModel banner) async {
    try {
      // Si gérant, charger uniquement son établissement
      if (_userController.userRole == 'Gérant') {
        final gerantEtablissement =
            await etablissementController.getEtablissementUtilisateurConnecte();
        if (gerantEtablissement != null) {
          establishments.assignAll([gerantEtablissement]);
          // Si le type de lien est "establishment" et qu'aucun lien n'est sélectionné, utiliser l'établissement du gérant
          if (banner.linkType == 'establishment' &&
              (banner.link == null || banner.link!.isEmpty)) {
            selectedLinkId.value = gerantEtablissement.id ?? '';
          }
        }
      } else {
        // Pour admin, charger tous les établissements
        final list = await etablissementController.getTousEtablissements();
        establishments.assignAll(list);
      }
    } catch (e) {
      debugPrint('Erreur chargement établissements: $e');
    }
  }

  /// Fetch all banners
  Future<void> fetchAllBanners() async {
    try {
      isLoading.value = true;
      if (isGerant) {
        final etab = await etablissementController.getEtablissementUtilisateurConnecte();
        if (etab != null && (etab.id?.isNotEmpty ?? false)) {
          final bannersEstab = await _bannerRepository.getBannersByEstablishment(etab.id!);
          final produits = await produitRepository.getProductsByEtablissement(etab.id!);
          final productIds = produits.map((p) => p.id).where((id) => id.isNotEmpty).toList();
          final bannersProducts = await _bannerRepository.getBannersByProductIds(productIds);
          final combined = [...bannersEstab, ...bannersProducts];
          combined.sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)));
          allBanners.assignAll(combined);
        } else {
          allBanners.clear();
        }
      } else {
        final banners = await _bannerRepository.getAllBanners();
        allBanners.assignAll(banners);
      }
    } catch (e) {
      TLoaders.errorSnackBar(
          message: 'Erreur lors du chargement des bannières: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Get published banners from cache (allBanners) - Ne recharge pas depuis la DB
  List<BannerModel> getPublishedBanners() {
    return getBannersByStatus('publiee');
  }

  /// Load published banners from DB (only if needed)
  Future<void> loadPublishedBannersIfNeeded() async {
    // Si allBanners est vide, charger toutes les bannières
    if (allBanners.isEmpty && !isLoading.value) {
      await fetchAllBanners();
    }
  }

  /// Get banners by status
  List<BannerModel> getBannersByStatus(String status) {
    return allBanners.where((banner) => banner.status == status).toList();
  }

  /// Get filtered banners based on selected tab
  List<BannerModel> getFilteredBannersByTab() {
    final statuses = ['en_attente', 'publiee', 'refusee'];
    if (selectedTabIndex.value >= 0 &&
        selectedTabIndex.value < statuses.length) {
      final status = statuses[selectedTabIndex.value];
      return getFilteredBanners()
          .where((banner) => banner.status == status)
          .toList();
    }
    return [];
  }

  /// Check if user is Admin
  bool get isAdmin => _userController.userRole == 'Admin';

  /// Check if user is Gerant
  bool get isGerant => _userController.userRole == 'Gérant';

  /// Check if user can add/edit/delete banners
  bool get canManageBanners => isGerant;

  /// Check if user can change banner status
  bool get canChangeStatus => isAdmin;

  /// Pick image from gallery or camera
  Future<void> pickImage({bool isMobile = false}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: isMobile ? 85 : 90,
        maxWidth: isMobile ? 1200 : 1920,
        maxHeight: isMobile ? 800 : 1080,
      );

      if (image != null) {
        pickedImage.value = image;
        imageUrl.value = ''; // Reset URL when new image is picked
      }
    } catch (e) {
      TLoaders.errorSnackBar(
          message: 'Erreur lors de la sélection de l\'image: $e');
    }
  }

  /// Add banner
  Future<void> addBanner() async {
    try {
      // Validation
      if (!formKey.currentState!.validate()) {
        return;
      }

      if (pickedImage.value == null && imageUrl.value.isEmpty) {
        TLoaders.warningSnackBar(
          title: 'Image manquante',
          message: 'Veuillez sélectionner une image pour la bannière',
        );
        return;
      }

      isLoading.value = true;

      // Upload image if a new one was picked
      String finalImageUrl = imageUrl.value;
      if (pickedImage.value != null) {
        final screenWidth = Get.width;
        final isMobileSize = screenWidth < 768;
        finalImageUrl = await _bannerRepository.uploadBannerImage(
          pickedImage.value!,
          isMobile: isMobileSize,
        );
      }

      // Create banner (Gérant only, status always 'en_attente' for new banners)
      if (!canManageBanners) {
        TLoaders.errorSnackBar(
          title: 'Permission refusée',
          message: 'Seuls les gérants peuvent ajouter des bannières',
        );
        return;
      }

      if (isGerant) {
        final gerantEtablissement = await etablissementController.getEtablissementUtilisateurConnecte();
        if (gerantEtablissement != null && (gerantEtablissement.id?.isNotEmpty ?? false)) {
          if (selectedLinkType.value == 'establishment') {
            if (selectedLinkId.value.isEmpty || selectedLinkId.value != gerantEtablissement.id) {
              selectedLinkId.value = gerantEtablissement.id!;
            }
          } else if (selectedLinkType.value == 'product') {
            if (selectedLinkId.value.isEmpty) {
              TLoaders.warningSnackBar(title: 'Lien produit manquant', message: 'Veuillez sélectionner un produit');
              isLoading.value = false;
              return;
            }
            try {
              final produit = await produitRepository.getProductById(selectedLinkId.value);
              if (produit == null || produit.etablissementId != gerantEtablissement.id) {
                TLoaders.errorSnackBar(title: 'Produit invalide', message: 'Ce produit n\'appartient pas à votre établissement');
                isLoading.value = false;
                return;
              }
            } catch (e) {
              TLoaders.errorSnackBar(title: 'Erreur', message: e.toString());
              isLoading.value = false;
              return;
            }
          }
        }
      }

      final banner = BannerModel(
        id: '',
        name: nameController.text.trim(),
        imageUrl: finalImageUrl,
        status: 'en_attente',
        link: selectedLinkId.value.isNotEmpty ? selectedLinkId.value : null,
        linkType: selectedLinkType.value.isNotEmpty ? selectedLinkType.value : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final newBanner = await _bannerRepository.addBanner(banner);
      await fetchAllBanners();

      // Envoyer une notification aux admins
      await _notifyAdminsNewBanner(newBanner);

      clearForm();
      Get.back(); // Fermer l'écran
      TLoaders.successSnackBar(
        title: 'Succès',
        message: 'Bannière ajoutée avec succès',
      );
    } catch (e) {
      TLoaders.errorSnackBar(
          message: 'Erreur lors de l\'ajout de la bannière: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update banner
  Future<void> updateBanner(String bannerId) async {
    try {
      // Check permissions
      if (!canManageBanners) {
        TLoaders.errorSnackBar(
          title: 'Permission refusée',
          message: 'Seuls les gérants peuvent modifier des bannières',
        );
        return;
      }

      // Validation
      if (!formKey.currentState!.validate()) {
        return;
      }

      isLoading.value = true;

      // Get existing banner to check status
      final existingBanner = allBanners.firstWhere((b) => b.id == bannerId);

      // Upload new image if one was picked
      String finalImageUrl = imageUrl.value;
      if (pickedImage.value != null) {
        final screenWidth = Get.width;
        final isMobileSize = screenWidth < 768;
        finalImageUrl = await _bannerRepository.uploadBannerImage(
          pickedImage.value!,
          isMobile: isMobileSize,
        );
      }

      // Préparer les données de modification
      final updatedData = {
        'name': nameController.text.trim(),
        'image_url': finalImageUrl,
        'link': selectedLinkId.value.isNotEmpty ? selectedLinkId.value : null,
        'link_type':
            selectedLinkType.value.isNotEmpty ? selectedLinkType.value : null,
      };

      // Gérer selon le statut actuel
      if (existingBanner.status == 'en_attente') {
        // Statut "en_attente" : modification directe
        final banner = BannerModel(
          id: bannerId,
          name: updatedData['name'].toString(),
          imageUrl: updatedData['image_url'].toString(),
          status: 'en_attente', // Reste en attente
          link: updatedData['link']?.toString(),
          linkType: updatedData['link_type']?.toString(),
          createdAt: existingBanner.createdAt,
          updatedAt: DateTime.now(),
        );

        await _bannerRepository.updateBanner(banner);
        await fetchAllBanners();

        clearForm();
        Get.back();
        TLoaders.successSnackBar(
          title: 'Succès',
          message: 'Bannière mise à jour avec succès',
        );
      } else if (existingBanner.status == 'publiee') {
        // Statut "publiee" : modification directe et retour en attente
        final banner = BannerModel(
          id: bannerId,
          name: updatedData['name'].toString(),
          imageUrl: updatedData['image_url'].toString(),
          status: 'en_attente',
          link: updatedData['link']?.toString(),
          linkType: updatedData['link_type']?.toString(),
          createdAt: existingBanner.createdAt,
          updatedAt: DateTime.now(),
        );

        await _bannerRepository.updateBanner(banner);
        await fetchAllBanners();

        clearForm();
        Get.back();
        TLoaders.successSnackBar(
          title: 'Succès',
          message: 'Bannière modifiée et remise en attente de validation',
        );
      } else if (existingBanner.status == 'refusee') {
        // Statut "refusee" : modifier directement et remettre en attente
        final banner = BannerModel(
          id: bannerId,
          name: updatedData['name'].toString(),
          imageUrl: updatedData['image_url'].toString(),
          status: 'en_attente', // Revenir en attente
          link: updatedData['link']?.toString(),
          linkType: updatedData['link_type']?.toString(),
          createdAt: existingBanner.createdAt,
          updatedAt: DateTime.now(),
        );

        await _bannerRepository.updateBanner(banner);
        await fetchAllBanners();

        clearForm();
        Get.back();
        TLoaders.successSnackBar(
          title: 'Succès',
          message: 'Bannière modifiée et remise en attente de validation',
        );
      }
    } catch (e) {
      TLoaders.errorSnackBar(
          message: 'Erreur lors de la mise à jour de la bannière: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete banner
  Future<void> deleteBanner(String bannerId) async {
    try {
      // Check permissions
      if (!(isGerant || isAdmin)) {
        TLoaders.errorSnackBar(
          title: 'Permission refusée',
          message: 'Seuls les administrateurs et gérants peuvent supprimer des bannières',
        );
        return;
      }

      // Get banner to delete image
      final banner = allBanners.firstWhere((b) => b.id == bannerId);

      isLoading.value = true;

      // Delete image from storage
      if (banner.imageUrl.isNotEmpty) {
        await _bannerRepository.deleteBannerImage(banner.imageUrl);
      }

      // Delete banner
      await _bannerRepository.deleteBanner(bannerId);
      await fetchAllBanners();

      // Afficher le snackbar de succès
      TLoaders.successSnackBar(
        title: 'Succès',
        message: 'Bannière supprimée avec succès',
      );
    } catch (e) {
      TLoaders.errorSnackBar(
          message: 'Erreur lors de la suppression de la bannière: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Update banner status (Admin only)
  Future<void> updateBannerStatus(String bannerId, String newStatus) async {
    try {
      if (!canChangeStatus) {
        TLoaders.errorSnackBar(
          title: 'Permission refusée',
          message:
              'Seuls les administrateurs peuvent changer le statut des bannières',
        );
        return;
      }

      if (!['en_attente', 'publiee', 'refusee'].contains(newStatus)) {
        TLoaders.errorSnackBar(
          title: 'Erreur',
          message: 'Statut invalide',
        );
        return;
      }

      isLoading.value = true;
      await _bannerRepository.updateBannerStatus(bannerId, newStatus);
      // Ne pas recharger toutes les bannières, le Realtime s'en chargera
      // Cela évite les conflits et permet une mise à jour plus fluide
      // await fetchAllBanners();

      TLoaders.successSnackBar(
        title: 'Succès',
        message: 'Statut de la bannière mis à jour',
      );
    } catch (e) {
      TLoaders.errorSnackBar(
          message: 'Erreur lors de la mise à jour du statut: $e');
      // En cas d'erreur, recharger pour s'assurer que l'état est cohérent
      await fetchAllBanners();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load banner for editing
  void loadBannerForEditing(BannerModel banner) {
    selectedBanner.value = banner;
    nameController.text = banner.name;
    imageUrl.value = banner.imageUrl;
    pickedImage.value = null;
    selectedStatus.value = banner.status;
    selectedLinkType.value = banner.linkType ?? '';
    selectedLinkId.value = banner.link ?? '';
  }

  /// Clear form
  void clearForm() {
    nameController.clear();
    pickedImage.value = null;
    imageUrl.value = '';
    selectedStatus.value = 'en_attente';
    selectedLinkType.value = '';
    selectedLinkId.value = '';
    selectedBanner.value = null;
  }

  /// Update search query
  void updateSearch(String query) {
    searchQuery.value = query;
  }

  /// Get filtered banners
  List<BannerModel> getFilteredBanners() {
    if (searchQuery.value.isEmpty) {
      return allBanners.toList();
    }
    return allBanners
        .where((banner) =>
            banner.name.toLowerCase().contains(searchQuery.value.toLowerCase()))
        .toList();
  }

  /// Refresh banners
  Future<void> refreshBanners() async {
    await fetchAllBanners();
  }

  /// S'abonner aux changements en temps réel des bannières
  void _subscribeToRealtimeBanners() {
    try {
      _bannersChannel = _db.channel('banners_realtime');

      _bannersChannel!.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'banners',
        callback: (payload) {
          try {
            final eventType = payload.eventType;
            final newData = payload.newRecord;
            final oldData = payload.oldRecord;

            debugPrint('📢 Événement Realtime bannière: $eventType');

            if (eventType == PostgresChangeEvent.insert) {
              final banner = BannerModel.fromJson(newData);
              debugPrint(
                  '➕ Nouvelle bannière reçue: ${banner.id} - ${banner.name} - ${banner.status}');
              // Vérifier si la bannière n'existe pas déjà dans la liste
              final index = allBanners.indexWhere((b) => b.id == banner.id);
              if (index == -1) {
                allBanners.insert(0, banner);
                allBanners.refresh();
                debugPrint('✅ Bannière ajoutée à la liste');
              }
            } else if (eventType == PostgresChangeEvent.update) {
              final banner = BannerModel.fromJson(newData);
              debugPrint(
                  '🔄 Bannière mise à jour: ${banner.id} - ${banner.name} - Statut: ${banner.status}');
              final index = allBanners.indexWhere((b) => b.id == banner.id);
              if (index != -1) {
                // Remplacer complètement l'élément pour forcer la mise à jour
                allBanners.removeAt(index);
                allBanners.insert(index, banner);
                allBanners.refresh();
                debugPrint(
                    '✅ Bannière mise à jour dans la liste (index: $index)');
              } else {
                // Si la bannière n'existe pas, l'ajouter
                allBanners.insert(0, banner);
                allBanners.refresh();
                debugPrint(
                    '✅ Bannière ajoutée (n\'existait pas dans la liste)');
              }
            } else if (eventType == PostgresChangeEvent.delete) {
              final id = oldData['id']?.toString();
              if (id != null) {
                final hadBanner = allBanners.any((b) => b.id == id);
                allBanners.removeWhere((b) => b.id == id);
                if (hadBanner) {
                  allBanners.refresh();
                  debugPrint('✅ Bannière supprimée de la liste: $id');
                }
              }
            }
          } catch (e, stackTrace) {
            debugPrint(
                '❌ Erreur traitement changement bannière temps réel: $e');
            debugPrint('Stack trace: $stackTrace');
          }
        },
      );

      _bannersChannel!.subscribe(
        (status, [error]) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            debugPrint('✅ Abonnement temps réel activé pour les bannières');
          } else if (status == RealtimeSubscribeStatus.channelError) {
            debugPrint('❌ Erreur abonnement temps réel bannières: $error');
          } else {
            debugPrint('⚠️ Statut abonnement bannières: $status');
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur abonnement temps réel bannières: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Se désabonner des changements en temps réel
  void _unsubscribeFromRealtimeBanners() {
    if (_bannersChannel != null) {
      try {
        _db.removeChannel(_bannersChannel!);
        _bannersChannel = null;
        debugPrint('Désabonné de l\'écoute temps réel des bannières');
      } catch (e) {
        debugPrint('Erreur lors de la désinscription temps réel: $e');
      }
    }
  }

  /// Notifier les admins lorsqu'une nouvelle bannière est ajoutée
  Future<void> _notifyAdminsNewBanner(BannerModel banner) async {
    try {
      // Récupérer le nom du gérant
      final gerantName = _userController.user.value.fullName.isNotEmpty
          ? _userController.user.value.fullName
          : 'Un gérant';

      // Récupérer tous les admins
      final adminUsers =
          await _db.from('users').select('id').eq('role', 'Admin');

      if (adminUsers.isEmpty) {
        debugPrint('⚠️ Aucun admin trouvé pour notifier');
        return;
      }

      // Envoyer une notification à chaque admin
      for (final admin in adminUsers) {
        try {
          await _db.from('notifications').insert({
            'user_id': admin['id'],
            'title': 'Nouvelle bannière à valider',
            'message':
                '$gerantName a ajouté une nouvelle bannière "${banner.name}".',
            'read': false,
            'created_at': DateTime.now().toIso8601String(),
          });
          debugPrint('Notification créée pour admin ${admin['id']}');
        } catch (e) {
          debugPrint(
              'Erreur création notification pour admin ${admin['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur envoi notification aux admins: $e');
      // Ne pas faire échouer l'ajout de la bannière si la notification échoue
    }
  }

  /// Approuver les modifications en attente (Admin only)
  Future<void> approvePendingChanges(String bannerId) async {
    try {
      if (!canChangeStatus) {
        TLoaders.errorSnackBar(
          title: 'Permission refusée',
          message:
              'Seuls les administrateurs peuvent approuver les modifications',
        );
        return;
      }

      isLoading.value = true;
      await _bannerRepository.approvePendingChanges(bannerId);
      await fetchAllBanners();

      TLoaders.successSnackBar(
        title: 'Succès',
        message: 'Modifications approuvées et appliquées',
      );
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur lors de l\'approbation: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refuser les modifications en attente (Admin only)
  Future<void> rejectPendingChanges(String bannerId) async {
    try {
      if (!canChangeStatus) {
        TLoaders.errorSnackBar(
          title: 'Permission refusée',
          message:
              'Seuls les administrateurs peuvent refuser les modifications',
        );
        return;
      }

      isLoading.value = true;
      await _bannerRepository.rejectPendingChanges(bannerId);
      await fetchAllBanners();

      TLoaders.successSnackBar(
        title: 'Succès',
        message: 'Modifications refusées',
      );
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur lors du refus: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Vérifier et mettre à jour les bannières expirées
  Future<void> checkExpiredBanners() async {
    try {
      final count = await _bannerRepository.checkAndUpdateExpiredBanners();
      if (count > 0) {
        debugPrint(
            '✅ $count bannière(s) expirée(s) mise(s) à jour automatiquement');
        await fetchAllBanners();
      }
    } catch (e) {
      debugPrint(
          '⚠️ Erreur lors de la vérification des bannières expirées: $e');
    }
  }

  /// Démarrer le timer pour vérifier périodiquement les bannières expirées
  void _startExpirationCheckTimer() {
    // Vérifier immédiatement
    checkExpiredBanners();

    // Puis vérifier toutes les heures
    _expirationCheckTimer = Timer.periodic(
      const Duration(hours: 1),
      (_) => checkExpiredBanners(),
    );
  }

  /// Vérifier si une bannière a des modifications en attente
  bool hasPendingChanges(BannerModel banner) {
    return banner.pendingChanges != null && banner.pendingChanges!.isNotEmpty;
  }

  /// Notifier les admins lorsqu'une modification est en attente pour une bannière publiée
  Future<void> _notifyAdminsPendingChanges(
      String bannerId, String bannerName) async {
    try {
      // Récupérer le nom du gérant
      final gerantName = _userController.user.value.fullName.isNotEmpty
          ? _userController.user.value.fullName
          : 'Un gérant';

      // Récupérer tous les admins
      final adminUsers =
          await _db.from('users').select('id').eq('role', 'Admin');

      if (adminUsers.isEmpty) {
        debugPrint('⚠️ Aucun admin trouvé pour notifier');
        return;
      }

      // Envoyer une notification à chaque admin
      for (final admin in adminUsers) {
        try {
          await _db.from('notifications').insert({
            'user_id': admin['id'],
            'title': 'Modifications en attente',
            'message':
                '$gerantName a demandé des modifications pour la bannière "$bannerName".',
            'read': false,
            'created_at': DateTime.now().toIso8601String(),
          });
          debugPrint(
              'Notification de modification créée pour admin ${admin['id']}');
        } catch (e) {
          debugPrint(
              'Erreur création notification pour admin ${admin['id']}: $e');
        }
      }
    } catch (e) {
      debugPrint('⚠️ Erreur envoi notification aux admins: $e');
    }
  }
}
