import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/repositories/horaire/horaire_repository.dart';
import '../../../utils/constants/enums.dart';
import '../../../utils/popups/loaders.dart';
import '../../shop/controllers/product/horaire_controller.dart';
import '../../shop/models/etablissement_model.dart';
import '../screens/gestion_etablissement/edit_etablissement/widgets/gestion_horaires_screen.dart';
import 'liste_etablissement_controller.dart';
import 'user_controller.dart';

class EditEtablissementController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final Etablissement etablissement;
  final ListeEtablissementController etablissementController =
      Get.find<ListeEtablissementController>();
  final UserController userController = Get.find<UserController>();
  late final HoraireController horaireController;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final latitudeController = TextEditingController();
  final longitudeController = TextEditingController();

  final _isLoading = false.obs;
  final horairesLoaded = false.obs;
  final selectedStatut = StatutEtablissement.en_attente.obs;
  final selectedImage = Rx<XFile?>(null);
  final currentImageUrl = Rx<String?>(null);

  late AnimationController animationController;
  late Animation<double> fadeAnimation;

  bool get isLoading => _isLoading.value;

  EditEtablissementController({required this.etablissement});

  @override
  void onInit() {
    super.onInit();
    _initializeHoraireController();
    _initializeForm();
    _loadHoraires();
    _initializeAnimation();
  }

  @override
  void onClose() {
    animationController.dispose();
    nameController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.onClose();
  }

  void _initializeAnimation() {
    animationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    );
    animationController.forward();
  }

  void _initializeHoraireController() {
    try {
      horaireController = Get.find<HoraireController>();
    } catch (e) {
      horaireController = Get.put(HoraireController(HoraireRepository()));
    }
  }

  void _initializeForm() {
    nameController.text = etablissement.name;
    addressController.text = etablissement.address;
    latitudeController.text = etablissement.latitude?.toString() ?? '';
    longitudeController.text = etablissement.longitude?.toString() ?? '';
    selectedStatut.value = etablissement.statut;
    currentImageUrl.value = etablissement.imageUrl;
  }

  Future<void> pickMainImage() async {
    try {
      final picked = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        selectedImage.value = picked;
      }
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur sélection image: $e');
    }
  }

  Future<void> _loadHoraires() async {
    try {
      horairesLoaded.value = false;
      await horaireController.fetchHoraires(etablissement.id!);
      horairesLoaded.value = true;
    } catch (e) {
      horairesLoaded.value = true;
    }
  }

  void gererHoraires() async {
    try {
      final result = await Get.to(() => GestionHorairesEtablissement(
            etablissementId: etablissement.id!,
            nomEtablissement: etablissement.name,
            isCreation: false,
          ));

      if (result == true) {
        await _loadHoraires();
        TLoaders.successSnackBar(message: 'Horaires mis à jour avec succès');
      }
    } catch (e) {
      TLoaders.errorSnackBar(
          message: 'Impossible de modifier les horaires: $e');
    }
  }

  void updateEtablissement() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _isLoading.value = true;

    try {
      String? imageUrl = currentImageUrl.value;
      if (selectedImage.value != null) {
        imageUrl = await etablissementController
            .uploadEtablissementImage(selectedImage.value!);
        if (imageUrl == null) {
          TLoaders.errorSnackBar(
              message: 'Erreur lors de l\'upload de l\'image');
          _isLoading.value = false;
          return;
        }
      }

      final updateData = <String, dynamic>{
        'name': nameController.text.trim(),
        'address': addressController.text.trim(),
        'image_url': imageUrl,
      };

      if (userController.userRole == 'Admin') {
        updateData['statut'] = selectedStatut.value;

        if (latitudeController.text.isNotEmpty) {
          updateData['latitude'] = double.tryParse(latitudeController.text);
        }
        if (longitudeController.text.isNotEmpty) {
          updateData['longitude'] = double.tryParse(longitudeController.text);
        }
      }

      final success = await etablissementController.updateEtablissement(
        etablissement.id,
        updateData,
      );

      if (success) {
        TLoaders.successSnackBar(
            message: 'Établissement mis à jour avec succès');
        Get.back(result: true);
      } else {
        TLoaders.errorSnackBar(message: 'Échec de la mise à jour');
      }
    } catch (e) {
      TLoaders.errorSnackBar(message: 'Erreur: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}
