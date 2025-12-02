import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../shop/controllers/banner_controller.dart';
import '../../../../shop/models/banner_model.dart';
import '../../../../shop/models/etablissement_model.dart';
import '../../../controllers/user_controller.dart';

class LinkSelector extends StatelessWidget {
  final BannerController controller;
  final bool isAdminView;
  final BannerModel banner;
  const LinkSelector({super.key, required this.controller, required this.isAdminView, required this.banner});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Déterminer le type de lien à afficher : priorité au type dans pendingChanges si présent
      final pendingLinkType = banner.pendingChanges != null
          ? banner.pendingChanges!['link_type']?.toString()
          : null;
      final linkType = pendingLinkType ?? controller.selectedLinkType.value;

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

        // Vérifier si une modification est en attente pour un produit
        // Soit le type de lien a changé vers 'product', soit le produit a changé (même type)
        final hasPendingLink = banner.pendingChanges != null &&
            (banner.pendingChanges!['link_type'] == 'product' ||
                (banner.pendingChanges!['link'] != null &&
                    linkType == 'product'));
        final pendingLinkId =
            hasPendingLink && banner.pendingChanges!['link'] != null
                ? banner.pendingChanges!['link']?.toString()
                : null;
        final pendingProduct = pendingLinkId != null && pendingLinkId.isNotEmpty
            ? products.firstWhereOrNull((p) => p.id == pendingLinkId)
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: isValidValue ? selectedValue : null,
              decoration: InputDecoration(
                labelText: 'Sélectionner un produit',
                prefixIcon: const Icon(Iconsax.shop),
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
            ),
            // Afficher le nouveau produit sélectionné sous le dropdown
            if (hasPendingLink && pendingProduct != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.edit, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouveau produit sélectionné:',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pendingProduct.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
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
          if (controller.selectedLinkId.value.isEmpty && !isAdminView) {
            controller.selectedLinkId.value = gerantEtablissement.id ?? '';
          }
        }

        final selectedValue = controller.selectedLinkId.value;
        final isValidValue = selectedValue.isNotEmpty &&
            establishments.any((e) => e.id == selectedValue);

        // Vérifier si une modification est en attente pour un établissement
        // Soit le type de lien a changé vers 'establishment', soit l'établissement a changé (même type)
        final hasPendingLink = banner.pendingChanges != null &&
            (banner.pendingChanges!['link_type'] == 'establishment' ||
                (banner.pendingChanges!['link'] != null &&
                    linkType == 'establishment'));
        final pendingLinkId =
            hasPendingLink && banner.pendingChanges!['link'] != null
                ? banner.pendingChanges!['link']?.toString()
                : null;
        final pendingEstablishment =
            pendingLinkId != null && pendingLinkId.isNotEmpty
                ? establishments.firstWhereOrNull((e) => e.id == pendingLinkId)
                : null;

        // Déterminer l'établissement actuel à afficher
        final currentEstablishment = isValidValue
            ? establishments.firstWhere((e) => e.id == selectedValue)
            : gerantEtablissement;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ne pas afficher le dropdown pour le gérant, afficher directement l'établissement
            if (isGerant && !isAdminView) ...[
              if (currentEstablishment != null) ...[
                Container(
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
                ),
              ],
            ] else ...[
              // Pour l'admin, afficher le dropdown
              DropdownButtonFormField<String>(
                value: isValidValue ? selectedValue : null,
                decoration: InputDecoration(
                  labelText: 'Sélectionner un établissement',
                  prefixIcon: const Icon(Iconsax.home),
                  filled: isAdminView,
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
              ),
            ],
            // Afficher le nouvel établissement sélectionné sous le dropdown/champ
            if (hasPendingLink && pendingEstablishment != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.edit, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nouvel établissement sélectionné:',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pendingEstablishment.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      }

      return const SizedBox.shrink();
    });
  }
}
