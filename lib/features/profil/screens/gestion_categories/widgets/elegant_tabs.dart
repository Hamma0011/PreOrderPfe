import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../shop/controllers/category_controller.dart';

class ElegantTabs extends StatelessWidget {
  final CategoryController controller;
  const ElegantTabs({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    
    final selectedIndex = controller.tabController.index.obs;
    final dark = THelperFunctions.isDarkMode(context);

    controller.tabController.addListener(() {
      selectedIndex.value = controller.tabController.index;
    });

    final tabs = ["Catégories", "Sous-catégories"];

    return Obx(() {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: dark ? TColors.eerieBlack : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: List.generate(tabs.length, (i) {
            final isSelected = selectedIndex.value == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.tabController.animateTo(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.blue.shade600 : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      tabs[i],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    });
  }
}