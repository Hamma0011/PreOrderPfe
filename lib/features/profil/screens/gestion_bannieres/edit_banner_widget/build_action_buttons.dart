import 'package:caferesto/features/shop/controllers/banner_controller.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../shop/models/banner_model.dart';
import 'show_approve_dialog.dart';
import 'show_reject_dialog.dart';

class BuildActionButtons extends StatelessWidget {
  final bool isAdminView;
  final BannerModel banner;
  final BannerController controller;
  const BuildActionButtons(
      {super.key,
      required this.isAdminView,
      required this.banner,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.canApprove(banner)) {
      // Boutons pour approuver/refuser les modifications (Admin)
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : () => showApproveDialog(context, banner, controller),
              icon: const Icon(Iconsax.tick_circle),
              label: const Text('Approuver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : () => showRejectDialog(context, banner, controller),
              icon: const Icon(Iconsax.close_circle),
              label: const Text('Refuser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      );
    } else if (controller.isGerant) {
      // Bouton Modifier (seulement pour Gérant)
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.updateBanner(banner.id),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Modifier la bannière'),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
