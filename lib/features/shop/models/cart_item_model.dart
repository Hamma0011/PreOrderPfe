import 'dart:convert';
import 'package:caferesto/features/shop/models/produit_model.dart';

class CartItemModel {
  String productId;
  String title;
  double price;
  String? image;
  int quantity;
  String variationId;
  String? brandName;
  ProductSizePrice? selectedVariation;
  String etablissementId;
  ProduitModel? product;
  String categoryId; // Ajout du categoryId pour faciliter l'affichage

  CartItemModel({
    required this.productId,
    required this.quantity,
    this.variationId = '',
    this.title = '',
    this.price = 0.0,
    this.image,
    this.brandName,
    this.selectedVariation,
    this.etablissementId = '',
    this.product,
    this.categoryId = '',
  });

  static CartItemModel empty() {
    return CartItemModel(productId: '', quantity: 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'image': image,
      'quantity': quantity,
      'variationId': variationId,
      'brandName': brandName,
      'selectedVariation': selectedVariation?.toMap(),
      'etablissementId': etablissementId,
      'categoryId': categoryId,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> data) {
    ProductSizePrice? selectedVariation;
    if (data['selectedVariation'] != null) {
      final variationData = data['selectedVariation'];
      if (variationData is Map<String, dynamic>) {
        // Si c'est déjà un Map, utiliser fromMap
        selectedVariation = ProductSizePrice.fromMap(variationData);
      } else if (variationData is String) {
        // Si c'est une chaîne JSON, parser d'abord
        try {
          final parsed =
              Map<String, dynamic>.from(json.decode(variationData) as Map);
          selectedVariation = ProductSizePrice.fromMap(parsed);
        } catch (e) {
          selectedVariation = null;
        }
      }
    }

    return CartItemModel(
      productId: data['productId'] ?? '',
      title: data['title'] ?? '',
      price: _parseDouble(data['price']),
      image: data['image'],
      quantity: data['quantity'] is int
          ? data['quantity']
          : int.tryParse(data['quantity']?.toString() ?? '1') ?? 1,
      variationId: data['variationId'] ?? '',
      brandName: data['brandName'],
      selectedVariation: selectedVariation,
      etablissementId: data['etablissementId'] ?? '',
      categoryId: data['categoryId'] ?? '',
    );
  }

  /// Helper function pour parser les doubles de manière sécurisée
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    return 0.0;
  }

  CartItemModel copyWith({
    String? productId,
    String? title,
    double? price,
    String? image,
    int? quantity,
    String? variationId,
    String? brandName,
    ProductSizePrice? selectedVariation,
    String? etablissementId,
    ProduitModel? product,
    String? categoryId,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      title: title ?? this.title,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
      variationId: variationId ?? this.variationId,
      brandName: brandName ?? this.brandName,
      selectedVariation: selectedVariation ?? this.selectedVariation,
      etablissementId: etablissementId ?? this.etablissementId,
      product: product ?? this.product,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
