import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/etablissement/etablissement_repository.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/popups/loaders.dart';
import 'user_controller.dart';
import '../../shop/models/etablissement_model.dart';
import '../../shop/models/produit_model.dart';
import '../../shop/models/statut_etablissement_model.dart';

class ListeEtablissementController extends GetxController {
  final EtablissementRepository repo;
  final UserController userController = Get.find<UserController>();
  final isLoading = false.obs;
  final etablissements = <Etablissement>[].obs;
  final SupabaseClient _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  final selectedFilter = 'Récents'.obs;

  ListeEtablissementController(this.repo);

  @override
  void onInit() {
    super.onInit();
    _subscribeToRealtimeEtablissements();
    _loadEtablissementsAccordingToRole();
  }

  Future<void> _loadEtablissementsAccordingToRole() async {
    try {
      final userRole = userController.userRole;
      final userId = userController.user.value.id;

      if (userRole == 'Admin') {
        await getTousEtablissements();
      } else if (userRole == 'Gérant' && userId.isNotEmpty) {
        await fetchEtablissementsByOwner(userId);
      }
      // Pour les autres rôles, on ne charge rien
    } catch (e) {
      debugPrint('Erreur chargement établissements selon rôle: $e');
    }
  }

  @override
  void onClose() {
    _unsubscribeFromRealtime();
    super.onClose();
  }

  void _subscribeToRealtimeEtablissements() {
    _channel = _supabase.channel('etablissements_changes');
    _channel!.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'etablissements',
      callback: (payload) {
        final type = payload.eventType;
        final newData = payload.newRecord;
        final oldData = payload.oldRecord;
        final etab = Etablissement.fromJson(
          type == PostgresChangeEvent.delete ? oldData : newData,
        );
        // Handle all statuses for admin/gerant management
        if (type == PostgresChangeEvent.insert) {
          etablissements.add(etab);
        }
        if (type == PostgresChangeEvent.update) {
          final index = etablissements.indexWhere((e) => e.id == etab.id);
          if (index != -1) etablissements[index] = etab;
        }
        if (type == PostgresChangeEvent.delete) {
          etablissements.removeWhere((e) => e.id == etab.id);
        }
        etablissements.refresh();
      },
    );
    _channel!.subscribe();
  }

  /// pourquoi ne pas utiliser cette méthode?
  // void subscribeToRealtimeEtablissements() {
  //   _channel = _supabase.channel('etablissements_changes');
  //   _channel!.onPostgresChanges(
  //     event: PostgresChangeEvent.all,
  //     schema: 'public',
  //     table: 'etablissements',
  //     callback: (payload) {
  //       final type = payload.eventType;
  //       final newData = payload.newRecord;
  //       final oldData = payload.oldRecord;
  //       final etab = Etablissement.fromJson(
  //         type == PostgresChangeEvent.delete ? oldData : newData,
  //       );
  //       if (etab.statut != StatutEtablissement.approuve) return;
  //       if (type == PostgresChangeEvent.insert) {
  //         etablissements.add(etab);
  //       }
  //       if (type == PostgresChangeEvent.update) {
  //         final index = etablissements.indexWhere((e) => e.id == etab.id);
  //         if (index != -1) etablissements[index] = etab;
  //       }
  //       if (type == PostgresChangeEvent.delete) {
  //         etablissements.removeWhere((e) => e.id == etab.id);
  //       }
  //       etablissements.refresh();
  //     },
  //   );
  //   _channel!.subscribe();
  // }

  void _unsubscribeFromRealtime() {
    if (_channel != null) {
      _supabase.removeChannel(_channel!);
      _channel = null;
    }
  }

  RxList<Etablissement> get filteredEtablissements {
    final List<Etablissement> all = etablissements;
    late List<Etablissement> filtered;

    switch (selectedFilter.value) {
      case 'Approuvés':
        filtered =
            all.where((e) => e.statut == StatutEtablissement.approuve).toList();
        break;
      case 'Rejetés':
        filtered =
            all.where((e) => e.statut == StatutEtablissement.rejete).toList();
        break;
      case 'En attente':
        filtered = all
            .where((e) => e.statut == StatutEtablissement.en_attente)
            .toList();
        break;
      default:
        filtered = List.from(all)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered.obs;
  }

  Future<String?> uploadEtablissementImage(XFile file) async {
    try {
      return repo.uploadEtablissementImage(file);
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur upload image: $e');
      return null;
    }
  }

  Future<String?> createEtablissement(Etablissement e) async {
    try {
      if (!_hasPermissionForAction('création')) {
        return null;
      }
      if (_isUserGerant()) {
        final canCreate =
            await repo.canUserCreateEtablissement(userController.user.value.id);
        if (!canCreate) {
          TLoaders.errorSnackBar(
              title: 'Limitation',
              message: 'Vous ne pouvez créer qu\'un seul établissement');
          return null;
        }
      }
      isLoading.value = true;

      final currentUser = userController.user.value;

      // Create in repo
      final id = await repo.createEtablissement(e);
      Get.back(result: true);

      if (id != null && id.isNotEmpty) {
        await _refreshEtablissementsAfterAction();
        TLoaders.successSnackBar(message: 'Établissement créé avec succès');

        try {
          final gerantName = currentUser.fullName.isNotEmpty
              ? currentUser.fullName
              : 'Un gérant';
          final etabName = e.name;

          // Fetch all admins
          final adminUsers =
              await _supabase.from('users').select('id').eq('role', 'Admin');

          if (adminUsers.isEmpty) {
            debugPrint('⚠️ Aucun admin trouvé pour notifier');
          } else {
            for (final admin in adminUsers) {
              final response = await _supabase.from('notifications').insert({
                'user_id': admin['id'],
                'title': 'Nouvel établissement à valider',
                'message':
                    '$gerantName a ajouté un nouvel établissement "$etabName".',
                'etablissement_id': id,
              }).select();
              debugPrint(
                  'Notification créée pour admin ${admin['id']}: $response');
            }
          }
        } catch (notifyErr) {
          debugPrint('⚠️ Erreur envoi notification: $notifyErr');
        }
      } else {
        TLoaders.errorSnackBar(message: 'Erreur lors de la création');
      }

      return id;
    } catch (err, stack) {
      _logError('création', err, stack);
      TLoaders.errorSnackBar(message: 'Erreur création: $err');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateEtablissement(
      String? id, Map<String, dynamic> data) async {
    try {
      if (!_hasPermissionForAction('mise à jour')) {
        return false;
      }

      if (id == null || id.isEmpty) {
        TLoaders.errorSnackBar(message: 'ID établissement manquant');
        return false;
      }

      // Vérifier que le gérant ne peut modifier que ses propres établissements
      if (_isUserGerant()) {
        final etablissement =
            etablissements.firstWhereOrNull((e) => e.id == id);
        if (etablissement == null) {
          TLoaders.errorSnackBar(message: 'Établissement non trouvé');
          return false;
        }
        final userId = userController.user.value.id;
        if (etablissement.idOwner != userId) {
          TLoaders.errorSnackBar(
            message: 'Vous ne pouvez modifier que vos propres établissements',
          );
          return false;
        }
      }

      isLoading.value = true;

      // S'assurer que le statut est converti correctement
      if (data.containsKey('statut') && data['statut'] is StatutEtablissement) {
        data['statut'] = (data['statut'] as StatutEtablissement).value;
      }

      Get.back(result: true);
      final success = await repo.updateEtablissement(id, data);
      if (success) {
        final index = etablissements.indexWhere((e) => e.id == id);
        if (index != -1) {
          final oldEts = etablissements[index];
          etablissements[index] = oldEts.copyWith(
              name: data['name'] ?? oldEts.name,
              address: data['address'] ?? oldEts.address,
              imageUrl: data['image_url'] ?? oldEts.imageUrl,
              statut: data['statut'] != null
                  ? StatutEtablissementExt.fromString(data['statut'])
                  : oldEts.statut);
          etablissements.refresh();
        }
        await _refreshEtablissementsAfterAction();
        TLoaders.successSnackBar(
            message: 'Établissement mis à jour avec succès');
        final etablissement =
            etablissements.firstWhereOrNull((e) => e.id == id);
        final gerantId = etablissement?.idOwner;
        final newStatut = data['statut'];
        final etabName = data['name'] ?? etablissement?.name ?? 'Établissement';

        if (gerantId != null && gerantId.isNotEmpty) {
          await _supabase.from('notifications').insert({
            'user_id': gerantId,
            'title': 'Statut mis à jour',
            'message':
                'Votre établissement "$etabName" est maintenant $newStatut.',
            'etablissement_id': id,
          });
        } else {
          debugPrint(
              '⚠️ Impossible d\'envoyer notification: id_owner introuvable');
        }
      } else {
        TLoaders.errorSnackBar(message: 'Échec de la mise à jour');
      }

      return success;
    } catch (e, stack) {
      _logError('mise à jour', e, stack);
      TLoaders.errorSnackBar(message: 'Erreur mise à jour: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Méthode pour changer le statut
  Future<bool> changeStatutEtablissement(
      String id, StatutEtablissement newStatut) async {
    try {
      // Seuls les admins peuvent changer le statut
      if (!_isUserAdmin()) {
        _logError('changement statut', 'Permission refusée : Admin requis');
        return false;
      }

      isLoading.value = true;

      // Utiliser la valeur correcte pour l'enum
      final success = await repo.changeStatut(id, newStatut);

      if (success) {
        final index = etablissements.indexWhere((e) => e.id == id);
        if (index != -1) {
          etablissements[index] =
              etablissements[index].copyWith(statut: newStatut);
          etablissements.refresh();
        }
        _refreshEtablissementsAfterAction();
        TLoaders.successSnackBar(message: 'Statut mis à jour avec succès');
      } else {
        TLoaders.errorSnackBar(message: 'Échec de la mise à jour du statut');
      }

      return success;
    } catch (e, stack) {
      _logError('changement statut', e, stack);
      TLoaders.errorSnackBar(message: 'Erreur changement statut: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Rafraîchissement après action
  Future<void> _refreshEtablissementsAfterAction() async {
    try {
      final userRole = userController.userRole;
      final userId = userController.user.value.id;

      if (userRole == 'Admin') {
        await getTousEtablissements();
      } else if (userRole == 'Gérant' && userId.isNotEmpty) {
        await fetchEtablissementsByOwner(userId);
      }
      etablissements.refresh();
    } catch (e) {
      debugPrint('Erreur rafraîchissement: $e');
    }
  }

  // Vérification de permission unifiée
  bool _hasPermissionForAction(String action) {
    final userRole = userController.userRole;

    if (userRole.isEmpty) {
      TLoaders.errorSnackBar(message: 'Utilisateur non connecté');
      return false;
    }

    if (action == 'création' && userRole != 'Gérant') {
      TLoaders.errorSnackBar(
          message: 'Seuls les Gérants peuvent créer des établissements');
      return false;
    }

    if (action == 'mise à jour' &&
        userRole != 'Gérant' &&
        userRole != 'Admin') {
      TLoaders.errorSnackBar(message: 'Permission refusée pour la mise à jour');
      return false;
    }

    return true;
  }

  Future<List<Etablissement>> getTousEtablissements() async {
    debugPrint(
        "🟢 [EtablissementController] Chargement de tous les établissements");
    try {
      isLoading.value = true;
      final data = await repo.getAllEtablissements();
      etablissements.assignAll(data);
      return data;
    } catch (e) {
      debugPrint('Erreur getTousEtablissements: $e');
      TLoaders.errorSnackBar(message: 'Erreur chargement établissements: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  bool isRecentEtablissement(Etablissement e) {
    final now = DateTime.now();
    final diff = now.difference(e.createdAt); // le "!" car on a déjà vérifié
    return diff.inDays < 3; // 3 jours = récent
  }

  // Récupérer les établissements d'un propriétaire
  Future<List<Etablissement>?> fetchEtablissementsByOwner(
      String ownerId) async {
    try {
      isLoading.value = true;
      final data = await repo.getEtablissementsByOwner(ownerId);

      // S'assurer que chaque établissement a un owner
      final dataWithOwner = data.map((etab) {
        if (etab.owner == null) {
          // Si l'owner est manquant, utiliser l'utilisateur courant
          return etab.copyWith(owner: userController.user.value);
        }
        return etab;
      }).toList();

      etablissements.assignAll(dataWithOwner);
      return dataWithOwner;
    } catch (e) {
      debugPrint('Erreur fetchEtablissementsByOwner: $e');
      TLoaders.errorSnackBar(message: 'Erreur chargement établissements: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Suppression améliorée
  Future<bool> deleteEtablissement(String id) async {
    try {
      if (!_hasPermissionForAction('suppression')) {
        return false;
      }

      // Confirmation avant suppression
      final shouldDelete = await _showDeleteConfirmation();
      if (!shouldDelete) return false;

      isLoading.value = true;

      final success = await repo.deleteEtablissement(id);

      if (success) {
        // Supprimer localement ET rafraîchir
        etablissements.removeWhere((e) => e.id == id);
        await _refreshEtablissementsAfterAction();
        TLoaders.successSnackBar(message: 'Établissement supprimé avec succès');
      } else {
        TLoaders.errorSnackBar(message: 'Échec de la suppression');
      }

      return success;
    } catch (e, stack) {
      _logError('suppression', e, stack);
      TLoaders.errorSnackBar(message: 'Erreur suppression: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  //Confirmatio n de suppression
  Future<bool> _showDeleteConfirmation() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
            'Êtes-vous sûr de vouloir supprimer cet établissement avec tout ses produits ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  bool _isUserGerant() {
    final userRole = userController.userRole;
    return userRole == 'Gérant';
  }

  bool _isUserAdmin() {
    final userRole = userController.userRole;
    return userRole == 'Admin';
  }

  // // Récupérer l'établissement de l'utilisateur connecté
  Future<Etablissement?> getEtablissementUtilisateurConnecte() async {
    try {
      final user = userController.user.value;

      if (user.id.isEmpty) {
        _logError('récupération établissement', 'Utilisateur non connecté');
        return null;
      }

      final etablissementsUtilisateur =
          await fetchEtablissementsByOwner(user.id);
      return etablissementsUtilisateur?.isNotEmpty == true
          ? etablissementsUtilisateur!.first
          : null;
    } catch (e, stack) {
      _logError('récupération établissement utilisateur', e, stack);
      return null;
    }
  }

  void _logError(String action, Object error, [StackTrace? stack]) {
    debugPrint('Erreur $action: $error');
    if (stack != null) {
      debugPrint('Stack: $stack');
    }
  }

  Future<List<ProduitModel>> getProduitsEtablissement({
    required String etablissementId,
  }) async {
    try {
      isLoading.value = true;
      final produits = await repo.getProduitsEtablissement(etablissementId);
      return produits;
    } catch (e) {
      TLoaders.errorSnackBar(
          title: 'Erreur', message: 'Impossible de charger les produits: $e');
      return [];
    } finally {
      isLoading.value = false;
    }
  }
}
