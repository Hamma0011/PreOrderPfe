// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'features/shop/controllers/navigation_controller.dart';
import 'utils/constants/colors.dart';
import 'utils/helpers/helper_functions.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: Obx(() => controller.getScreen(controller.selectedIndex.value)),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
              color: darkMode
                  ? TColors.darkModeBackground
                  : TColors.playStoreBackground,
              border: Border(
                  top: BorderSide(
                color: Colors.grey.shade300.withValues(alpha: 0.5),
                width: 0.5,
              ))),
          child: NavigationBar(
            height: 70,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
                controller.selectedIndex.value = index,
            backgroundColor: darkMode
                ? TColors.darkModeBackground
                : TColors.playStoreBackground,
            indicatorColor: Colors.blue.withValues(alpha: 0.5),
            surfaceTintColor: Colors.transparent,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(Iconsax.home, color: TColors.playStoreUnselected),
                selectedIcon: Icon(Iconsax.home5, color: Colors.blue[100]),
                label: 'Accueil',
              ),
              NavigationDestination(
                icon: Icon(Iconsax.shop, color: TColors.playStoreUnselected),
                selectedIcon: Icon(Iconsax.shop5, color: Colors.blue[100]),
                label: 'Établissement',
              ),
              NavigationDestination(
                icon: Icon(Iconsax.heart, color: TColors.playStoreUnselected),
                selectedIcon: Icon(Iconsax.heart5, color: Colors.blue[300]),
                label: 'Favoris',
              ),
              NavigationDestination(
                icon: Icon(Iconsax.profile_circle,
                    color: TColors.playStoreUnselected),
                selectedIcon:
                    Icon(Iconsax.profile_circle5, color: Colors.blue[300]),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
