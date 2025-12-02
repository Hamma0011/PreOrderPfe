import 'package:caferesto/features/shop/models/banner_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../shop/controllers/banner_controller.dart';
import '../../../controllers/user_controller.dart';

class BuildTypeLien extends StatelessWidget {
  final BannerController controller;
  final BannerModel banner;
  final bool isAdminView;
  const BuildTypeLien(
      {super.key,
      required this.controller,
      required this.isAdminView,      required this.banner});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Obx(() {
      final currentValue = controller.selectedLinkType.value;
      final hasPendingLinkType = banner.pendingChanges != null &&
          banner.pendingChanges!['link_type'] != null;
      final pendingLinkType = hasPendingLinkType
          ? banner.pendingChanges!['link_type'].toString()
          : null;
      final userController = Get.find<UserController>();
      final isGerant = userController.userRole == 'Gérant';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String?>(
            value: currentValue.isEmpty ? null : currentValue,
            decoration: InputDecoration(
              labelText: 'Type de lien',
              prefixIcon: const Icon(Iconsax.link),
              filled: isAdminView,
            ),
            items: [
              DropdownMenuItem(
                  value: null,
                  child: Text(
                    'Aucun lien',
                    style: TextStyle(
                        color: dark ? Colors.white : TColors.eerieBlack),
                  )),
              DropdownMenuItem(
                  value: 'product',
                  child: Text(
                    'Produit',
                    style: TextStyle(
                        color: dark ? Colors.white : TColors.eerieBlack),
                  )),
              DropdownMenuItem(
                value: 'establishment',
                child: Text(
                  'Établissement',
                  style: TextStyle(
                      color: dark ? Colors.white : TColors.eerieBlack),
                ),
              ),
            ],
            onChanged: isAdminView
                ? null
                : (value) {
                    controller.selectedLinkType.value = value ?? '';
                    if (value != banner.linkType) {
                      controller.selectedLinkId.value = ''; // Reset selection
                    }
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
          ),
          // Afficher le type de lien modifié sous le dropdown
          if (hasPendingLinkType && pendingLinkType != null) ...[
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
                          'Nouveau type de lien:',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          pendingLinkType == 'product'
                              ? 'Produit'
                              : pendingLinkType == 'establishment'
                                  ? 'Établissement'
                                  : 'Aucun lien',
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
    });
  }
}
