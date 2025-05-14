import 'package:connectapp/screens/notification/domain/entities/notification.dart';

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationError extends NotificationState {
  final String message;

  NotificationError(this.message);
}

class NotificationsLoaded extends NotificationState {
  final List<Notificationn> notifications;

  NotificationsLoaded(this.notifications);
}

class NotificationCountLoaded extends NotificationState {
  final int count;

  NotificationCountLoaded(this.count);
}
