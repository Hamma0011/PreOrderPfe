import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../shop/controllers/banner_controller.dart';
import '../../../../shop/models/banner_model.dart';
import '../widgets/image_placeholder.dart';
import '../widgets/image_preview.dart';
import '../widgets/local_image_preview.dart';
import 'image_comparison.dart';

class BuildImageSection extends StatelessWidget {
    final  BannerController controller;
    final bool isMobile;
    final BannerModel banner;
    final bool isAdminView;
  const BuildImageSection({super.key, required this.controller, required this.isAdminView,required this.isMobile,required this.banner});

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
            final hasPendingImage = banner.pendingChanges != null &&
                banner.pendingChanges!['image_url'] != null;

            // Si admin et modifications en attente, afficher les deux images
            if (isAdminView && hasPendingImage) {
              return ImageComparison(
                currentImageUrl: controller.imageUrl.value,
                pendingImageUrl: banner.pendingChanges!['image_url'].toString(),
              );
            }

            // Sinon, affichage normal
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
          if (!isAdminView)
            ElevatedButton.icon(
              onPressed: () => controller.pickImage(isMobile: isMobile),
              icon: const Icon(Iconsax.image),
              label: Text(
                  'Changer l\'image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
              ),
            ),
        ],
      ),
    );
  }
}