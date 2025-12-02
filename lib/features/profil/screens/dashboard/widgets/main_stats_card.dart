import 'package:flutter/material.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../models/dashboard_stats_model.dart';

import 'package:iconsax/iconsax.dart';

import 'stat_card.dart';

class MainStatsCard extends StatelessWidget {
  final DashboardStats stats;
  final bool dark;
  final bool isAdmin;
  const MainStatsCard(
      {super.key,
      required this.stats,
      required this.dark,
      this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Déterminer le nombre de colonnes selon la largeur de l'écran
        int crossAxisCount;
        double childAspectRatio;
        double iconSize;
        double valueFontSize;
        double titleFontSize;
        double horizontalPadding;
        double verticalPadding;

        if (constraints.maxWidth > 1200) {
          // Desktop large
          crossAxisCount = 4;
          childAspectRatio = 3.5;
          iconSize = 16;
          valueFontSize = 14;
          titleFontSize = 10;
          horizontalPadding = AppSizes.sm;
          verticalPadding = AppSizes.xs;
        } else if (constraints.maxWidth > 800) {
          // Desktop moyen / Tablette large
          crossAxisCount = 3;
          childAspectRatio = 2.8;
          iconSize = 16;
          valueFontSize = 14;
          titleFontSize = 10;
          horizontalPadding = AppSizes.sm;
          verticalPadding = AppSizes.xs;
        } else if (constraints.maxWidth > 600) {
          // Tablette
          crossAxisCount = 2;
          childAspectRatio = 2.5;
          iconSize = 18;
          valueFontSize = 16;
          titleFontSize = 11;
          horizontalPadding = AppSizes.sm;
          verticalPadding = AppSizes.xs;
        } else if (constraints.maxWidth > 400) {
          // Mobile moyen
          crossAxisCount = 1;
          childAspectRatio = 3.2;
          iconSize = 20;
          valueFontSize = 18;
          titleFontSize = 12;
          horizontalPadding = AppSizes.sm;
          verticalPadding = AppSizes.xs;
        } else {
          // Mobile petit (Galaxy A50 et similaires)
          crossAxisCount = 1;
          childAspectRatio = 3.5;
          iconSize = 18;
          valueFontSize = 16;
          titleFontSize = 11;
          horizontalPadding = AppSizes.xs;
          verticalPadding = AppSizes.xs / 2;
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing:
              constraints.maxWidth < 400 ? AppSizes.xs : AppSizes.sm,
          mainAxisSpacing:
              constraints.maxWidth < 400 ? AppSizes.xs : AppSizes.sm,
          childAspectRatio: childAspectRatio,
          children: [
            StatCard(
              title: 'Total Commandes',
              value: stats.totalOrders.toString(),
              icon: Iconsax.shopping_bag,
              color: Colors.blue,
              dark: dark,
              iconSize: iconSize,
              valueFontSize: valueFontSize,
              titleFontSize: titleFontSize,
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
            ),
            StatCard(
              title: 'Revenus Total',
              value: '${stats.totalRevenue.toStringAsFixed(2)} DT',
              icon: Iconsax.dollar_circle,
              color: Colors.green,
              dark: dark,
              iconSize: iconSize,
              valueFontSize: valueFontSize,
              titleFontSize: titleFontSize,
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
            ),
            StatCard(
              title: 'Revenus Aujourd\'hui',
              value: '${stats.todayRevenue.toStringAsFixed(2)} DT',
              icon: Iconsax.calendar,
              color: Colors.orange,
              dark: dark,
              iconSize: iconSize,
              valueFontSize: valueFontSize,
              titleFontSize: titleFontSize,
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
            ),
            StatCard(
              title: 'Revenus Ce Mois',
              value: '${stats.monthlyRevenue.toStringAsFixed(2)} DT',
              icon: Iconsax.chart,
              color: Colors.purple,
              dark: dark,
              iconSize: iconSize,
              valueFontSize: valueFontSize,
              titleFontSize: titleFontSize,
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
            ),
            StatCard(
              title: 'Commandes En Attente',
              value: stats.pendingOrders.toString(),
              icon: Iconsax.clock,
              color: Colors.amber,
              dark: dark,
              iconSize: iconSize,
              valueFontSize: valueFontSize,
              titleFontSize: titleFontSize,
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
            ),
            StatCard(
              title: 'Commandes Actives',
              value: stats.activeOrders.toString(),
              icon: Iconsax.activity,
              color: Colors.cyan,
              dark: dark,
              iconSize: iconSize,
              valueFontSize: valueFontSize,
              titleFontSize: titleFontSize,
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
            ),
            StatCard(
              title: isAdmin ? 'Établissements' : 'Produits',
              value: isAdmin
                  ? stats.totalEtablissements.toString()
                  : stats.totalProducts.toString(),
              icon: Iconsax.box,
              color: Colors.indigo,
              dark: dark,
              iconSize: iconSize,
              valueFontSize: valueFontSize,
              titleFontSize: titleFontSize,
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
            ),
            StatCard(
              title: isAdmin ? 'Utilisateurs' : 'Stock Faible',
              value: isAdmin
                  ? stats.totalUsers.toString()
                  : stats.lowStockProducts.toString(),
              icon: Iconsax.warning_2,
              color: Colors.red,
              dark: dark,
              iconSize: iconSize,
              valueFontSize: valueFontSize,
              titleFontSize: titleFontSize,
              horizontalPadding: horizontalPadding,
              verticalPadding: verticalPadding,
            ),
          ],
        );
      },
    );
  }
}
