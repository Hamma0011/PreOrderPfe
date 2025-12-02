import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../models/dashboard_stats_model.dart';


import 'revenue_item.dart';
class RevenueChart extends StatelessWidget {
    final DashboardStats stats;
  final bool dark;
  const RevenueChart({super.key, required this.stats, required this.dark});

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Évolution des Revenus',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              RevenueItem( label: 
                  'Aujourd\'hui', value: stats.todayRevenue, color: Colors.orange, dark: dark),
              RevenueItem(
                  label: 'Ce Mois', value: stats.monthlyRevenue, color: Colors.green, dark: dark),
              RevenueItem(label: 'Total', value: stats.totalRevenue, color: Colors.blue, dark: dark),
            ],
          ),
        ],
      ),
    );
  }
}