import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../models/notification_model.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({super.key, 
    required this.notification,
    required this.dark,
    required this.onTap,
  });

  final NotificationModel notification;
  final bool dark;
  final VoidCallback onTap;

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd MMM yyyy', 'fr').format(dateTime);
    } else if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  IconData _getNotificationIcon() {
    final title = notification.title.toLowerCase();
    if (title.contains('établissement') || title.contains('statut')) {
      return Iconsax.buildings;
    } else if (title.contains('commande') || title.contains('order')) {
      return Iconsax.shopping_cart;
    } else if (title.contains('produit')) {
      return Iconsax.box;
    } else if (title.contains('approuvé') || title.contains('accepté')) {
      return Iconsax.tick_circle;
    } else if (title.contains('rejeté') || title.contains('refusé')) {
      return Iconsax.close_circle;
    } else {
      return Iconsax.notification;
    }
  }

  Color _getIconColor() {
    final title = notification.title.toLowerCase();
    if (title.contains('approuvé') || title.contains('accepté')) {
      return TColors.success;
    } else if (title.contains('rejeté') || title.contains('refusé')) {
      return TColors.error;
    } else if (title.contains('commande')) {
      return TColors.primary;
    } else {
      return notification.read
          ? (dark ? Colors.grey.shade600 : Colors.grey.shade400)
          : TColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification.read;
    final iconColor = _getIconColor();
    final icon = _getNotificationIcon();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSizes.md),
          decoration: BoxDecoration(
            color: dark
                ? (isRead
                    ? TColors.darkContainer
                    : TColors.primary.withValues(alpha: 0.15))
                : (isRead
                    ? TColors.white
                    : TColors.primary.withValues(alpha: 0.08)),
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
            border: Border.all(
              color: isRead
                  ? Colors.transparent
                  : (dark
                      ? TColors.primary.withValues(alpha: 0.4)
                      : TColors.primary.withValues(alpha: 0.3)),
              width: isRead ? 0 : 1.5,
            ),
            boxShadow: isRead
                ? []
                : [
                    BoxShadow(
                      color: TColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Indicateur de notification non lue (barre verticale)
                if (!isRead)
                  Container(
                    width: 4,
                    margin: const EdgeInsets.only(right: AppSizes.md),
                    decoration: BoxDecoration(
                      color: TColors.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                // Icône de notification avec fond dégradé
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isRead
                          ? [
                              dark
                                  ? TColors.darkContainer
                                  : Colors.grey.shade100,
                              dark
                                  ? TColors.darkContainer
                                  : Colors.grey.shade50,
                            ]
                          : [
                              TColors.primary.withValues(alpha: 0.2),
                              TColors.primary.withValues(alpha: 0.1),
                            ],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSizes.borderRadiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                // Contenu de la notification
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre avec badge "Nouveau" si non lue
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: isRead
                                        ? FontWeight.w500
                                        : FontWeight.bold,
                                    fontSize: 16,
                                    color: isRead
                                        ? (dark
                                            ? Colors.grey.shade300
                                            : Colors.grey.shade700)
                                        : (dark
                                            ? Colors.white
                                            : Colors.black87),
                                    height: 1.3,
                                  ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: TColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Nouveau',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.sm / 2),
                      // Message
                      Text(
                        notification.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: dark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              fontSize: 14,
                              height: 1.4,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSizes.sm),
                      // Date avec icône
                      Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            size: 12,
                            color: dark
                                ? Colors.grey.shade600
                                : Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getTimeAgo(notification.createdAt),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: dark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
