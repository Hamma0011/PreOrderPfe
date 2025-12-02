import 'package:flutter/material.dart';
import 'package:caferesto/features/profil/models/dashboard_stats_model.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/gerant_dashboard_controller.dart';

class PickupHours extends StatelessWidget {
  final DashboardStats stats;
  final bool dark;
  const PickupHours({super.key, required this.stats, required this.dark});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GerantDashboardController>();
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.clock, color: Colors.blue.shade400, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Heures de Pickup les Plus Fréquentes',
                  style: Theme.of(context).textTheme.titleLarge,
                  softWrap: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          if (stats.pickupHours.isEmpty)
            const Text('Aucune donnée disponible')
          else
            ...stats.pickupHours.asMap().entries.map((entry) {
              final index = entry.key;
              final hourData = entry.value;
              final hour = hourData['hour'] as String? ?? 'Inconnu';
              final count = hourData['count'] as int? ?? 0;
              final maxCount = stats.pickupHours.isNotEmpty
                  ? (stats.pickupHours[0]['count'] as int? ?? 1)
                  : 1;
              final percentage =
                  controller.calculatePercentage(count, maxCount);
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              hour,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '$count commande${count > 1 ? 's' : ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.orange.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
