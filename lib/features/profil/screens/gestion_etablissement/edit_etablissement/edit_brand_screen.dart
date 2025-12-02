import 'dart:typed_data';

import 'package:caferesto/utils/constants/colors.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../shop/models/etablissement_model.dart';
import '../../../../shop/models/horaire_model.dart';
import '../../../controllers/edit_etablissement_controller.dart';

import '../../gestion_categories/widgets/category_form_widgets.dart';

// Widget Stateless
class EditEtablissementScreen extends StatelessWidget {
  final Etablissement etablissement;

  const EditEtablissementScreen({super.key, required this.etablissement});

  @override
  Widget build(BuildContext context) {
    // Initialiser le contrôleur
    final controller =
        Get.put(EditEtablissementController(etablissement: etablissement));

    return Scaffold(
      appBar: TAppBar(
        title: const Text('Modifier l\'établissement'),
        actions: [
          Obx(() => IconButton(
                icon: const Icon(Icons.save),
                onPressed: controller.isLoading
                    ? null
                    : controller.updateEtablissement,
                tooltip: 'Enregistrer',
              )),
        ],
      ),
      body: FadeTransition(
        opacity: controller.fadeAnimation,
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final isMobile = width < 600;
          final isTablet = width >= 600 && width < 900;
          final isDesktop = width >= 900;

          final content = ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth:
                    isDesktop ? 1100 : (isTablet ? 760 : double.infinity)),
            child: Form(
              key: controller.formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isDesktop || isTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildImageSection(context, width, controller),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                _buildUserRoleSection(context, controller),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                _buildStatutSection(context, controller),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                _buildHorairesSection(
                                    context, width, controller),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildBasicInfoSection(width, controller),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                _buildCoordinatesSection(
                                    context, width, controller),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(() => ElevatedButton.icon(
                                            onPressed:
                                                controller.isLoading
                                                    ? null
                                                    : controller
                                                        .updateEtablissement,
                                            icon: const Icon(Iconsax.save_2),
                                            label: const Text(
                                                'Enregistrer les modifications'),
                                            style: ElevatedButton.styleFrom(
                                              minimumSize:
                                                  const Size.fromHeight(55),
                                              backgroundColor: TColors.primary,
                                            ),
                                          )),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => Get.back(),
                                        icon: const Icon(Iconsax.close_circle),
                                        label: const Text('Annuler'),
                                        style: OutlinedButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(55),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Les champs marqués d\'un * sont requis.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildImageSection(context, width, controller),
                          const SizedBox(height: AppSizes.spaceBtwSections),
                          _buildUserRoleSection(context, controller),
                          const SizedBox(height: AppSizes.spaceBtwSections),
                          _buildStatutSection(context, controller),
                          const SizedBox(height: AppSizes.spaceBtwSections),
                          _buildBasicInfoSection(width, controller),
                          const SizedBox(height: AppSizes.spaceBtwSections),
                          _buildCoordinatesSection(context, width, controller),
                          const SizedBox(height: AppSizes.spaceBtwSections),
                          _buildHorairesSection(context, width, controller),
                          const SizedBox(height: AppSizes.spaceBtwSections),
                          Obx(() => ElevatedButton.icon(
                                onPressed: controller.isLoading
                                    ? null
                                    : controller.updateEtablissement,
                                icon: const Icon(Iconsax.save_2),
                                label:
                                    const Text('Enregistrer les modifications'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(55),
                                  backgroundColor: TColors.primary,
                                ),
                              )),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => Get.back(),
                            icon: const Icon(Iconsax.close_circle),
                            label: const Text('Annuler'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(55),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );

          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 20, vertical: 16),
              child: content,
            ),
          );
        }),
      ),
    );
  }

  static Widget _buildImageSection(BuildContext context, double width,
      EditEtablissementController controller) {
    final previewHeight =
        (width >= 900) ? 220.0 : (width >= 600 ? 200.0 : 160.0);
    final previewWidth = double.infinity;
    final borderRadius = BorderRadius.circular(12.0);

    Widget mainImageWidget() {
      return Obx(() {
        if (controller.selectedImage.value != null) {
          return FutureBuilder<Uint8List?>(
            future: controller.selectedImage.value!.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ClipRRect(
                  borderRadius: borderRadius,
                  child: Image.memory(snapshot.data!,
                      fit: BoxFit.cover,
                      width: previewWidth,
                      height: previewHeight),
                );
              } else {
                return SizedBox(
                  height: previewHeight,
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
        } else if (controller.currentImageUrl.value != null &&
            controller.currentImageUrl.value!.isNotEmpty) {
          return ClipRRect(
            borderRadius: borderRadius,
            child: Image.network(controller.currentImageUrl.value!,
                fit: BoxFit.cover, width: previewWidth, height: previewHeight,
                errorBuilder: (context, error, stackTrace) {
              return Container(
                height: previewHeight,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image,
                    color: Colors.grey, size: 40),
              );
            }),
          );
        } else {
          return SizedBox(
            height: previewHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined,
                      color: Colors.grey, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Ajouter une image',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }
      });
    }

    return CategoryFormCard(
      children: [
        const Text('Image de l\'établissement',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: controller.pickMainImage,
          child: Container(
            width: previewWidth,
            height: previewHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: borderRadius,
            ),
            child: Stack(
              children: [
                mainImageWidget(),
                Obx(() => (controller.selectedImage.value != null ||
                        (controller.currentImageUrl.value != null &&
                            controller.currentImageUrl.value!.isNotEmpty))
                    ? Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 16),
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cliquez pour changer l\'image',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  static Widget _buildBasicInfoSection(
      double width, EditEtablissementController controller) {
    final isWide = width >= 900;

    return CategoryFormCard(children: [
      const Text('Informations de base',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16),
      TextFormField(
        controller: controller.nameController,
        decoration: const InputDecoration(
            labelText: 'Nom de l\'établissement *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business_outlined)),
        validator: (v) =>
            v == null || v.isEmpty ? 'Veuillez entrer le nom' : null,
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: controller.addressController,
        decoration: const InputDecoration(
            labelText: 'Adresse complète *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on_outlined)),
        maxLines: isWide ? 4 : 3,
        validator: (v) =>
            v == null || v.isEmpty ? 'Veuillez entrer l\'adresse' : null,
      ),
    ]);
  }

  static Widget _buildCoordinatesSection(BuildContext context, double width,
      EditEtablissementController controller) {
    return CategoryFormCard(children: [
      const Text('Coordonnées GPS',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller.latitudeController,
              decoration: const InputDecoration(
                labelText: 'Latitude',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.explore_outlined),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: controller.longitudeController,
              decoration: const InputDecoration(
                labelText: 'Longitude',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.explore_outlined),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        'Les coordonnées GPS sont optionnelles',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ]);
  }

  // Section statut (pour Admin seulement)
  static Widget _buildStatutSection(
      BuildContext context, EditEtablissementController controller) {
    // Obx seulement pour vérifier le rôle utilisateur (qui peut théoriquement changer)
    return Obx(() {
      // Si ce n'est pas Admin, retourner SizedBox
      if (controller.userController.user.value.role != 'Admin') {
        return const SizedBox();
      }

      // Si Admin, afficher la section avec le Dropdown
      return CategoryFormCard(
        children: [
          const Text('Statut de l\'établissement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: DropdownButtonFormField<StatutEtablissement>(
                isExpanded: true,
                value: controller.selectedStatut.value,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Statut',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: StatutEtablissement.values.map((statut) {
                  return DropdownMenuItem<StatutEtablissement>(
                    value: statut,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: THelperFunctions.getStatutColor(statut),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                            child: Text(
                          THelperFunctions.getStatutText(statut),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        )),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (newStatut) {
                  if (newStatut != null) {
                    controller.selectedStatut.value = newStatut;
                  }
                },
              ),
            );
          }),
        ],
      );
    });
  }

  static Widget _buildUserRoleSection(
      BuildContext context, EditEtablissementController controller) {
    return CategoryFormCard(
      children: [
        const Text('Rôle utilisateur',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.person, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connecté en tant que :',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Obx(() => Text(
                        controller.userController.user.value.role,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                      )),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.userController.user.value.fullName,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildHorairesSection(BuildContext context, double width,
      EditEtablissementController controller) {
    final isWide = width >= 900;

    return CategoryFormCard(
      children: [
        const Text('Horaires d\'ouverture',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Obx(() {
          if (!controller.horairesLoaded.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (!controller.horaireController.hasHoraires.value) {
            return _buildAucunHoraire();
          } else {
            return _buildHorairesPreview(controller);
          }
        }),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: controller.gererHoraires,
          icon: const Icon(Icons.schedule),
          label: Obx(() => Text(controller.horaireController.hasHoraires.value
              ? 'Modifier les horaires'
              : 'Configurer les horaires')),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, isWide ? 55 : 50),
            backgroundColor: Colors.orange[50],
            foregroundColor: Colors.orange[800],
          ),
        ),
      ],
    );
  }

  static Widget _buildAucunHoraire() {
    return const Column(
      children: [
        Icon(Icons.access_time, size: 48, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          'Aucun horaire configuré',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 4),
        Text(
          'Configurez les horaires d\'ouverture de votre établissement',
          style: TextStyle(color: Colors.grey, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget _buildHorairesPreview(EditEtablissementController controller) {
    final horairesOuverts = controller.horaireController.horaires
        .where((h) => h.estOuvert && h.isValid)
        .toList();
    horairesOuverts.sort((a, b) => a.jour.index.compareTo(b.jour.index));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              '${controller.horaireController.nombreJoursOuverts} jours ouverts',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            )),
        const SizedBox(height: 12),
        ...horairesOuverts.take(3).map((h) => _buildHorairePreview(h)),
        if (horairesOuverts.length > 3)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '... et ${horairesOuverts.length - 3} autres jours',
              style: const TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  static Widget _buildHorairePreview(Horaire horaire) {
    return Builder(
      builder: (context) {
        final dark = THelperFunctions.isDarkMode(context);
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? TColors.eerieBlack : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    THelperFunctions.getJourAbrege(horaire.jour),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      horaire.jour.valeur,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${horaire.ouverture} - ${horaire.fermeture}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.check_circle,
                color: Colors.green[400],
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}
