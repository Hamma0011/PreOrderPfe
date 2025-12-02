import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/banner_management_controller.dart';

class BuildEmptyState extends StatelessWidget {
  const BuildEmptyState({super.key, required this.controller});

  final BannerManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.image, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                "Aucune bannière ${controller.getTabName(controller.selectedTabIndex.value).toLowerCase()}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ));
  }
}
