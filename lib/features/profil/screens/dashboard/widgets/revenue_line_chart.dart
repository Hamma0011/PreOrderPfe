import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/dashboard_controller.dart';

class RevenueLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> dailyRevenue;
  final bool dark;
  final DashboardController controller;

  const RevenueLineChart({
    super.key,
    required this.dailyRevenue,
    required this.dark,
    required this.controller,
  });

  String _getPeriodLabel(String period) {
    switch (period) {
      case '7days':
        return '7 derniers jours';
      case 'month':
        return 'Ce mois';
      case '3months':
        return '3 derniers mois';
      case 'year':
        return 'Cette année';
      case 'all':
        return 'Toutes périodes';
      default:
        return '7 derniers jours';
    }
  }

  String _formatDateLabel(String date, String period) {
    if (period == 'year' || period == 'all') {
      // Format MM/YYYY pour les mois
      final parts = date.split('-');
      if (parts.length >= 2) {
        return '${parts[1]}/${parts[0]}';
      }
      return date;
    } else {
      // Format DD/MM pour les jours
      final parts = date.split('-');
      if (parts.length >= 3) {
        return '${parts[2]}/${parts[1]}';
      }
      return date.substring(5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final period = controller.revenuePeriodFilter.value;
      final periodLabel = _getPeriodLabel(period);

      if (dailyRevenue.isEmpty) {
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Évolution des Revenus (Cumulatif)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue.shade400.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: period,
                      underline: const SizedBox(),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      icon: Icon(
                        Iconsax.arrow_down_1,
                        size: 16,
                        color: Colors.blue.shade400,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '7days',
                          child: Text('7 jours'),
                        ),
                        DropdownMenuItem(
                          value: 'month',
                          child: Text('Mois'),
                        ),
                        DropdownMenuItem(
                          value: '3months',
                          child: Text('3 mois'),
                        ),
                        DropdownMenuItem(
                          value: 'year',
                          child: Text('Année'),
                        ),
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('Toutes périodes'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          controller.updateRevenuePeriodFilter(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('Aucune donnée disponible'),
                ),
              ),
            ],
          ),
        );
      }

      final maxRevenue = dailyRevenue
          .map((e) => (e['revenue'] as num?)?.toDouble() ?? 0.0)
          .reduce((a, b) => a > b ? a : b);

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Évolution des Revenus',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue.shade400.withValues(alpha: 0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: period,
                    underline: const SizedBox(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    icon: Icon(
                      Iconsax.arrow_down_1,
                      size: 16,
                      color: Colors.blue.shade400,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: '7days',
                        child: Text('7 jours'),
                      ),
                      DropdownMenuItem(
                        value: 'month',
                        child: Text('Mois'),
                      ),
                      DropdownMenuItem(
                        value: '3months',
                        child: Text('3 mois'),
                      ),
                      DropdownMenuItem(
                        value: 'year',
                        child: Text('Année'),
                      ),
                      DropdownMenuItem(
                        value: 'all',
                        child: Text('Toutes périodes'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        controller.updateRevenuePeriodFilter(value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Période: $periodLabel',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: maxRevenue > 0 ? maxRevenue / 5 : 200,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < dailyRevenue.length) {
                            final date =
                                dailyRevenue[value.toInt()]['date'] as String;
                            // Afficher seulement certains points pour éviter la surcharge
                            final interval = dailyRevenue.length > 30
                                ? (dailyRevenue.length / 10).ceil()
                                : (dailyRevenue.length > 7
                                    ? (dailyRevenue.length / 5).ceil()
                                    : 1);
                            if (value.toInt() % interval == 0 ||
                                value.toInt() == dailyRevenue.length - 1) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _formatDateLabel(date, period),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: maxRevenue > 0 ? maxRevenue / 5 : 200,
                        reservedSize: 50,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()} DT',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border:
                        Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  minX: 0,
                  maxX: (dailyRevenue.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxRevenue > 0 ? maxRevenue * 1.2 : 1000,
                  lineBarsData: [
                    LineChartBarData(
                      spots: dailyRevenue.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          (entry.value['revenue'] as num?)?.toDouble() ?? 0.0,
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue.shade400,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.shade400.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
