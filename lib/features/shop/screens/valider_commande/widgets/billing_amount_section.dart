import 'package:caferesto/utils/helpers/pricing_calculator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/product/panier_controller.dart';

class TBillingAmountSection extends StatelessWidget {
  const TBillingAmountSection({super.key});

  String _formatPreparationTime(int minutes) {
    if (minutes == 0) {
      return 'Prêt immédiatement';
    } else if (minutes == 1) {
      return '1 minute';
    } else {
      return '$minutes minutes';
    }
  }

  @override
  Widget build(BuildContext context) {
    final panierController = Get.find<PanierController>();
    
    final subTotal = panierController.totalCartPrice.value;
    final preparationTime = panierController.calculerTempsPreparation();
    return Column(
      children: [
        /// Subtotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sous total',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$subTotal DT',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(
          height: AppSizes.spaceBtwItems / 2,
        ),

        const SizedBox(
          height: AppSizes.spaceBtwItems / 2,
        ),

        const SizedBox(
          height: AppSizes.spaceBtwItems / 2,
        ),

        /// Temps de préparation
        if (preparationTime > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Temps de préparation',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Text(
                _formatPreparationTime(preparationTime),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        if (preparationTime > 0)
          const SizedBox(
            height: AppSizes.spaceBtwItems / 2,
          ),

        /// Order total fee
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              '${TPricingCalculator.calculateTotalPrice(subTotal, 'tn')} DT',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ],
    );
  }
}
