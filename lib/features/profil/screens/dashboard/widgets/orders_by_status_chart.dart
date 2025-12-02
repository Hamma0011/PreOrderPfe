import 'package:caferesto/features/profil/controllers/gerant_dashboard_controller.dart';
import 'package:caferesto/utils/constants/enums.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../models/dashboard_stats_model.dart';

class OrdersByStatusChart extends StatelessWidget {
  final DashboardStats stats;
  final bool dark;
  const OrdersByStatusChart({super.key, required this.stats, required this.dark});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GerantDashboardController>();
    return  Container(
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
          Text(
            'Commandes par Statut',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          ...stats.ordersByStatus.entries.map((entry) {
            final status = entry.key;
            final count = entry.value;
                    final percentage =
                  controller.calculatePercentage(count, stats.totalOrders);

            Color statusColor;
            switch (status) {
              case 'pending':
                statusColor = Colors.amber;
                break;
              case 'preparing':
                statusColor = Colors.blue;
                break;
              case 'ready':
                statusColor = Colors.cyan;
                break;
              case 'delivered':
                statusColor = Colors.green;
                break;
              case 'cancelled':
                statusColor = Colors.red;
                break;
              default:
                statusColor = Colors.grey;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(THelperFunctions.getStatusLabel(status as OrderStatus)),
                      Text('$count (${percentage.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
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