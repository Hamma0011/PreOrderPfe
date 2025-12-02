import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../shop/controllers/banner_controller.dart';
import '../../../../shop/models/banner_model.dart';

void showApproveDialog(
  BuildContext context,
  BannerModel banner,
  BannerController controller,
) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Iconsax.tick_circle, color: Colors.green.shade600),
          const SizedBox(width: 8),
          const Text("Approuver les modifications"),
        ],
      ),
      content: Text(
          "Approuver les modifications pour la bannière \"${banner.name}\" ?"),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Annuler"),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            Get.back();
            await controller.approvePendingChanges(banner.id);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
          child: const Text("Approuver"),
        ),
      ],
    ),
  );
}
