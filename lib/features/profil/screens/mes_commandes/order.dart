import 'package:caferesto/common/widgets/appbar/appbar.dart';
import 'package:caferesto/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shop/controllers/commandes/order_controller.dart';
import 'widgets/order_list.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<OrderController>();

    return Scaffold(
      appBar: TAppBar(
        title: Row(
          children: [
            Text(
              'Mes commandes',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppSizes.defaultSpace),
        child: TOrderListItems(),
      ),
    );
  }
}
