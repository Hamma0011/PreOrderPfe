import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../shop/controllers/banner_controller.dart';
import '../../../../shop/models/banner_model.dart';
import 'status_option.dart';

void showStatusChangeDialog(
    BuildContext context, BannerModel banner, BannerController controller) {
  final currentStatus = banner.status;

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Changer le statut"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Bannière: ${banner.name}"),
          const SizedBox(height: 16),
          const Text("Sélectionner le nouveau statut:"),
          const SizedBox(height: 16),
          StatusOption(
              status: 'en_attente',
              label: 'En attente',
              color: Colors.orange,
              icon: Iconsax.clock,
              currentStatus: currentStatus,
              banner: banner,
              controller: controller),
          const SizedBox(height: 8),
          StatusOption(
              status: 'publiee',
              label: 'Publiée',
              color: Colors.green,
              icon: Iconsax.tick_circle,
              currentStatus: currentStatus,
              banner: banner,
              controller: controller),
          const SizedBox(height: 8),
          StatusOption(
              status: 'refusee',
              label: 'Refusée',
              color: Colors.red,
              icon: Iconsax.close_circle,
              currentStatus: currentStatus,
              banner: banner,
              controller: controller),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text("Annuler"),
        ),
      ],
    ),
  );
}
