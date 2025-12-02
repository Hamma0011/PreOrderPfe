import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../shop/controllers/banner_controller.dart';

class ImagePlaceholder extends StatelessWidget {
  final BannerController controller;
  final bool isMobile;
  const ImagePlaceholder(
      {super.key, required this.controller, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: dark ? TColors.dark : Colors.grey[200],
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(
          color: dark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.image,
            size: 64,
            color: dark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Text(
            isMobile
                ? 'Taille recommandée: 1200x800px '
                : 'Taille recommandée: 1920x1080px',
            style: TextStyle(
              color: dark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
