import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/chat/chat_bubble.dart';
import 'package:connectapp/model/chat/chatservice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String recieverUID;

  const ChatScreen({
    Key? key,
    required this.recieverUID,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // LinkedIn colors
  final Color linkedInBlue = Color(0xFF0077B5);
  final Color lightBlue = Color(0xFF0A66C2);
  final Color whiteBackground = Color(0xFFF3F2EF);
  final Color borderGrey = Color(0xFFE1E9EE);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final Chatservice _chatService = Chatservice();
  final FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  // User details for the receiver
  Map<String, dynamic>? _receiverUserData;

  @override
  void initState() {
    super.initState();
    _fetchReceiverUserData();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });
    Future.delayed(
      const Duration(milliseconds: 500),
      () => scrollDown(),
    );
  }

  void _fetchReceiverUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.recieverUID).get();

      setState(() {
        _receiverUserData = userDoc.data() as Map<String, dynamic>?;
      });
    } catch (e) {
      print("Error fetching receiver user data: $e");
    }
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.fastOutSlowIn);
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.recieverUID, _messageController.text);
      _messageController.clear();
    }

    scrollDown();
  }

  String _getReceiverName() {
    if (_receiverUserData != null) {
      String firstName = _receiverUserData!['first_name'] ?? '';
      String lastName = _receiverUserData!['last_name'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return widget.recieverUID;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: linkedInBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            // Profile picture
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
                image: _receiverUserData != null &&
                        _receiverUserData!['imageUrl'] != null
                    ? DecorationImage(
                        image: NetworkImage(_receiverUserData!['imageUrl']),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _receiverUserData == null ||
                      _receiverUserData!['imageUrl'] == null
                  ? Icon(Icons.person, color: Colors.grey[600])
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getReceiverName(),
                    style: TextStyle(
                      color: linkedInBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_receiverUserData != null &&
                      _receiverUserData!['proffesional_details'] != null &&
                      _receiverUserData!['proffesional_details'].isNotEmpty)
                    Text(
                      _receiverUserData!['proffesional_details'][0]['title'] ??
                          '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.video_call, color: linkedInBlue),
            onPressed: () {
              // Implement video call functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.call, color: linkedInBlue),
            onPressed: () {
              // Implement voice call functionality
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String? senderUID = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
        stream: _chatService.getMessages(widget.recieverUID, senderUID),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading messages",
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: linkedInBlue,
              ),
            );
          }
          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    String? senderUID = FirebaseAuth.instance.currentUser!.uid;
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data["senderEmail"] == senderUID;
    DateTime timeMsg = data["timestamp"].toDate();
    String formattedTime = DateFormat('MMM d, h:mm a').format(timeMsg);
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return InkWell(
      onLongPress: () => _showMessageOptionsDialog(doc, isCurrentUser),
      child: Container(
        alignment: alignment,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            ChatBubble(message: data["message"], iscurrentUser: isCurrentUser),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptionsDialog(DocumentSnapshot doc, bool isCurrentUser) {
    String? senderUID = FirebaseAuth.instance.currentUser!.uid;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(
            'Manage Message',
            style: TextStyle(
              color: linkedInBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Do you want to delete this message?',
            style: TextStyle(color: Colors.grey[800]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: linkedInBlue),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentUser ? Colors.red : Colors.grey,
              ),
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (isCurrentUser) {
                  _chatService.deleteMessages(
                      widget.recieverUID, senderUID!, doc.id);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('You can only delete your own messages'),
                      backgroundColor: Colors.red[400],
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: borderGrey, width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.camera_alt, color: linkedInBlue),
            onPressed: () {
              // Implement camera/media upload functionality
            },
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderGrey),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: myFocusNode,
                decoration: InputDecoration(
                  hintText: 'Write a message...',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: null,
                minLines: 1,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.send,
              color: _messageController.text.isNotEmpty
                  ? linkedInBlue
                  : Colors.grey,
            ),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
