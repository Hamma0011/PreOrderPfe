import 'package:caferesto/features/shop/controllers/category_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class SearchAndFilterBar extends StatelessWidget {
  final CategoryController controller;
  const SearchAndFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: TextField(
              onChanged: controller.updateSearch,
              decoration: InputDecoration(
                hintText: "Rechercher une catégorie...",
                prefixIcon: const Icon(Iconsax.search_normal_1, size: 20),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: dark ? TColors.eerieBlack : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Filter Button
          Obx(() {
            final isFeatured =
                controller.selectedFilter.value == CategoryFilter.featured;
            return GestureDetector(
              onTap: () {
                controller.updateFilter(
                    isFeatured ? CategoryFilter.all : CategoryFilter.featured);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isFeatured ? Colors.amber.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: isFeatured
                          ? Colors.amber.shade800
                          : Colors.grey.shade600,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isFeatured ? "Vedettes" : "Toutes",
                      style: TextStyle(
                        color: isFeatured
                            ? Colors.amber.shade800
                            : Colors.grey.shade700,
                        fontWeight:
                            isFeatured ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}