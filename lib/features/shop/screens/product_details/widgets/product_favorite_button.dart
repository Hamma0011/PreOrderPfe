import 'package:caferesto/features/shop/controllers/product/favorites_controller.dart';
import 'package:caferesto/features/shop/models/produit_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductFavoriteButton extends StatelessWidget {
  const ProductFavoriteButton({
    super.key,
    required this.product,
    required this.dark,
  });

  final ProduitModel product;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final FavoritesController controller = Get.find<FavoritesController>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Obx(() {
          final isFav = controller.isFavourite(product.id);
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: dark ? Colors.grey.shade800 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: InkWell(
              onTap: () => controller
                  .toggleFavoriteProduct(product.id),
              child: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 18,
                color: isFav
                    ? Colors.red
                    : (dark ? Colors.grey.shade300 : Colors.grey.shade700),
              ),
            ),
          );
        }),
      ],
    );
  }
}
