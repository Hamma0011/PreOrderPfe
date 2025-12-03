import 'package:caferesto/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:caferesto/features/shop/screens/accueil/widgets/build_empty_state.dart';
import 'package:caferesto/utils/device/device_utility.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/layouts/grid_layout.dart';
import '../../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'widgets/home_categories.dart';
import '../../controllers/product/produit_controller.dart';
import '../../controllers/banner_controller.dart';
import '../voir_tout_produits/tout_produits_populaires.dart';
import '../categories/all_categories.dart';
import 'widgets/home_appbar.dart';
import 'widgets/promo_slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProduitController());
final bannerController = Get.find<BannerController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Charger les bannières une seule fois si nécessaire
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bannerController.loadPublishedBannersIfNeeded();
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Primary Header Container
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  /// AppBar
                  const THomeAppBar(),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// Catégories
                  TSectionHeading(
                      title: 'Catégories Populaires',
                      padding: EdgeInsets.all(0),
                      showActionButton: true,
                      whiteTextColor: true,
                      onPressed: () =>
                          Get.to(() => const AllCategoriesScreen())),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  /// Categories List
                  const THomeCategories(),
                  const SizedBox(height: AppSizes.spaceBtwItems),
                ],
              ),
            ),

            /// Corps
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: TDeviceUtils.getHorizontalPadding(screenWidth),
                vertical: AppSizes.defaultSpace,
              ),
              child: Column(
                children: [
                  /// -- PromoSlider avec cache - Ne se recharge pas à chaque rebuild
                  Obx(() {
                    final banners = bannerController.getPublishedBanners();

                    // Afficher un loader seulement si on charge initialement et qu'il n'y a pas de bannières
                    if (bannerController.isLoading.value && banners.isEmpty) {
                      return SizedBox(
                        height: TDeviceUtils.getPromoSliderHeight(
                            screenWidth, screenHeight),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    // Si pas de bannières, ne rien afficher
                    if (banners.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return TPromoSlider(
                      banners: banners,
                      height: TDeviceUtils.getPromoSliderHeight(
                          screenWidth, screenHeight),
                      autoPlay: true,
                      autoPlayInterval: 5000,
                    );
                  }),
                  const SizedBox(height: AppSizes.spaceBtwSections),

                  /// -- En tête
                  TSectionHeading(
                    title: 'Produits Populaires',
                    padding: EdgeInsets.all(0),
                    showActionButton: true,
                    onPressed: () => Get.to(() => ToutProduitsPopulaires(
                          title: 'Tout les produits populaires',
                          futureMethod: controller.fetchAllFeaturedProducts(),
                        )),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems),

                  /// Popular products avec GridLayout responsive
                  Obx(() {
                    if (controller.isLoading) {
                      return const TVerticalProductShimmer();
                    }
                    if (controller.featuredProducts.isEmpty) {
                      return BuildEmptyState();
                    }
                    return GridLayout(
                      itemCount: controller.featuredProducts.length,
                      itemBuilder: (_, index) => ProductCardVertical(
                        product: controller.featuredProducts[index],
                      ),
                      crossAxisCount:
                          TDeviceUtils.getCrossAxisCount(screenWidth),
                      mainAxisExtent:
                          TDeviceUtils.getMainAxisExtent(screenWidth),
                    );
                  })
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
