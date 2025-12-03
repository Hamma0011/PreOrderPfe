import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../utils/popups/loaders.dart';
import '../../models/cart_item_model.dart';
import '../../models/produit_model.dart';
import 'variation_controller.dart';

class PanierController extends GetxController {
  RxInt cartItemsCount = 0.obs;
  RxDouble totalCartPrice = 0.0.obs;
  final RxMap<String, int> tempQuantityMap = <String, int>{}.obs;
  RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  // ID de la commande en cours de modification (null si nouvelle commande)
  final RxString editingOrderId = ''.obs;

  // Accès à la base de données Supabase
  final _db = Supabase.instance.client;

  // Obtenir VariationController depuis l'injection de dépendance GetX
  VariationController get variationController =>
      Get.find<VariationController>();

  PanierController() {
    chargerArticlesPanier();
  }

  /// Vérifie le stock disponible d'un produit depuis la base de données
  Future<int> obtenirStockDisponible(String productId) async {
    try {
      final productResponse = await _db
          .from('produits')
          .select('est_stockable, quantite_stock')
          .eq('id', productId)
          .single();

      final isStockable = productResponse['est_stockable'] as bool? ?? false;
      if (!isStockable) {
        // Produit non stockable, retourner une valeur élevée pour permettre l'ajout
        return 999999;
      }

      final stock = (productResponse['quantite_stock'] as num?)?.toInt() ?? 0;
      return stock;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du stock: $e');
      // En cas d'erreur, retourner 0 pour bloquer l'ajout
      return 0;
    }
  }

  /// Vérifie le stock disponible d'une variation spécifique depuis la base de données
  Future<int> obtenirStockDisponibleVariation(String productId, String variationId) async {
    try {
      final productResponse = await _db
          .from('produits')
          .select('product_type, est_stockable, tailles_prix')
          .eq('id', productId)
          .single();

      final isStockable = productResponse['est_stockable'] as bool? ?? false;
      final productType = productResponse['product_type']?.toString() ?? '';
      if (!isStockable || productType != 'variable') return 999999;

      final raw = productResponse['tailles_prix'];
      List<dynamic> taillesList;
      if (raw is String) {
        taillesList = (json.decode(raw) as List).toList();
      } else if (raw is List) {
        taillesList = raw.toList();
      } else {
        taillesList = json.decode(json.encode(raw)) as List<dynamic>;
      }
      for (final e in taillesList) {
        final m = Map<String, dynamic>.from(e as Map);
        final taille = m['taille']?.toString() ?? '';
        final id = m['id']?.toString() ?? '';
        if (taille == variationId || id == variationId) {
          final current = (m['stock'] is num)
              ? (m['stock'] as num).toInt()
              : int.tryParse('${m['stock']}') ?? 0;
          return current;
        }
      }
      return 0;
    } catch (e) {
      debugPrint('Erreur lors de la récupération du stock variation: $e');
      return 0;
    }
  }

  /// Vérifie si la quantité demandée est disponible en stock
  Future<bool> verifierStockDisponible(
      String productId, int quantiteDemandee) async {
    final stockDisponible = await obtenirStockDisponible(productId);

    // Si le produit n'est pas stockable, toujours autoriser
    if (stockDisponible >= 999999) {
      return true;
    }

    // Vérifier la quantité déjà dans le panier pour ce produit
    final quantiteDansPanier = obtenirQuantiteProduitDansPanier(productId);
    final quantiteTotale = quantiteDansPanier + quantiteDemandee;

    return quantiteTotale <= stockDisponible;
  }

  /// Vérifie si une variante est dans le panier
  bool estVariationDansPanier(String productId, String variationId) {
    return cartItems.any((item) =>
        item.productId == productId &&
        item.variationId == variationId &&
        item.variationId.isNotEmpty);
  }

  /// Met à jour la variante d'un produit dans le panier
  void mettreAJourVariation(String productId, String newSize, double newPrice) {
    int index = cartItems.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final produit = cartItems[index].product;
      final sp = produit?.sizesPrices.firstWhereOrNull((e) => e.size == newSize);
      cartItems[index] = cartItems[index].copyWith(
        selectedVariation:
            sp ?? ProductSizePrice(id: '${DateTime.now().millisecondsSinceEpoch}', size: newSize, price: newPrice, stock: 0),
        price: newPrice,
      );
    }
    mettreAJourTotauxPanier();
  }

  /// Vérifie si un produit peut être ajouté au panier
  bool peutAjouterProduit(ProduitModel product) {
    // Si le panier est vide, tout est autorisé
    if (cartItems.isEmpty) return true;

    // Récupère l'établissement du premier produit du panier
    final currentEtablissementId = cartItems.first.etablissementId;
    // Vérifie si l'établissement du produit correspond
    if (product.etablissementId == currentEtablissementId) {
      return true;
    } else {
      // Refuser si ce n'est pas le même établissement
      TLoaders.customToast(
        message:
            "Vous ne pouvez pas ajouter des produits de plusieurs établissements.",
      );
      return false;
    }
  }

  /// Vérifie si une variante est sélectionnée
  bool aVarianteSelectionnee() {
    final variation = variationController.selectedVariation.value;
    return variation != null;
  }

  /// Obtient la clé unique d'un produit (ID + variante)
  String _obtenirCle(ProduitModel product) {
    final variation = variationController.selectedVariation.value;
    final variationId = product.isVariable && variation != null
        ? variation.size // ✅ Accéder directement à .size
        : "";
    return '${product.id}-$variationId';
  }

  /// Met à jour la quantité temporaire d'un produit
  void mettreAJourQuantiteTemporaire(ProduitModel product, int quantity) {
    final key = _obtenirCle(product);
    if (quantity <= 0) {
      tempQuantityMap.remove(key); // Supprimer l'entrée quand la quantité est 0
    } else {
      tempQuantityMap[key] = quantity;
    }
  }

  /// Obtient la quantité temporaire d'un produit
  int obtenirQuantiteTemporaire(ProduitModel product) {
    final key = _obtenirCle(product);
    // Utiliser la quantité temporaire si elle existe, sinon utiliser la quantité réelle du panier
    final tempQuantity = tempQuantityMap[key];
    if (tempQuantity != null) {
      return tempQuantity;
    }
    // Si aucune quantité temporaire, obtenir la quantité existante du panier
    return obtenirQuantiteExistante(product);
  }

  /// Obtient la quantité existante d'un produit dans le panier
  int obtenirQuantiteExistante(ProduitModel product) {
    if (product.isSingle) {
      return obtenirQuantiteProduitDansPanier(product.id);
    } else {
      final variation = variationController.selectedVariation.value;
      final variationId = variation?.size ?? '';
      // Pour les produits variables, retourner la quantité seulement si une variante est sélectionnée
      if (variationId.isEmpty) {
        // Aucune variante sélectionnée, retourner 0 (pas dans le panier)
        return 0;
      }
      return obtenirQuantiteVariationDansPanier(product.id, variationId);
    }
  }

  /// Réinitialise la quantité temporaire d'un produit (utile lors de la navigation pour ajouter une nouvelle variante)
  void reinitialiserQuantiteTemporaireProduit(String productId) {
    // Supprimer toutes les quantités temporaires pour ce produit (peu importe la variante)
    tempQuantityMap.removeWhere((key, value) => key.startsWith('$productId-'));
  }

  // --- Ajouter / Retirer du panier -----------------------------------------------

  /// Modifie la variante d'un produit dans le panier
  void modifierVariationPanier(String productId, int currentIndex) {
    final variation = variationController.selectedVariation.value;
    if (variation == null || variation.size.isEmpty) {
      TLoaders.customToast(message: 'Veuillez choisir une variante');
      return;
    }

    // Obtenir la taille sélectionnée (l'ID de variation est basé sur la taille)
    final selectedSize = variationController.selectedSize.value;
    if (selectedSize.isEmpty) {
      TLoaders.customToast(message: 'Veuillez choisir une variante');
      return;
    }

    // Vérifier si la nouvelle variante est déjà dans le panier (excluding current item)
    final existingIndex = cartItems.indexWhere((item) =>
        item.productId == productId &&
        item.variationId == selectedSize &&
        cartItems.indexOf(item) != currentIndex);

    if (existingIndex >= 0) {
      TLoaders.customToast(
          message: 'Cette variante est déjà dans votre panier');
      return;
    }

    // Mettre à jour la variante existante
    final item = cartItems[currentIndex];
    final product = item.product;

    if (product == null) {
      TLoaders.customToast(message: 'Produit introuvable');
      return;
    }

    // Utiliser directement ProductSizePrice
    final price = variation.price;

    // Obtenir la quantité temporaire (l'utilisateur peut l'avoir modifiée)
    final tempQuantity = obtenirQuantiteTemporaire(product);
    final finalQuantity = tempQuantity > 0 ? tempQuantity : item.quantity;

    cartItems[currentIndex] = item.copyWith(
      variationId: selectedSize,
      price: price,
      quantity: finalQuantity, // Update quantity if changed
      selectedVariation: variation,
      // Keep existing image if variation doesn't have one
      image: item.image,
    );

    // Réinitialiser la quantité temporaire après modification
    mettreAJourQuantiteTemporaire(product, 0);
    mettreAJourPanier();
    TLoaders.customToast(message: 'Variante modifiée avec succès');
    Get.back(); // Retourner à l'écran précédent
  }

  /// Ajoute un produit au panier
  Future<void> ajouterAuPanier(ProduitModel product) async {
    if (!peutAjouterProduit(product)) return;

    final quantity = obtenirQuantiteTemporaire(product);

    // Vérifications de base
    if (product.isVariable) {
      final variation = variationController.selectedVariation.value;
      if (variation == null || variation.size.isEmpty) {
        TLoaders.customToast(message: 'Veuillez choisir une variante');
        return;
      }
    } else if (product.isStockable && product.stockQuantity < 1) {
      // Vérifier le stock uniquement pour les produits stockables
      TLoaders.errorSnackBar(
        title: 'Stock insuffisant',
        message:
            'Stock disponible: 0 article. Ce produit est actuellement hors stock.',
      );
      return;
    }

    // Si la quantité est 0, par défaut mettre 1 pour les nouveaux articles
    final quantityToAdd = quantity > 0 ? quantity : 1;

    // Vérifier le stock disponible depuis la base de données
    if (product.isStockable) {
      if (product.isVariable) {
        final variation = variationController.selectedVariation.value;
        final variationId = variation?.size ?? '';
        final stockDisponibleVar =
            await obtenirStockDisponibleVariation(product.id, variationId);
        final quantiteDansPanierVar =
            obtenirQuantiteVariationDansPanier(product.id, variationId);
        final quantiteTotaleVar = quantiteDansPanierVar + quantityToAdd;
        if (quantiteTotaleVar > stockDisponibleVar) {
          TLoaders.errorSnackBar(
            title: 'Stock insuffisant',
            message: stockDisponibleVar == 0
                ? 'Cette taille est hors stock.'
                : 'Stock disponible pour cette taille: $stockDisponibleVar. Vous avez déjà $quantiteDansPanierVar dans votre panier. Quantité demandée: $quantityToAdd.',
          );
          return;
        }
      } else {
        final stockDisponible = await obtenirStockDisponible(product.id);
        final quantiteDansPanier = obtenirQuantiteProduitDansPanier(product.id);
        final quantiteTotale = quantiteDansPanier + quantityToAdd;
        if (quantiteTotale > stockDisponible) {
          TLoaders.errorSnackBar(
            title: 'Stock insuffisant',
            message: stockDisponible == 0
                ? 'Stock disponible: 0 article. Ce produit est actuellement hors stock.'
                : 'Stock disponible: $stockDisponible article${stockDisponible > 1 ? 's' : ''}. Vous avez déjà $quantiteDansPanier dans votre panier. Quantité demandée: $quantityToAdd.',
          );
          return;
        }
      }
    }

    final selectedCartItem = produitVersArticlePanier(product, quantityToAdd);

    // Vérifier si la variante existe déjà
    final existingIndex = cartItems.indexWhere((item) =>
        item.productId == selectedCartItem.productId &&
        item.variationId == selectedCartItem.variationId);

    if (existingIndex >= 0) {
      // La variante existe déjà, ne rien faire
      TLoaders.customToast(
          message: 'Cette variante est déjà dans votre panier');
      return;
    }

    // Ajouter la nouvelle variante
    cartItems.add(selectedCartItem);
    TLoaders.customToast(message: 'Produit ajouté au panier');

    // Réinitialiser la quantité temporaire après avoir ajouté avec succès au panier
    mettreAJourQuantiteTemporaire(product, 0);
    mettreAJourPanier();
  }

  /// Convertit un produit en article de panier
  CartItemModel produitVersArticlePanier(ProduitModel product, int quantity) {
    if (product.isSingle) {
      variationController.resetSelectedAttributes();
    }

    final variation = variationController.selectedVariation.value;
    final isVariation = variation != null && variation.size.isNotEmpty;

    // Get price from variation or product
    final price = isVariation
        ? variation.price
        : (product.salePrice > 0.0 ? product.salePrice : product.price);

    return CartItemModel(
      productId: product.id,
      title: product.name,
      price: price,
      image: product
          .imageUrl, // Use product image (variation doesn't have separate image)
      quantity: quantity,
      variationId: isVariation ? variation.size : '',
      brandName: product.etablissement?.name ?? 'Inconnu',
      selectedVariation: variation,
      etablissementId: product.etablissementId,
      product: product,
      categoryId: product.categoryId, // Stocker le categoryId
    );
  }

  // --- Gestion du panier -------------------------------------------------------

  /// Met à jour le panier (totaux, sauvegarde, rafraîchissement)
  void mettreAJourPanier() {
    mettreAJourTotauxPanier();
    sauvegarderArticlesPanier();
    cartItems.refresh();
  }

  /// Ajoute un article au panier (ou augmente la quantité si déjà présent)
  Future<void> ajouterUnAuPanier(CartItemModel item) async {
    final index = cartItems.indexWhere((cartItem) =>
        cartItem.productId == item.productId &&
        cartItem.variationId == item.variationId);

    if (index >= 0) {
      // Vérifier le stock avant d'augmenter la quantité
      final product = item.product;
      if (product != null && product.isStockable) {
        final quantiteActuelle = cartItems[index].quantity;
        final nouvelleQuantite = quantiteActuelle + 1;
        if (product.isVariable) {
          final variationId = cartItems[index].variationId;
          final stockDisponibleVar =
              await obtenirStockDisponibleVariation(item.productId, variationId);
          if (nouvelleQuantite > stockDisponibleVar) {
            TLoaders.errorSnackBar(
              title: 'Stock insuffisant',
              message: stockDisponibleVar == 0
                  ? 'Cette taille est hors stock.'
                  : 'Stock disponible pour cette taille: $stockDisponibleVar. Vous avez déjà $quantiteActuelle dans votre panier. Quantité demandée: $nouvelleQuantite.',
            );
            return;
          }
        } else {
          final stockDisponible = await obtenirStockDisponible(item.productId);
          if (nouvelleQuantite > stockDisponible) {
            TLoaders.errorSnackBar(
              title: 'Stock insuffisant',
              message: stockDisponible == 0
                  ? 'Stock disponible: 0 article. Ce produit est actuellement hors stock.'
                  : 'Stock disponible: $stockDisponible article${stockDisponible > 1 ? 's' : ''}. Vous avez déjà $quantiteActuelle dans votre panier. Quantité demandée: $nouvelleQuantite.',
            );
            return;
          }
        }
      }

      // Créer une nouvelle instance pour déclencher la réactivité
      cartItems[index] = cartItems[index].copyWith(
        quantity: cartItems[index].quantity + 1,
      );
    } else {
      cartItems.add(item);
    }
    mettreAJourPanier();
  }

  /// Retire un article du panier (ou diminue la quantité si supérieure à 1)
  void retirerUnDuPanier(CartItemModel item) {
    final index = cartItems.indexWhere((cartItem) =>
        cartItem.productId == item.productId &&
        cartItem.variationId == item.variationId);

    if (index >= 0) {
      if (cartItems[index].quantity > 1) {
        // Créer une nouvelle instance pour déclencher la réactivité
        cartItems[index] = cartItems[index].copyWith(
          quantity: cartItems[index].quantity - 1,
        );
      } else {
        dialogRetirerDuPanier(index);
        return;
      }
      mettreAJourPanier();
    }
  }

  /// Affiche un dialogue de confirmation pour retirer un article du panier
  void dialogRetirerDuPanier(int index) {
    Get.defaultDialog(
      title: 'Confirmation',
      middleText: 'Voulez-vous vraiment supprimer ce produit du panier?',
      textConfirm: 'Oui',
      textCancel: 'Non',
      onConfirm: () {
        cartItems.removeAt(index);
        mettreAJourPanier();
        TLoaders.customToast(message: 'Produit supprimé du panier');
        Get.back();
      },
      onCancel: () => Get.back(),
    );
  }

  // --- Totaux et stockage ------------------------------------------------------

  /// Met à jour les totaux du panier (prix total et nombre d'articles)
  void mettreAJourTotauxPanier() {
    double calculatedTotalPrice = 0.0;
    int calculatedcartItemsCount = 0;
    for (var item in cartItems) {
      calculatedTotalPrice += (item.price) * item.quantity.toDouble();
      calculatedcartItemsCount += item.quantity;
    }
    totalCartPrice.value = calculatedTotalPrice;
    cartItemsCount.value = calculatedcartItemsCount;
  }

  /// Calcule le temps de préparation total de la commande
  /// Les produits de catégories différentes peuvent être préparés en parallèle
  /// Retourne le temps maximum entre les catégories (car les catégories sont préparées en parallèle)
  int calculerTempsPreparation() {
    // Grouper les produits par catégorie
    final Map<String, int> timeByCategory = {};

    for (var item in cartItems) {
      final product = item.product;
      if (product != null && product.categoryId.isNotEmpty) {
        // Pour chaque catégorie, additionner les temps de préparation
        // (produits de la même catégorie sont préparés séquentiellement)
        final categoryTime = product.preparationTime * item.quantity;
        timeByCategory[product.categoryId] =
            (timeByCategory[product.categoryId] ?? 0) + categoryTime;
      }
    }

    // Si aucune catégorie trouvée, retourner 0
    if (timeByCategory.isEmpty) return 0;

    // Retourner le maximum entre les catégories
    // (car les catégories différentes sont préparées en parallèle)
    return timeByCategory.values.reduce((a, b) => a > b ? a : b);
  }

  /// Sauvegarde les articles du panier dans le stockage local
  void sauvegarderArticlesPanier() async {
    final cartItemStrings = cartItems.map((item) => item.toJson()).toList();
    await GetStorage().write('cartItems', cartItemStrings);
  }

  /// Charge les articles du panier depuis le stockage local
  void chargerArticlesPanier() async {
    final cartItemStrings = GetStorage().read<List<dynamic>>('cartItems');
    if (cartItemStrings != null) {
      cartItems.assignAll(cartItemStrings
          .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>)));
      mettreAJourTotauxPanier();
    }
  }

  // --- Obtenir les quantités --------------------------------------------------------

  /// Obtient la quantité totale d'un produit dans le panier (toutes variations confondues)
  int obtenirQuantiteProduitDansPanier(String productId) {
    return cartItems
        .where((item) => item.productId == productId)
        .fold(0, (sum, el) => sum + el.quantity);
  }

  /// Obtient la quantité d'une variation spécifique d'un produit dans le panier
  int obtenirQuantiteVariationDansPanier(String productId, String variationId) {
    final foundItem = cartItems.firstWhereOrNull(
      (item) => item.productId == productId && item.variationId == variationId,
    );
    return foundItem?.quantity ?? 0;
  }

  /// Vide le panier
  void viderPanier() {
    tempQuantityMap.clear();
    cartItems.clear();
    editingOrderId.value = '';
    mettreAJourPanier();
  }

  /// Charge les articles d'une commande dans le panier pour modification
  void chargerArticlesCommandeDansPanier(
      List<CartItemModel> orderItems, String orderId) {
    viderPanier();
    cartItems.addAll(orderItems);
    editingOrderId.value = orderId;
    mettreAJourPanier();
  }

  /// Obtient la quantité d'un produit dans le panier (première occurrence)
  int obtenirQuantiteProduit(String productId) {
    final item = cartItems.firstWhereOrNull((e) => e.productId == productId);
    return item?.quantity ?? 0;
  }

  /// Obtient tous les IDs de variations d'un produit qui sont dans le panier
  List<String> obtenirVariationsDansPanier(String productId) {
    return cartItems
        .where((item) =>
            item.productId == productId && item.variationId.isNotEmpty)
        .map((item) => item.variationId)
        .toList();
  }

  /// Vérifie si toutes les variations d'un produit sont dans le panier
  bool sontToutesVariationsDansPanier(ProduitModel product) {
    final allVariationIds = product.sizesPrices.map((sp) => sp.size).toSet();
    final cartVariationIds = cartItems
        .where((item) => item.productId == product.id)
        .map((item) => item.variationId)
        .toSet();

    return allVariationIds.difference(cartVariationIds).isEmpty;
  }

  /// Obtient un Set des IDs de variations d'un produit dans le panier (pour la performance)
  Set<String> obtenirVariationsDansPanierSet(String productId) {
    return cartItems
        .where((item) =>
            item.productId == productId && item.variationId.isNotEmpty)
        .map((item) => item.variationId)
        .toSet();
  }
}
