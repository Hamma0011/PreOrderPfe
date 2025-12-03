import 'package:caferesto/utils/constants/enums.dart';
import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';

class StatusPieChart extends StatelessWidget {
  final Map<String, int> ordersByStatus;
  final bool dark;

  const StatusPieChart({
    super.key,
    required this.ordersByStatus,
    required this.dark,
  });

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.cyan;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refused':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ordersByStatus.isEmpty) {
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
              'Répartition des Commandes',
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

    final total = ordersByStatus.values.reduce((a, b) => a + b);
    final pieChartData = ordersByStatus.entries.toList();

    if (total == 0) {
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
              'Répartition des Commandes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('Aucune commande'),
              ),
            ),
          ],
        ),
      );
    }

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
            'Répartition des Commandes',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                // Desktop layout
                return Row(
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: pieChartData.map((entry) {
                            final percentage = (entry.value / total * 100);
                            return PieChartSectionData(
                              value: entry.value.toDouble(),
                              title: '${percentage.toStringAsFixed(1)}%',
                              color: getStatusColor(entry.key),
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: pieChartData.map((entry) {
                          final percentage = (entry.value / total * 100);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: getStatusColor(entry.key),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getStatusLabel(entry.key),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                Text(
                                  '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: getStatusColor(entry.key),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              } else {
                // Mobile layout
                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: pieChartData.map((entry) {
                            final percentage = (entry.value / total * 100);
                            return PieChartSectionData(
                              value: entry.value.toDouble(),
                              title: '${percentage.toStringAsFixed(1)}%',
                              color: getStatusColor(entry.key),
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...pieChartData.map((entry) {
                      final percentage = (entry.value / total * 100);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: getStatusColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getStatusLabel(entry.key),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Text(
                              '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: getStatusColor(entry.key),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  /// Convertit une chaîne de statut en OrderStatus et retourne le label
  String _getStatusLabel(String status) {
    if (status.isEmpty) {
      return 'Inconnu';
    }

    OrderStatus orderStatus;
    switch (status.toLowerCase().trim()) {
      case 'pending':
        orderStatus = OrderStatus.pending;
        break;
      case 'preparing':
        orderStatus = OrderStatus.preparing;
        break;
      case 'ready':
        orderStatus = OrderStatus.ready;
        break;
      case 'delivered':
        orderStatus = OrderStatus.delivered;
        break;
      case 'cancelled':
        orderStatus = OrderStatus.cancelled;
        break;
      case 'refused':
        orderStatus = OrderStatus.refused;
        break;
      default:
        // Si le statut n'est pas reconnu, retourner 'pending' par défaut
        orderStatus = OrderStatus.pending;
    }
    return THelperFunctions.getStatusLabel(orderStatus);
  }
}
