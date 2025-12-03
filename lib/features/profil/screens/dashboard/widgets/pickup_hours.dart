import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:caferesto/features/profil/models/dashboard_stats_model.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class PickupHours extends StatelessWidget {
  final DashboardStats stats;
  final bool dark;
  const PickupHours({super.key, required this.stats, required this.dark});

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
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: () {
                    final counts = stats.pickupHours
                        .map((e) => (e['count'] as int?) ?? 0)
                        .toList();
                    final maxCount =
                        counts.isNotEmpty && counts.any((c) => c > 0)
                            ? counts.reduce((a, b) => a > b ? a : b)
                            : 10;
                    return maxCount > 0
                        ? (maxCount * 1.2).ceilToDouble()
                        : 10.0;
                  }(),
                  minY: 0,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.blue.shade600,
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final hour = (stats.pickupHours[groupIndex]['hour']
                                as String?) ??
                            '';
                        final count = (stats.pickupHours[groupIndex]['count']
                                as int?) ??
                            0;
                        return BarTooltipItem(
                          '$hour\n$count commande${count > 1 ? 's' : ''}',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 &&
                              index < stats.pickupHours.length) {
                            final hour =
                                stats.pickupHours[index]['hour'] as String? ??
                                    '';
                            final label =
                                hour.length > 5 ? hour.substring(0, 5) : hour;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  barGroups: stats.pickupHours.asMap().entries.map((entry) {
                    final count = (entry.value['count'] as int?) ?? 0;
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: count.toDouble(),
                          color: count > 0
                              ? Colors.blue.shade400
                              : Colors.grey.shade300,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
