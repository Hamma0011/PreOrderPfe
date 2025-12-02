import 'package:caferesto/features/profil/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/products/cart/cart_menu_icon.dart';
import '../../../../../common/widgets/shimmer/shimmer_effect.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../notification/screens/show_notifications.dart';
import 'search_overlay.dart';

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    return TAppBar(
      centerTitle: false,
      showBackArrow: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => userController.profileLoading.value
              ? const TShimmerEffect(width: 80, height: 15)
              : Text(TTexts.homeAppbarSubTitle,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .apply(color: TColors.grey))),
          Obx(() => userController.profileLoading.value
              ? const TShimmerEffect(width: 80, height: 15)
              : Text(userController.user.value.fullName,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall!
                      .apply(color: TColors.grey))),
        ],
      ),
      actions: [
        const NotificationBell(),
        IconButton(
          icon: const Icon(Iconsax.search_normal_1, color: Colors.white),
          onPressed: () {
            Get.to(() => const SearchOverlay(),
                transition: Transition.rightToLeft,
                duration: const Duration(milliseconds: 300));
          },
        ),
        TCartCounterIcon(
          counterBgColor: TColors.black,
          counterTextColor: TColors.white,
          iconColor: TColors.white,
        ),
      ],
    );
  }
}
