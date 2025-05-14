import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/screens/post/domain/entities/comment.dart';

class Post {
  final String id;
  final String userid;
  final String userName;
  final String text;
  //final String caption;

  final DateTime timeStamp;
  final List<String> likes;
  final List<String> saves;
  final List<Comment> comments;
  //final String? imageUrl;
  //final bool anonymous;

  Post({
    required this.id,
    required this.userid,
    required this.userName,
    required this.text,
    //required this.caption,
    required this.timeStamp,
    required this.likes,
    required this.saves,
    required this.comments,
    //required this.imageUrl,
    //required this.anonymous,
  });

  //convert post to json

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userid,
      'userName': userName,
      'text': text,
      // 'caption': caption,
      'timeStamp': timeStamp,
      'likes': likes,
      'saves': saves,
      'comments': comments.map((comment) => comment.toJson()),
      //'imageUrl': imageUrl,
      //'anonymous': anonymous,
    };
  }

  //convert json to post

  factory Post.fromJson(Map<String, dynamic> json) {
    final List<Comment> comments = (json['comments'] as List<dynamic>?)
            ?.map((commentJson) => Comment.fromJson(commentJson))
            .toList() ??
        [];
    return Post(
      id: json['id'],
      userid: json['userid'],
      userName: json['userName'],
      text: json['text'],
      //caption: json['caption'],
      timeStamp: (json['timeStamp'] as Timestamp).toDate(),
      likes: List<String>.from(json['likes'] ?? []),
      saves: List<String>.from(json['saves'] ?? []),
      comments: comments,
      //imageUrl: json['imageUrl'],
      //anonymous: json['anonymous'],
    );
  }
}
