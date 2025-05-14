import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  //final String senderID;
  final String senderUID;
  final String recieverUID;
  final String message;
  final Timestamp timestamp;

  Message({
    //required this.senderID,
    required this.senderUID,
    required this.recieverUID,
    required this.message,
    required this.timestamp,
  });

  //Convert to Map

  Map<String, dynamic> toMap() {
    return {
      //'senderID': senderID,
      'senderEmail': senderUID,
      'recieverID': recieverUID,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
