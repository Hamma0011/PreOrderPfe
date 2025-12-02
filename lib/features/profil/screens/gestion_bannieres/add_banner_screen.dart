import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../shop/controllers/banner_controller.dart';
import '../../../../data/repositories/product/produit_repository.dart';
import '../../controllers/liste_etablissement_controller.dart';
import '../../controllers/user_controller.dart';

import 'widgets/image_section.dart';
import 'widgets/link_selector.dart';

class AddBannerScreen extends StatelessWidget {
  const AddBannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerController = Get.find<BannerController>();
    final produitRepository = Get.find<ProduitRepository>();
    final etablissementController = Get.find<ListeEtablissementController>();
    final userController = Get.find<UserController>();

    // Charger les données pour les dropdowns
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final products = await produitRepository.getAllProducts();
        bannerController.products.assignAll(products);
      } catch (e) {
        debugPrint('Erreur chargement produits: $e');
      }
      try {
        // Si gérant, charger uniquement son établissement
        if (userController.userRole == 'Gérant') {
          final gerantEtablissement = await etablissementController
              .getEtablissementUtilisateurConnecte();
          if (gerantEtablissement != null) {
            bannerController.establishments.assignAll([gerantEtablissement]);
          }
        } else {
          // Pour admin, charger tous les établissements
          final establishments =
              await etablissementController.getTousEtablissements();
          bannerController.establishments.assignAll(establishments);
        }
      } catch (e) {
        debugPrint('Erreur chargement établissements: $e');
      }
    });

    bannerController.clearForm();

    return Scaffold(
      appBar: TAppBar(
        title: const Text("Ajouter une bannière"),
      ),
      body: Obx(() => _buildBody(context, bannerController)),
    );
  }

  Widget _buildBody(BuildContext context, BannerController controller) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.defaultSpace),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Image
              ImageSection(controller:  controller,isMobile:  isMobile),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Nom de la bannière
              TextFormField(
                controller: controller.nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la bannière',
                  prefixIcon: Icon(Iconsax.text),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // Type de lien
              Obx(() {
                final currentValue = controller.selectedLinkType.value;
                final userController = Get.find<UserController>();
                final isGerant = userController.userRole == 'Gérant';

                return DropdownButtonFormField<String?>(
                  value: currentValue.isEmpty ? null : currentValue,
                  decoration: const InputDecoration(
                    labelText: 'Type de lien',
                    prefixIcon: Icon(Iconsax.link),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Aucun lien')),
                    DropdownMenuItem(value: 'product', child: Text('Produit')),
                    DropdownMenuItem(
                      value: 'establishment',
                      child: Text('Établissement'),
                    ),
                  ],
                  onChanged: (value) {
                    controller.selectedLinkType.value = value ?? '';
                    controller.selectedLinkId.value = ''; // Reset selection
                    // Si gérant sélectionne "établissement", définir automatiquement son établissement
                    if (isGerant &&
                        value == 'establishment' &&
                        controller.establishments.isNotEmpty) {
                      final gerantEtablissement = controller.establishments
                          .firstWhereOrNull((e) => e.id != null);
                      if (gerantEtablissement != null) {
                        controller.selectedLinkId.value =
                            gerantEtablissement.id ?? '';
                      }
                    }
                  },
                );
              }),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // Sélection du lien selon le type
              if (controller.selectedLinkType.value.isNotEmpty)
                LinkSelector(controller: controller, isAdminView: false,),
              const SizedBox(height: AppSizes.spaceBtwInputFields),

              // État actuel (toujours en_attente pour les nouvelles bannières)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'État actuel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Les nouvelles bannières sont créées avec le statut "En attente". L\'administrateur pourra les publier ou les refuser.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Bouton Ajouter
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.addBanner(),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ajouter la bannière'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
