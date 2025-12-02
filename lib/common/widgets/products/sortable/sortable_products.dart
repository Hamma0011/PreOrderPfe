import 'package:caferesto/common/widgets/layouts/grid_layout.dart';
import 'package:caferesto/common/widgets/products/product_cards/product_card_vertical.dart';
import 'package:caferesto/features/shop/controllers/product/all_products_controller.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../features/shop/controllers/product/produit_controller.dart';
import '../../../../features/shop/models/produit_model.dart';
import '../../../../utils/device/device_utility.dart';

class TSortableProducts extends StatelessWidget {
  const TSortableProducts({
    super.key,
    required this.products,
    this.useBrandContext = false,
  });

  final List<ProduitModel> products;
  final bool useBrandContext;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AllProductsController>();
    final productController = Get.find<ProduitController>();

    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        /// DropDown
        Obx(
          () => DropdownButtonFormField(
              decoration: const InputDecoration(prefixIcon: Icon(Iconsax.sort)),
              items: [
                'Nom',
                'Prix croissant',
                'Prix décroissant',
                'Récent',
                'Ventes',
              ]
                  .map((option) =>
                      DropdownMenuItem(value: option, child: Text(option)))
                  .toList(),
              value: controller.selectedSortOption.value,
              onChanged: (value) {
                if (value == null) return;
                if (useBrandContext) {
                  controller.sortBrandProducts(value);
                } else {
                  productController.sortProducts(value);
                }
              }),
        ),
        const SizedBox(height: AppSizes.spaceBtwSections),

        /// Products
        useBrandContext
            ? Obx(
                () => GridLayout(
                  itemCount: controller.filteredBrandProducts.length,
                  itemBuilder: (_, index) => ProductCardVertical(
                      product: controller.filteredBrandProducts[index]),
                  crossAxisCount: TDeviceUtils.getCrossAxisCount(screenWidth),
                  mainAxisExtent: TDeviceUtils.getMainAxisExtent(screenWidth),
                ),
              )
            : Obx(() => GridLayout(
                  itemCount: productController.featuredProducts.length,
                  itemBuilder: (_, index) => ProductCardVertical(
                      product: productController.featuredProducts[index]),
                  crossAxisCount: TDeviceUtils.getCrossAxisCount(screenWidth),
                  mainAxisExtent: TDeviceUtils.getMainAxisExtent(screenWidth),
                ))
      ],
    );
  }
}
