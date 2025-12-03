import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class OrdersBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> ordersByDay;
  final bool dark;

  const OrdersBarChart({
    super.key,
    required this.ordersByDay,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    // getOrdersByDayForChart devrait toujours retourner les 7 jours de la semaine
    // même si stats.ordersByDay est vide, donc ordersByDay ne devrait jamais être vide
    // Mais on garde cette vérification par sécurité
    if (ordersByDay.isEmpty) {
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
              'Commandes par Jour de la Semaine',
              style: Theme.of(context).textTheme.titleLarge,
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

    // Calculer le maximum en gérant le cas où tous les comptes sont 0
    final counts = ordersByDay.map((e) => (e['count'] as int?) ?? 0).toList();
    final maxCount = counts.isNotEmpty && counts.any((c) => c > 0)
        ? counts.reduce((a, b) => a > b ? a : b)
        : 10; // Valeur par défaut si toutes les valeurs sont 0

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
            'Commandes par Jour de la Semaine',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxCount > 0 ? (maxCount * 1.2).ceilToDouble() : 10.0,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.blue.shade600,
                    tooltipRoundedRadius: 8,
                    tooltipPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day =
                          (ordersByDay[groupIndex]['day'] as String?) ?? '';
                      final count =
                          (ordersByDay[groupIndex]['count'] as int?) ?? 0;
                      return BarTooltipItem(
                        '$day\n$count commande${count > 1 ? 's' : ''}',
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
                        if (index >= 0 && index < ordersByDay.length) {
                          final day =
                              ordersByDay[index]['day'] as String? ?? '';
                          if (day.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                day.length > 3 ? day.substring(0, 3) : day,
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
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                        );
                      },
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
                barGroups: ordersByDay.asMap().entries.map((entry) {
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
