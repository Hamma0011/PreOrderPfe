import 'dart:async';

import 'package:caferesto/data/repositories/notifications/notifications_repository.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../../profil/screens/gestion_etablissement/liste_etablissement/mon_etablissement_screen.dart';
import '../../profil/controllers/user_controller.dart';
import '../../profil/screens/gestion_commandes/gerant_order_management_screen.dart';
import '../../profil/screens/mes_commandes/order.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
    final notificationRepository = Get.find<NotificationsRepository>();

    final notifications = <NotificationModel>[].obs;
    final _isLoading = false.obs;
    RealtimeChannel? _channel;
    StreamSubscription<AuthState>? _authSubscription;

    int get unreadCount => notifications.where((n) => !n.read).length;
    bool get isLoading => _isLoading.value;

    @override
    void onInit() {
    super.onInit();
    _loadNotifications();
    _subscribeRealtime();

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (authState) async {
        final event = authState.event;
        final session = authState.session;

        if (event == AuthChangeEvent.signedIn && session?.user != null) {
          _resubscribeForUser(session!.user.id);
          await _loadNotifications();
        }

        if (event == AuthChangeEvent.initialSession && session?.user != null) {
          _resubscribeForUser(session!.user.id);
        }

        if (event == AuthChangeEvent.signedOut) {
          _unsubscribe();
          notifications.clear();
        }
      },
    );
  }

  @override
  void onClose() {
    if (_channel != null) {
      notificationRepository.unsubscribeFromNotifications(_channel!);
    }
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> _loadNotifications() async {
    _isLoading.value = true;
    try {
      final fetchedNotifications =
          await notificationRepository.fechUserNotifications();
      fetchedNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifications.value = fetchedNotifications;
    } catch (e) {
      debugPrint('Erreur chargement notifications: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// Exposer la méthode pour le rafraîchissement
  Future<void> refreshNotifications() async {
    await _loadNotifications();
  }

  void _subscribeRealtime() {
    final userId = notificationRepository.authRepo.authUser?.id ?? '';
    if (userId.isEmpty) {
      debugPrint('Cannot subscribe: user ID is empty');
      return;
    }

    _channel = notificationRepository.subscribeToNotifications(
      userId: userId,
      onNewNotification: (newNotif) {
        notifications.insert(0, newNotif);
        notifications.refresh();

        // Afficher une snackbar pour la nouvelle notification
        Get.snackbar(
          newNotif.title,
          newNotif.message,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withValues(alpha: 0.85),
          colorText: Colors.white,
        );
      },
    );
  }

  void _resubscribeForUser(String userId) {
    try {
      _unsubscribe();
      _channel = notificationRepository.subscribeToNotifications(
        userId: userId,
        onNewNotification: (newNotif) {
          notifications.insert(0, newNotif);
          notifications.refresh();
          Get.snackbar(
            newNotif.title,
            newNotif.message,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green.withValues(alpha: 0.85),
            colorText: Colors.white,
          );
        },
      );
    } catch (e) {
      debugPrint('Resubscribe error: $e');
    }
  }

  void _unsubscribe() {
    if (_channel != null) {
      notificationRepository.unsubscribeFromNotifications(_channel!);
      _channel = null;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await notificationRepository.markAsRead(id);

      // Mettre à jour localement
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(read: true);
        notifications.refresh();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de marquer la notification comme lue',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final unreadIds =
          notifications.where((n) => !n.read).map((n) => n.id).toList();

      if (unreadIds.isEmpty) return;

      await notificationRepository.markAllAsRead(unreadIds);

      // Mettre à jour localement
      for (var i = 0; i < notifications.length; i++) {
        if (!notifications[i].read) {
          notifications[i] = notifications[i].copyWith(read: true);
        }
      }
      notifications.refresh();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de marquer toutes les notifications comme lues',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Gère le tap sur une notification (business logic)
  void handleNotificationTap(NotificationModel notification) async {
    // Marquer comme lue
    await markAsRead(notification.id);

    // Déterminer la navigation selon le type de notification
    final titleLower = notification.title.toLowerCase();
    final messageLower = notification.message.toLowerCase();
    final isOrderNotification = titleLower.contains('commande') ||
        titleLower.contains('order') ||
        messageLower.contains('commande') ||
        messageLower.contains('order');

    if (isOrderNotification) {
      // Récupérer le rôle de l'utilisateur
      final userController = Get.find<UserController>();
      final userRole = userController.userRole;

      // Navigation selon le rôle
      if (userRole == 'Client') {
        Get.to(() => const OrderScreen());
      } else {
        Get.to(() => const GerantOrderManagementScreen());
      }
    } else if (notification.etablissementId != null) {
      Get.to(
        () => MonEtablissementScreen(),
        arguments: {'etablissementId': notification.etablissementId},
      );
    }
  }
}
