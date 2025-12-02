import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../shop/controllers/banner_controller.dart';
import '../../../../shop/models/etablissement_model.dart';
import '../../../controllers/user_controller.dart';

class LinkSelector extends StatelessWidget {
  final BannerController controller;
  final bool isAdminView;

  const LinkSelector(
      {super.key, required this.controller, required this.isAdminView});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final linkType = controller.selectedLinkType.value;
      if (linkType.isEmpty) return const SizedBox.shrink();

      if (linkType == 'product') {
        final products = controller.products;
        if (products.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Aucun produit disponible',
                style: TextStyle(color: Colors.grey)),
          );
        }

        final selectedValue = controller.selectedLinkId.value;
        final isValidValue = selectedValue.isNotEmpty &&
            products.any((p) => p.id == selectedValue);

        return DropdownButtonFormField<String>(
          value: isValidValue ? selectedValue : null,
          decoration: InputDecoration(
            labelText: 'Sélectionner un produit',
            prefixIcon: Icon(Iconsax.shop),
            filled: isAdminView,
          ),
          items: products.map((product) {
            return DropdownMenuItem(
              value: product.id,
              child: Text(product.name),
            );
          }).toList(),
          onChanged: isAdminView
              ? null
              : (value) {
                  controller.selectedLinkId.value = value ?? '';
                },
          validator: (value) {
            if (linkType.isNotEmpty && (value == null || value.isEmpty)) {
              return 'Veuillez sélectionner un produit';
            }
            return null;
          },
        );
      } else if (linkType == 'establishment') {
        final userController = Get.find<UserController>();
        final isGerant = userController.userRole == 'Gérant';

        final establishments =
            controller.establishments.where((e) => e.id != null).toList();
        if (establishments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Aucun établissement disponible',
                style: TextStyle(color: Colors.grey)),
          );
        }

        // Pour le gérant, récupérer son établissement par défaut
        Etablissement? gerantEtablissement;
        if (isGerant && establishments.isNotEmpty) {
          gerantEtablissement = establishments.first;
          // Définir automatiquement l'établissement du gérant si pas encore défini
          if (controller.selectedLinkId.value.isEmpty) {
            controller.selectedLinkId.value = gerantEtablissement.id ?? '';
          }
        }

        final selectedValue = controller.selectedLinkId.value;
        final isValidValue = selectedValue.isNotEmpty &&
            establishments.any((e) => e.id == selectedValue);

        // Déterminer l'établissement actuel à afficher
        final currentEstablishment = isValidValue
            ? establishments.firstWhere((e) => e.id == selectedValue)
            : gerantEtablissement;

        // Ne pas afficher le dropdown pour le gérant, afficher directement l'établissement
        if (isGerant && currentEstablishment != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Iconsax.home, color: Colors.grey.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Établissement',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentEstablishment.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Pour l'admin, ne pas permettre la sélection
        return DropdownButtonFormField<String>(
          value: isValidValue ? selectedValue : null,
          decoration: const InputDecoration(
            labelText: 'Sélectionner un établissement',
            prefixIcon: Icon(Iconsax.home),
          ),
          items: establishments.map((establishment) {
            return DropdownMenuItem(
              value: establishment.id!,
              child: Text(establishment.name),
            );
          }).toList(),
          onChanged: isAdminView
              ? null
              : (value) {
                  controller.selectedLinkId.value = value ?? '';
                },
          validator: (value) {
            if (linkType.isNotEmpty && (value == null || value.isEmpty)) {
              return 'Veuillez sélectionner un établissement';
            }
            return null;
          },
        );
      }

      return const SizedBox.shrink();
    });
  }
}
