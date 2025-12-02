import 'package:caferesto/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/banner_management_controller.dart';

class BuildSearchBar extends StatelessWidget {
  final BannerManagementController controller;

  const BuildSearchBar({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.defaultSpace),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: controller.updateSearch,
              decoration: InputDecoration(
                hintText: "Rechercher une bannière...",
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
        ],
      ),
    );
  }
}
