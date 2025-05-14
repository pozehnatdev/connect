import 'package:connectapp/screens/notification/presentation/components/notification_tile.dart';
import 'package:connectapp/screens/notification/presentation/cubits/notification_cubits.dart';
import 'package:connectapp/screens/notification/presentation/cubits/notification_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectapp/screens/notification/domain/entities/notification.dart'
    as custom;

class NotificationList extends StatelessWidget {
  const NotificationList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state is NotificationsLoaded) {
          final notifications = state.notifications;

          // Group notifications by time section
          final Map<String, List<custom.Notificationn>> groupedNotifications =
              {};

          for (var notification in notifications) {
            final timeSection = _getTimeSection(notification.timeStamp);
            if (!groupedNotifications.containsKey(timeSection)) {
              groupedNotifications[timeSection] = [];
            }
            groupedNotifications[timeSection]!.add(notification);
          }

          // Build list with headers only for the first item in each group
          final List<Widget> notificationWidgets = [];

          groupedNotifications.forEach((timeSection, notificationsInSection) {
            for (int i = 0; i < notificationsInSection.length; i++) {
              notificationWidgets.add(
                NotificationTile(
                  notification: notificationsInSection[i],
                  showHeader: i == 0 ? true : false,
                ),
              );
            }
          });

          return ListView(
            children: notificationWidgets,
          );
        } else if (state is NotificationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('No notifications'));
        }
      },
    );
  }

  String _getTimeSection(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) return "Today";
    if (difference.inDays == 1) return "Yesterday";
    if (difference.inDays < 7) return "This Week";
    return "Last Week";
  }
}
