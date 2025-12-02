import 'package:caferesto/features/shop/controllers/product/panier_controller.dart';
import 'package:caferesto/features/shop/models/produit_model.dart';
import 'package:caferesto/features/shop/screens/panier/cart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/product_bottom_bar.dart';

class ProductDetailBottomBarWrapper extends StatelessWidget {
  const ProductDetailBottomBarWrapper({
    super.key,
    required this.product,
    required this.dark,
    required this.isSmallScreen,
    this.onVariationSelected,
  });

  final ProduitModel product;
  final bool dark;
  final bool isSmallScreen;
  final VoidCallback? onVariationSelected;

  void _handleMainAction(PanierController controller) {
    if (!controller.peutAjouterProduit(product)) return;

    if (product.productType == 'variable') {
      final hasSelectedVariant = controller.aVarianteSelectionnee();
      if (!hasSelectedVariant) {
        Get.snackbar(
          'Sélection requise',
          'Veuillez choisir une variante avant de continuer',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Si c'est une modification (mode édition), appeler le callback
      if (onVariationSelected != null) {
        onVariationSelected!();
        return;
      }

      // Vérifier si la variation SPÉCIFIQUE est dans le panier (pour le mode ajout)
      final selectedSize = controller.variationController.selectedSize.value;
      if (selectedSize.isNotEmpty) {
        final variationQuantity = controller.obtenirQuantiteVariationDansPanier(
            product.id, selectedSize);
        if (variationQuantity > 0) {
          // Cette variation spécifique est déjà dans le panier, naviguer vers le panier
          Get.to(() => const CartScreen());
          return;
        }
      }
    } else {
      // Pour les produits simples, vérifier si le produit est dans le panier
      final quantity = controller.obtenirQuantiteProduitDansPanier(product.id);
      if (quantity > 0) {
        Get.to(() => const CartScreen());
        return;
      }
    }

    // Ajouter un nouvel article (soit une nouvelle variation soit un nouveau produit)
    // Utiliser ajouterAuPanier qui gère la logique correctement
    controller.ajouterAuPanier(product).catchError((error) {
      // L'erreur est déjà gérée dans ajouterAuPanier avec TLoaders
    });
  }

  Future<void> _handleIncrement(PanierController controller) async {
    if (!controller.peutAjouterProduit(product)) return;
    if (product.productType == 'single' || controller.aVarianteSelectionnee()) {
      // Obtenir la quantité temporaire actuelle
      final currentQuantity = controller.obtenirQuantiteTemporaire(product);
      final nouvelleQuantite = currentQuantity + 1;

      // Vérifier le stock disponible si le produit est stockable
      if (product.isStockable) {
        final stockDisponible = await controller.obtenirStockDisponible(product.id);
        final quantiteDansPanier = controller.obtenirQuantiteProduitDansPanier(product.id);
        final quantiteTotale = quantiteDansPanier + nouvelleQuantite;

        if (quantiteTotale > stockDisponible) {
          // Afficher un message d'erreur
          Get.snackbar(
            'Stock insuffisant',
            stockDisponible == 0
                ? 'Stock disponible: 0 article. Ce produit est actuellement hors stock.'
                : 'Stock disponible: $stockDisponible article${stockDisponible > 1 ? 's' : ''}. Vous avez déjà $quantiteDansPanier dans votre panier. Quantité demandée: $nouvelleQuantite.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
          return;
        }
      }

      // Si le stock est suffisant, incrémenter la quantité temporaire
      controller.mettreAJourQuantiteTemporaire(product, nouvelleQuantite);
    }
  }

  void _handleDecrement(PanierController controller) {
    if (product.productType == 'single' || controller.aVarianteSelectionnee()) {
      // Obtenir la quantité temporaire actuelle et la décrémenter
      final currentQuantity = controller.obtenirQuantiteTemporaire(product);
      if (currentQuantity > 0) {
        controller.mettreAJourQuantiteTemporaire(product, currentQuantity - 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use safe instance getter
    final controller = Get.find<PanierController>();

    return ProductBottomBar(
      product: product,
      dark: dark,
      isSmallScreen: isSmallScreen,
      onIncrement: () {
        _handleIncrement(controller).catchError((error) {
          // L'erreur est déjà gérée dans _handleIncrement avec Get.snackbar
        });
      },
      onDecrement: () => _handleDecrement(controller),
      onMainAction: () => _handleMainAction(controller),
    );
  }
}
