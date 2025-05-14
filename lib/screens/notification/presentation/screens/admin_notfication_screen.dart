import 'package:connectapp/screens/notification/domain/entities/notification.dart';
import 'package:connectapp/screens/notification/presentation/cubits/notification_cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminNotficationScreen extends StatefulWidget {
  const AdminNotficationScreen({super.key});

  @override
  State<AdminNotficationScreen> createState() => _AdminNotficationScreenState();
}

class _AdminNotficationScreenState extends State<AdminNotficationScreen> {
  TextEditingController notificationController = TextEditingController();
  @override
  void SubmitNotification() {
    // Implement the logic to submit the notification to the server or database
    String notificationText = notificationController.text;
    if (notificationText.isNotEmpty) {
      final notification = Notificationn(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: "all",
          triggerUserId: "null",
          triggerUserName: "null",
          //postId: "null",
          type: 0, // 1 for request, 0 for event
          isAccepted: false,
          timeStamp: DateTime.now(),
          isRead: false,
          text: notificationText);
      context.read<NotificationCubit>().createNotification(notification);
      print("Notification submitted: $notificationText");
      // Clear the text field after submission
      notificationController.clear();
    } else {
      print("Notification text is empty.");
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Notification',
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: notificationController,
              decoration: InputDecoration(
                labelText: 'Add Notification',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                SubmitNotification();
              },
              child: Text('Submit Notification'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
