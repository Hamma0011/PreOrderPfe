import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/notification_controller.dart';
import '../../../common/widgets/appbar/appbar.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import 'widgets/notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final dark = THelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? TColors.dark : TColors.light,
      appBar: TAppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notifications'),
            Obx(() {
              final unreadCount = controller.unreadCount;
              if (unreadCount == 0) {
                return const SizedBox.shrink();
              }
              return Text(
                '$unreadCount non lue${unreadCount > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: dark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
              );
            }),
          ],
        ),
        showBackArrow: true,
        actions: [
          // Bouton pour marquer toutes comme lues
          Obx(() {
            final unreadCount = controller.unreadCount;
            if (unreadCount == 0) {
              return const SizedBox.shrink();
            }
            return Tooltip(
              message: 'Marquer toutes comme lues',
              child: IconButton(
                icon: const Icon(Iconsax.tick_circle),
                onPressed: () => controller.markAllAsRead(),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: TColors.primary,
            ),
          );
        }

        final notifications = controller.notifications;

        if (notifications.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.defaultSpace * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: dark
                          ? TColors.darkContainer
                          : TColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.notification_bing,
                      size: 64,
                      color: dark
                          ? Colors.grey.shade600
                          : TColors.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwSections),
                  Text(
                    'Aucune notification',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dark ? Colors.white : Colors.black,
                        ),
                  ),
                  const SizedBox(height: AppSizes.spaceBtwItems / 2),
                  Text(
                    'Vous n\'avez pas encore de notifications.\nElles apparaîtront ici lorsqu\'elles arriveront.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: dark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshNotifications(),
          color: TColors.primary,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.defaultSpace,
                  vertical: AppSizes.spaceBtwItems,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final notification = notifications[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSizes.spaceBtwItems,
                        ),
                        child: NotificationItem(
                          notification: notification,
                          dark: dark,
                          onTap: () =>
                              controller.handleNotificationTap(notification),
                        ),
                      );
                    },
                    childCount: notifications.length,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
