import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../shop/controllers/banner_controller.dart';
import '../../../../shop/models/banner_model.dart';

class StatusOption extends StatelessWidget {
  final String status;
  final String label;
  final MaterialColor color;
  final IconData icon;
  final String currentStatus;
  final BannerModel banner;
  final BannerController controller;
  const StatusOption(
      {super.key,
      required this.status,
      required this.label,
      required this.color,
      required this.icon,
      required this.currentStatus,
      required this.banner,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    final isSelected = status == currentStatus;

    return InkWell(
      onTap: isSelected
          ? null
          : () {
              Get.back();
              controller.updateBannerStatus(banner.id, status);
            },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.shade100 : color.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color.shade300 : color.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color.shade700, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: color.shade700,
                ),
              ),
            ),
            if (isSelected)
              Icon(Iconsax.tick_circle, color: color.shade700, size: 20),
          ],
        ),
      ),
    );
  }
}
