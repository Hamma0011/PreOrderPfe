import 'package:caferesto/features/shop/models/banner_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../shop/controllers/banner_controller.dart';
import 'status_change_dialog.dart';

class BuildChangerStatut extends StatelessWidget {
  final BannerController controller;
  final BannerModel banner;
  final bool isAdminView;
  const BuildChangerStatut(
      {super.key,
      required this.controller,
      required this.banner,
      required this.isAdminView});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.selectedStatus.value;
      String statusLabel;
      MaterialColor statusColor;
      IconData statusIcon;

      switch (status) {
        case 'publiee':
          statusLabel = 'Publiée';
          statusColor = Colors.green;
          statusIcon = Iconsax.tick_circle;
          break;
        case 'refusee':
          statusLabel = 'Refusée';
          statusColor = Colors.red;
          statusIcon = Iconsax.close_circle;
          break;
        default:
          statusLabel = 'En attente';
          statusColor = Colors.orange;
          statusIcon = Iconsax.clock;
      }

      return GestureDetector(
        onTap: isAdminView
            ? () => showStatusChangeDialog(context, banner, controller)
            : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.shade200,
              width: isAdminView ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'État actuel',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: statusColor.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 14,
                        color: statusColor.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAdminView
                          ? 'Appuyez pour changer le statut'
                          : 'Seul l\'administrateur peut modifier le statut.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isAdminView)
                Icon(
                  Iconsax.arrow_right_3,
                  color: statusColor.shade700,
                  size: 20,
                ),
            ],
          ),
        ),
      );
    });
  }
}
