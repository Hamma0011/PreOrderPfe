import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../features/shop/controllers/product/panier_controller.dart';
import '../../../../../features/shop/models/produit_model.dart';
import '../../../../../features/shop/screens/product_details/product_detail.dart';
import '../../../../../utils/constants/colors.dart';

class ProductCardAddToCartButton extends StatelessWidget {
  const ProductCardAddToCartButton({
    super.key,
    required this.product,
  });

  final ProduitModel product;

  bool get isSingleProduct {
    return product.productType == 'single';
  }

  @override
  Widget build(BuildContext context) {
    final panierController = Get.find<PanierController>();

    return Obx(() {
      final productQuantityInCart =
          panierController.obtenirQuantiteProduitDansPanier(product.id);

      return Container(
        height: 32, // Slightly larger for detail page
        width: productQuantityInCart > 0 ? 80 : 32,
        decoration: BoxDecoration(
          color: productQuantityInCart > 0
              ? TColors.primary
              : TColors.dark.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(12), // Slightly larger radius
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: productQuantityInCart > 0
              ? _buildCounterWidget(
                  context, panierController, productQuantityInCart)
              : _buildAddButton(context, panierController),
        ),
      );
    });
  }

  Widget _buildAddButton(
      BuildContext context, PanierController panierController) {
    return GestureDetector(
      onTap: () => _handleAddToCart(panierController),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 18, // Slightly larger icon
          ),
        ),
      ),
    );
  }

  Widget _buildCounterWidget(
      BuildContext context, PanierController panierController, int quantity) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4), // More padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // DECREMENT BUTTON
          GestureDetector(
            onTap: () => _handleDecrement(panierController),
            child: Container(
              width: 24, // Slightly larger
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius:
                    BorderRadius.circular(8), // Slightly larger radius
              ),
              child: const Center(
                child: Icon(
                  Icons.remove_rounded,
                  color: Colors.white,
                  size: 14, // Slightly larger
                ),
              ),
            ),
          ),

          // QUANTITY
          Container(
            constraints: const BoxConstraints(minWidth: 20),
            child: Text(
              quantity.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ),

          // INCREMENT BUTTON
          GestureDetector(
            onTap: () => _handleIncrement(panierController),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddToCart(PanierController panierController) {
    // Vérifier si on peut ajouter ce produit
    if (!panierController.peutAjouterProduit(product)) return;

    // Pour les produits variables, rediriger vers la page de détail pour choisir la taille
    if (!isSingleProduct) {
      Get.to(() => ProductDetailScreen(product: product));
      return;
    }

    // Pour les produits simples, ajouter directement au panier
    if (isSingleProduct) {
      final cartItem = panierController.produitVersArticlePanier(product, 1);
      panierController.ajouterUnAuPanier(cartItem).catchError((error) {
        // L'erreur est déjà gérée dans ajouterUnAuPanier avec TLoaders
      });
    }
  }

  void _handleIncrement(PanierController panierController) {
    // Vérifier si on peut ajouter ce produit
    if (!panierController.peutAjouterProduit(product)) return;

    // Pour les produits variables, rediriger vers la page de détail pour choisir la taille
    if (!isSingleProduct) {
      Get.to(() => ProductDetailScreen(product: product));
      return;
    }

    // Pour les produits simples, ajouter directement au panier
    if (isSingleProduct) {
      final cartItem = panierController.produitVersArticlePanier(product, 1);
      panierController.ajouterUnAuPanier(cartItem).catchError((error) {
        // L'erreur est déjà gérée dans ajouterUnAuPanier avec TLoaders
      });
    }
  }

  void _handleDecrement(PanierController panierController) {
    if (isSingleProduct) {
      final cartItem = panierController.produitVersArticlePanier(product, 1);
      panierController.retirerUnDuPanier(cartItem);
    }
  }
}
