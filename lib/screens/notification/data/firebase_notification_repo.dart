import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/screens/notification/domain/entities/notification.dart';
import 'package:connectapp/screens/notification/domain/repos/notification_repos.dart';

class FirebaseNotificationRepo implements NotificationRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference notificationsCollection =
      FirebaseFirestore.instance.collection('notifications');

  @override
  Future<void> createNotification(Notificationn notification) async {
    try {
      await notificationsCollection
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      throw Exception("Error creating notification: $e");
    }
  }

  @override
  Future<List<Notificationn>> fetchNotificationsForUser(String userId) async {
    try {
      final notificationsSnapshot = await notificationsCollection
          .where('userId', whereIn: [userId, 'all'])
          .orderBy('timeStamp', descending: true)
          .get();

      final List<Notificationn> notifications = notificationsSnapshot.docs
          .map((doc) =>
              Notificationn.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return notifications;
    } catch (e) {
      throw Exception("Error fetching notifications: $e");
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await notificationsCollection
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception("Error marking notification as read: $e");
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = firestore.batch();
      final notificationsSnapshot = await notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (var doc in notificationsSnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      throw Exception("Error marking all notifications as read: $e");
    }
  }

  @override
  Future<void> acceptConnectRequest(String notificationId) async {
    try {
      await notificationsCollection
          .doc(notificationId)
          .update({'isAccepted': true});
    } catch (e) {
      throw Exception("Error accepting connect request: $e");
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      throw Exception("Error deleting notification: $e");
    }
  }

  @override
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final querySnapshot = await notificationsCollection
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return querySnapshot.count!;
    } catch (e) {
      throw Exception("Error getting unread notification count: $e");
    }
  }
}
