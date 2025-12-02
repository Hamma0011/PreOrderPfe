import 'package:caferesto/features/profil/screens/dashboard/widgets/system_stat_item.dart';
import 'package:flutter/material.dart';
import 'package:caferesto/features/profil/models/dashboard_stats_model.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
class SystemStats extends StatelessWidget {
  final DashboardStats stats;
  final bool dark;
  final bool isAdmin;
  const SystemStats({
    super.key,
    required this.stats,
    required this.dark,
    this.isAdmin = false,
  });

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
            'Statistiques Système',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          // Statistiques spécifiques selon le rôle
          if (isAdmin) ...[
            SystemStatItem(
              label: 'Total Établissements',
              value: stats.totalEtablissements.toString(),
              icon: Iconsax.home,
            ),
            SystemStatItem(
              label: 'Total Utilisateurs',
              value: stats.totalUsers.toString(),
              icon: Iconsax.profile_2user,
            ),
          ] else ...[
            SystemStatItem(
              label: 'Total Produits',
              value: stats.totalProducts.toString(),
              icon: Iconsax.box,
            ),
            SystemStatItem(
              label: 'Produits Stock Faible',
              value: stats.lowStockProducts.toString(),
              icon: Iconsax.warning_2,
            ),
          ],
          // Statistiques communes
          SystemStatItem(
            label: 'Valeur Moyenne Commande',
            value: '${stats.averageOrderValue.toStringAsFixed(2)} DT',
            icon: Iconsax.dollar_circle,
          ),
          SystemStatItem(
            label: 'Commandes Aujourd\'hui',
            value: stats.ordersToday.toString(),
            icon: Iconsax.calendar,
          ),
          SystemStatItem(
            label: 'Commandes Ce Mois',
            value: stats.ordersThisMonth.toString(),
            icon: Iconsax.chart_2,
          ),
        ],
      ),
    );
  }
}