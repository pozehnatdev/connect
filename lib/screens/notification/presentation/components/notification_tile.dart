import 'package:connectapp/screens/notification/presentation/cubits/notification_cubits.dart';
import 'package:connectapp/screens/post/presentation/cubits/post_cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:connectapp/screens/notification/domain/entities/notification.dart'
    as custom;

class NotificationTile extends StatefulWidget {
  final custom.Notificationn notification;
  final bool showHeader;

  const NotificationTile({
    Key? key,
    required this.notification,
    this.showHeader = false,
  }) : super(key: key);

  @override
  State<NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<NotificationTile> {
  bool isTtsPlaying = false;
  bool _isProcessing = false;
  bool _locallyAccepted = false;

  @override
  void initState() {
    super.initState();
    // If the notification is already accepted, reflect that in our local state
    _locallyAccepted = widget.notification.isAccepted;
  }

  String _getNotificationTitle() {
    switch (widget.notification.type) {
      case 1:
        return "${widget.notification.triggerUserName} sent you a connection request";
      default:
        return "${widget.notification.text}";
    }
  }

  IconData _getNotificationIcon() {
    switch (widget.notification.type) {
      case 1:
        return Icons.connect_without_contact;
      default:
        return Icons.admin_panel_settings_outlined;
    }
  }

  String _getTimeSection(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) return "Today";
    if (difference.inDays == 1) return "Yesterday";
    if (difference.inDays < 7) return "This Week";
    return "Last Week";
  }

  Future<void> _handleAcceptConnection() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Immediately update the UI
      setState(() {
        _locallyAccepted = true;
        _isProcessing = false;
      });

      final currentUserId = FirebaseAuth.instance.currentUser?.uid;
      if (currentUserId == null || currentUserId.isEmpty) {
        throw Exception('No authenticated user found');
      }

      final triggerUserId = widget.notification.triggerUserId;
      if (triggerUserId == null || triggerUserId.isEmpty) {
        throw Exception('Invalid trigger user ID');
      }

      // Do the backend processing silently
      try {
        // 1. Update the notification status to accepted
        await FirebaseFirestore.instance
            .collection('notifications')
            .where('id', isEqualTo: widget.notification.id)
            .get()
            .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            snapshot.docs.first.reference.update({
              'isAccepted': true,
              'isRead': true,
            });
          }
        });

        // 2. Update current user's addedUsers array
        DocumentReference userDoc1 =
            FirebaseFirestore.instance.collection('users').doc(currentUserId);

        await userDoc1.update({
          'addedUsers': FieldValue.arrayUnion([triggerUserId])
        });

        // 3. Update trigger user's addedUsers array
        DocumentReference userDoc2 =
            FirebaseFirestore.instance.collection('users').doc(triggerUserId);

        await userDoc2.update({
          'addedUsers': FieldValue.arrayUnion([currentUserId])
        });

        // Show success snackbar
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Connection with ${widget.notification.triggerUserName} accepted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Just log the error, don't change UI state back
        print('Error in backend operations: $e');
      }
    } catch (e) {
      // This should only happen if we can't get the current user ID
      setState(() {
        _locallyAccepted = false;
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept connection: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleRejectConnection() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Update the UI immediately
      setState(() {
        _isProcessing = false;
      });

      // 2. Process backend operations
      try {
        // Delete the notification from Firestore
        await FirebaseFirestore.instance
            .collection('notifications')
            .where('id', isEqualTo: widget.notification.id)
            .get()
            .then((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            snapshot.docs.first.reference.delete();
          }
        });

        // Show rejection message if still mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Connection request rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        // Just log the error, UI is already updated
        print('Error in backend rejection: $e');
      }
    } catch (e) {
      // This is for critical errors before UI update
      setState(() {
        _isProcessing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject connection: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the PostCubit directly in the build method instead of storing it
    final postCubit = context.read<PostCubit>();

    return Container(
      color: widget.notification.isRead ? null : Colors.grey[100],
      child: Column(
        children: [
          // Section header - only show if showHeader is true
          if (widget.showHeader)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: Text(
                _getTimeSection(widget.notification.timeStamp),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          // Divider after header
          if (widget.showHeader)
            const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          // Notification tile
          InkWell(
            onTap: () {
              if (!widget.notification.isRead) {
                context
                    .read<NotificationCubit>()
                    .markNotificationAsRead(widget.notification.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon on the left
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        child: Icon(
                          _getNotificationIcon(),
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      // Notification text
                      Expanded(
                        child: Text(
                          _getNotificationTitle(),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Connection request actions - only show for connection requests (type 1)
                  // and only if not already accepted
                  if (widget.notification.type == 1 &&
                      !widget.notification.isAccepted &&
                      !_locallyAccepted)
                    Container(
                      margin: const EdgeInsets.only(top: 12, left: 40),
                      child: _isProcessing
                          ? const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : Row(
                              children: [
                                ElevatedButton(
                                  onPressed: _handleAcceptConnection,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text('Accept'),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton(
                                  onPressed: _handleRejectConnection,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.grey[800],
                                    side: BorderSide(color: Colors.grey[400]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text('Decline'),
                                ),
                              ],
                            ),
                    ),

                  // Show "Accepted" label for already accepted connection requests
                  if (widget.notification.type == 1 &&
                      (widget.notification.isAccepted || _locallyAccepted))
                    Container(
                      margin: const EdgeInsets.only(top: 8, left: 40),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Accepted',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
