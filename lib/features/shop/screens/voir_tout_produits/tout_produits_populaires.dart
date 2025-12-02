import 'package:flutter/material.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/products/sortable/sortable_products.dart';
import '../../../../common/widgets/shimmer/vertical_product_shimmer.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/cloud_helper_functions.dart';
import '../../models/produit_model.dart';

class ToutProduitsPopulaires extends StatelessWidget {
  const ToutProduitsPopulaires(
      {super.key, required this.title, this.futureMethod});

  final String title;
  final Future<List<ProduitModel>>? futureMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TAppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.all(AppSizes.defaultSpace),
        child: FutureBuilder(
            future: futureMethod,
            builder: (context, snapshot) {
              const loader = TVerticalProductShimmer();
              final widget = TCloudHelperFunctions.checkMultiRecordState(
                snapshot: snapshot,
                loader: loader,
              );

              if (widget != null) return widget;

              /// Afficher les produits s'il sont disponibles
              final products = snapshot.data!;
              return TSortableProducts(products: products);
            }),
      )),
    );
  }
}
