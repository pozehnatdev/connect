import 'package:connectapp/screens/notification/domain/entities/notification.dart';

abstract class NotificationRepo {
  Future<void> createNotification(Notificationn notification);
  Future<List<Notificationn>> fetchNotificationsForUser(String userId);

  Future<void> markNotificationAsRead(String notificationId);
  Future<void> acceptConnectRequest(String notificationId);
  Future<void> markAllNotificationsAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Future<int> getUnreadNotificationCount(String userId);
}
