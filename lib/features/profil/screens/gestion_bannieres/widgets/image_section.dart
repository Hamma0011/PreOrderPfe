import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../shop/controllers/banner_controller.dart';
import 'image_placeholder.dart';
import 'image_preview.dart';
import 'local_image_preview.dart';
class ImageSection extends StatelessWidget {
  final BannerController controller;
  final bool isMobile;
  const ImageSection(
      {super.key, required this.controller, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    
    final dark = THelperFunctions.isDarkMode(context);

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: dark ? TColors.darkContainer : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image de la bannière',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSizes.spaceBtwItems),
          Obx(() {
            final pickedImage = controller.pickedImage.value;
            if (pickedImage != null) {
              return LocalImagePreview(imageFile: pickedImage);
            } else if (controller.imageUrl.value.isNotEmpty) {
              return ImagePreview(imageUrl: controller.imageUrl.value);
            } else {
              return ImagePlaceholder(
                  controller: controller, isMobile: isMobile);
            }
          }),
          const SizedBox(height: AppSizes.spaceBtwItems),
          ElevatedButton.icon(
            onPressed: () => controller.pickImage(isMobile: isMobile),
            icon: const Icon(Iconsax.image),
            label: Text(isMobile
                ? 'Sélectionner une image (Mobile)'
                : 'Sélectionner une image'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
            ),
          ),
        ],
      ),
    );
  }
}