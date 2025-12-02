import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/dashboard_controller.dart';
import 'main_stats_card.dart';
import 'orders_bar_chart.dart';
import 'orders_by_day.dart';
import 'period_filter.dart';
import 'pickup_hours.dart';
import 'revenue_line_chart.dart';
import 'status_pie_chart.dart';
import 'system_stats.dart';
import 'top_etablissements_chart.dart';
import 'top_product_widget.dart';
import 'top_users.dart';

class DashboardContent extends StatelessWidget {
  final DashboardController controller;
  final bool dark;
  final bool isAdmin;

  const DashboardContent(
      {super.key,
      required this.controller,
      required this.dark,
      required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading && controller.stats.value == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final stats = controller.stats.value;
      if (stats == null) {
        return const Center(child: Text('Aucune statistique disponible'));
      }

      return RefreshIndicator(
        onRefresh: controller.loadDashboardStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filtre de période
              PeriodFilter(controller: controller, dark: dark, isAdmin: isAdmin),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Cartes de statistiques principales
              MainStatsCard(stats: stats, dark: dark, isAdmin: isAdmin),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Graphiques et statistiques détaillées
              Obx(() => FutureBuilder<List<Map<String, dynamic>>>(
                // Utiliser revenuePeriodFilter pour forcer le rechargement
                key: ValueKey(controller.revenuePeriodFilter.value),
                future: controller.getDailyRevenue(),
                builder: (context, dailyRevenueSnapshot) {
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: controller.getTopEtablissements(5),
                    builder: (context, topEtablissementsSnapshot) {
                      final dailyRevenue = dailyRevenueSnapshot.data ?? [];
                      final topEtablissements =
                          topEtablissementsSnapshot.data ?? [];
                      final ordersByDayForChart =
                          controller.getOrdersByDayForChart(stats.ordersByDay);

                      return LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 800) {
                            // Desktop layout
                            return Column(
                              children: [
                                // Première ligne : Revenue Line Chart et Status Pie Chart
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: RevenueLineChart(
                                        dailyRevenue: dailyRevenue,
                                        dark: dark,
                                        controller: controller,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: AppSizes.spaceBtwItems),
                                    Expanded(
                                      child: StatusPieChart(
                                        ordersByStatus: stats.ordersByStatus,
                                        dark: dark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                // Deuxième ligne : Orders Bar Chart et Top Etablissements
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: OrdersBarChart(
                                        ordersByDay: ordersByDayForChart,
                                        dark: dark,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: AppSizes.spaceBtwItems),
                                    isAdmin
                                        ? Expanded(
                                            child: TopEtablissementsChart(
                                              topEtablissements:
                                                  topEtablissements,
                                              dark: dark,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ],
                                ),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                // Troisième ligne : Top Products et System Stats
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: TopProductsWidget(
                                          stats: stats, dark: dark),
                                    ),
                                    const SizedBox(
                                        width: AppSizes.spaceBtwItems),
                                    Expanded(
                                      child:
                                          SystemStats(stats: stats, dark: dark, isAdmin: isAdmin),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          } else {
                            // Mobile layout
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RevenueLineChart(
                                  dailyRevenue: dailyRevenue,
                                  dark: dark,
                                  controller: controller,
                                ),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                StatusPieChart(
                                  ordersByStatus: stats.ordersByStatus,
                                  dark: dark,
                                ),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                OrdersBarChart(
                                  ordersByDay: ordersByDayForChart,
                                  dark: dark,
                                ),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                isAdmin
                                    ? TopEtablissementsChart(
                                        topEtablissements: topEtablissements,
                                        dark: dark,
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                TopProductsWidget(stats: stats, dark: dark),
                                const SizedBox(
                                    height: AppSizes.spaceBtwSections),
                                SystemStats(stats: stats, dark: dark, isAdmin: isAdmin),
                              ],
                            );
                          }
                        },
                      );
                    },
                  );
                },
              )),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Statistiques par jour et heures de pickup
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 800) {
                    // Desktop layout
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: OrdersByDay(stats: stats, dark: dark),
                        ),
                        const SizedBox(width: AppSizes.spaceBtwItems),
                        Expanded(
                          child: PickupHours(stats: stats, dark: dark),
                        ),
                      ],
                    );
                  } else {
                    // Mobile layout
                    return Column(
                      children: [
                        OrdersByDay(stats: stats, dark: dark),
                        const SizedBox(height: AppSizes.spaceBtwSections),
                        PickupHours(stats: stats, dark: dark),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: AppSizes.spaceBtwSections),

              // Utilisateurs les plus fidèles
              TopUsers(stats: stats, dark: dark),
            ],
          ),
        ),
      );
    });
  }
}
