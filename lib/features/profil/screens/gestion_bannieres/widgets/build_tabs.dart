import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../controllers/banner_management_controller.dart';
import 'adaptive_tab_label.dart';

class BuildTabs extends StatelessWidget {
  final BannerManagementController controller;
  const BuildTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: dark ? TColors.darkContainer : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: controller.tabController,
            tabs: [
              Tab(
                child: AdaptiveTabLabel(
                  icon: Iconsax.clock,
                  label: 'En attente',
                  count: controller.enAttenteCount,
                  badgeColor: Colors.orange.shade100,
                  badgeTextColor: Colors.orange.shade700,
                ),
              ),
              Tab(
                child: AdaptiveTabLabel(
                  icon: Iconsax.tick_circle,
                  label: 'Publiée',
                  count: controller.publieeCount,
                  badgeColor: Colors.green.shade100,
                  badgeTextColor: Colors.green.shade700,
                ),
              ),
              Tab(
                child: AdaptiveTabLabel(
                  icon: Iconsax.close_circle,
                  label: 'Refusée',
                  count: controller.refuseeCount,
                  badgeColor: Colors.red.shade100,
                  badgeTextColor: Colors.red.shade700,
                ),
              ),
            ],
            labelColor: Colors.blue.shade600,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue.shade600,
          ),
        ));
  }
}
