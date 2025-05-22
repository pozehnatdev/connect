import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/chat/chatscreen.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  // LinkedIn colors
  final Color linkedInBlue = Color(0xFF0077B5);
  final Color lightBlue = Color(0xFF0A66C2);
  final Color whiteBackground = Color(0xFFF3F2EF);
  final Color borderGrey = Color(0xFFE1E9EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.message_outlined, color: linkedInBlue, size: 24),
            const SizedBox(width: 10),
            Text(
              'Messages',
              style: TextStyle(
                color: linkedInBlue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: _buildAddedUsersList(),
    );
  }

  Widget _buildAddedUsersList() {
    String currentUseruid = FirebaseAuth.instance.currentUser!.uid!;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUseruid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmptyState("Error loading messages");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: linkedInBlue,
            ),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>?;

        if (userData == null || userData['addedUsers'] == null) {
          return _buildEmptyState("No conversations yet");
        }

        var addedUsers = userData['addedUsers'] as List<dynamic>;

        if (addedUsers.isEmpty) {
          return _buildEmptyState("No conversations yet");
        }

        return ListView.builder(
          itemCount: addedUsers.length,
          itemBuilder: (context, index) {
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(addedUsers[index])
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return _buildUserTilePlaceholder();
                }

                if (userSnapshot.hasError ||
                    !userSnapshot.hasData ||
                    userSnapshot.data == null) {
                  return _buildUserTilePlaceholder(error: true);
                }

                var user = userSnapshot.data!.data() as Map<String, dynamic>?;
                if (user == null) {
                  return _buildUserTilePlaceholder(error: true);
                }

                return _buildUserTile(user);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserTilePlaceholder({bool error = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderGrey),
        ),
        child: ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
          ),
          title: Container(
            height: 16,
            color: error ? Colors.red[100] : Colors.grey[300],
          ),
          subtitle: Container(
            height: 12,
            width: 100,
            color: error ? Colors.red[50] : Colors.grey[200],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user) {
    String currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    List<String> ids = [currentUserUid, user['id']];
    ids.sort(); // Ensure chatRoomID is the same for any two users
    String chatRoomID = ids.join('_');

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection("chat_rooms")
          .doc(chatRoomID)
          .get(),
      builder: (context, snapshot) {
        bool isNewMessage = false;
        String senderUid = '';
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.exists) {
          isNewMessage = snapshot.data!['new_msg'] ?? false;
          senderUid = snapshot.data!['sender_uid'] ?? '';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderGrey),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                  image: user['imageUrl'] != null
                      ? DecorationImage(
                          image: NetworkImage(user['imageUrl']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user['imageUrl'] == null
                    ? Icon(Icons.person, size: 30, color: Colors.grey[600])
                    : null,
              ),
              title: Text(
                '${user['first_name'] ?? ''} ${user["last_name"] ?? ''}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              subtitle: user['proffesional_details'] != null &&
                      user['proffesional_details'].isNotEmpty
                  ? Text(
                      user['proffesional_details'][0]['title'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    )
                  : null,
              trailing: (FirebaseAuth.instance.currentUser!.uid != senderUid &&
                      isNewMessage)
                  ? Icon(
                      Icons.circle,
                      color: linkedInBlue,
                      size: 20,
                    )
                  : null,
              onTap: () {
                if (FirebaseAuth.instance.currentUser!.uid != senderUid) {
                  FirebaseFirestore.instance
                      .collection("chat_rooms")
                      .doc(chatRoomID)
                      .update({"new_msg": false, "sender_uid": currentUserUid});
                  setState(() {
                    isNewMessage = false;
                  });
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      recieverUID: user['id'],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
