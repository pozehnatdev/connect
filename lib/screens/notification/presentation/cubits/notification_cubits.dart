import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectapp/screens/notification/domain/entities/notification.dart';
import 'package:connectapp/screens/notification/domain/repos/notification_repos.dart';
import 'package:connectapp/screens/notification/presentation/cubits/notification_states.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepo notificationRepo;

  NotificationCubit({required this.notificationRepo})
      : super(NotificationInitial());

  Future<void> createNotification(Notificationn notification) async {
    try {
      await notificationRepo.createNotification(notification);
    } catch (e) {
      emit(NotificationError("Error creating notification: $e"));
    }
  }

  Future<void> fetchNotificationsForUser(String userId) async {
    try {
      emit(NotificationLoading());
      final notifications =
          await notificationRepo.fetchNotificationsForUser(userId);
      emit(NotificationsLoaded(notifications));
    } catch (e) {
      emit(NotificationError("Error fetching notifications: $e"));
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await notificationRepo.markNotificationAsRead(notificationId);
      // After marking one as read, refresh the notifications
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        final updatedNotifications =
            currentState.notifications.map((notification) {
          if (notification.id == notificationId) {
            // Create a new notification object with isRead set to true
            return Notificationn(
              id: notification.id,
              userId: notification.userId,
              triggerUserId: notification.triggerUserId,
              triggerUserName: notification.triggerUserName,
              //postId: notification.postId,
              type: notification.type,
              isAccepted: notification.isAccepted,
              timeStamp: notification.timeStamp,
              isRead: true,
              text: notification.text,
            );
          }
          return notification;
        }).toList();
        emit(NotificationsLoaded(updatedNotifications));
      }
    } catch (e) {
      emit(NotificationError("Error marking notification as read: $e"));
    }
  }

  Future<void> acceptConnectRequest(
    String notificationId,
  ) async {
    try {
      // First, get the current state to check if we have loaded notifications
      final currentState = state;

      // Make the API call to accept the connection request
      await notificationRepo.acceptConnectRequest(notificationId);

      // After accepting the request, update the notification in our state
      if (currentState is NotificationsLoaded) {
        final updatedNotifications =
            currentState.notifications.map((notification) {
          if (notification.id == notificationId) {
            // Create a new notification object with isAccepted set to true
            return Notificationn(
              id: notification.id,
              userId: notification.userId,
              triggerUserId: notification.triggerUserId,
              triggerUserName: notification.triggerUserName,
              // postId: notification.postId,
              type: notification.type,
              isAccepted: true,
              timeStamp: notification.timeStamp,
              isRead: notification.isRead,
              text: notification.text,
            );
          }
          return notification;
        }).toList();
        emit(NotificationsLoaded(updatedNotifications));
      }
    } catch (e) {
      emit(NotificationError("Error accepting connect request: $e"));
      // Re-throw the error so the UI can handle it appropriately
      rethrow;
    }
  }

  Future<void> rejectConnectRequest(String notificationId) async {
    try {
      await notificationRepo.deleteNotification(notificationId);
      // After rejecting the request, refresh the notifications
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        final updatedNotifications = currentState.notifications
            .where((notification) => notification.id != notificationId)
            .toList();
        emit(NotificationsLoaded(updatedNotifications));
      }
    } catch (e) {
      emit(NotificationError("Error rejecting connect request: $e"));
      // Re-throw the error so the UI can handle it appropriately
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await notificationRepo.markAllNotificationsAsRead(userId);
      // After marking all as read, refresh the notifications
      final currentState = state;
      if (currentState is NotificationsLoaded) {
        final updatedNotifications =
            currentState.notifications.map((notification) {
          // Create a new notification object with isRead set to true
          return Notificationn(
            id: notification.id,
            userId: notification.userId,
            triggerUserId: notification.triggerUserId,
            triggerUserName: notification.triggerUserName,
            // postId: notification.postId,
            isAccepted: notification.isAccepted,
            type: notification.type,
            timeStamp: notification.timeStamp,
            isRead: true,
            text: notification.text,
          );
        }).toList();
        emit(NotificationsLoaded(updatedNotifications));
      }
    } catch (e) {
      emit(NotificationError("Error marking all notifications as read: $e"));
    }
  }

  Future<void> fetchUnreadNotificationCount(String userId) async {
    try {
      final count = await notificationRepo.getUnreadNotificationCount(userId);
      emit(NotificationCountLoaded(count));
    } catch (e) {
      emit(NotificationError("Error fetching unread notification count: $e"));
    }
  }
}
