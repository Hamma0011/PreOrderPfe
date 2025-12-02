import 'package:caferesto/data/repositories/authentication/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/notification/models/notification_model.dart';

class NotificationsRepository extends GetxController {
  final _db = Supabase.instance.client;
  final authRepo = Get.find<AuthenticationRepository>();

  Future<List<NotificationModel>> fechUserNotifications() async {
    try {
      final user = authRepo.authUser;
      if (user == null || user.id.isEmpty) {
        throw 'Impossible de trouver les infromations de l\'utilisateur, essayer ultérieurememnt';
      }

      final response = await _db
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) =>
              NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw 'Erreur lors de la récupération des notifications: $e, essayer ultérieurememnt';
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _db
          .from('notifications')
          .update({'read': true}).eq('id', notificationId);
    } catch (e) {
      throw 'Erreur lors du marquage notification: $e, essayer ultérieurememnt';
    }
  }

  Future<void> markAllAsRead(List<String> notificationIds) async {
    try {
      if (notificationIds.isEmpty) return;

      await _db
          .from('notifications')
          .update({'read': true}).inFilter('id', notificationIds);
    } catch (e) {
      throw 'Erreur du marquage de tout les notifications: $e, essayer ultérieurememnt';
    }
  }

  RealtimeChannel subscribeToNotifications({
    required String userId,
    required Function(NotificationModel) onNewNotification,
  }) {
    final channel = _db.channel('public:notifications_user_$userId');

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        final newNotification = NotificationModel.fromJson(payload.newRecord);
        onNewNotification(newNotification);
      },
    );
    channel.subscribe();

    return channel;
  }

  void unsubscribeFromNotifications(RealtimeChannel channel) {
    try {
      _db.removeChannel(channel);
    } catch (e) {
      debugPrint('Erreur lors de la désinscription des notifications: $e');
    }
  }
}
