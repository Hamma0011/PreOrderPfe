import 'package:caferesto/common/widgets/layouts/grid_layout.dart';
import 'package:caferesto/common/widgets/products/cart/cart_menu_icon.dart';
import 'package:caferesto/common/widgets/brands/etablissement_card.dart';
import 'package:caferesto/common/widgets/shimmer/store_shimmer.dart';
import 'package:caferesto/common/widgets/texts/section_heading.dart';
import 'package:caferesto/features/shop/controllers/etablissement_controller.dart';
import 'package:caferesto/features/shop/screens/etablissements/produits_etablissement.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/colors.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final etablissementController = Get.find<EtablissementController>();

    return Scaffold(
      appBar: TAppBar(
        showBackArrow: false,
        title: Text(
          'Établissements',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: const [
          TCartCounterIcon(
            iconColor: TColors.primary,
            counterBgColor: TColors.primary,
          )
        ],
      ),
      body: Obx(() {
        if (etablissementController.isLoading &&
            etablissementController.etablissements.isEmpty) {
          return const StoreShimmer();
        }

        final approved = etablissementController.etablissements;

        if (approved.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace),
              child: Text(
                'Aucun établissement approuvé',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TSectionHeading(title: 'Nos partenaires'),
              const SizedBox(height: AppSizes.spaceBtwItems),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 600 ? 1 : 2;
                  final mainAxisExtent =
                      constraints.maxWidth < 400 ? 90.0 : 80.0;

                  return GridLayout(
                    itemCount: approved.length,
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: mainAxisExtent,
                    itemBuilder: (_, index) {
                      final brand = approved[index];
                      return EtablissementCard(
                        showBorder: true,
                        brand: brand,
                        onTap: () => Get.to(
                          () => BrandProducts(brand: brand),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
