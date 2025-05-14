import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/screens/post/domain/entities/comment.dart';
import 'package:connectapp/screens/post/domain/entities/post.dart';
import 'package:connectapp/screens/post/domain/repos/post_repos.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');
  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error creating post $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPost() async {
    try {
      final postsSnapshot =
          await postsCollection.orderBy('timeStamp', descending: true).get();
      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return allPosts;
    } catch (e) {
      throw Exception("Error deleting post $e");
    }
  }

  @override
  Future<List<Post>> fetchPostbyUserId(String userId) async {
    try {
      final postsSnapshot =
          await postsCollection.where('userId', isEqualTo: userId).get();

      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception("Error fetching post by user id $e");
    }
  }

  @override
  Future<void> togglelikePost(String postId, String userId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        final hasliked = post.likes.contains(userId);
        if (hasliked) {
          post.likes.remove(userId);
        } else {
          post.likes.add(userId);
        }
        await postsCollection.doc(postId).update({'likes': post.likes});
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error toggling like $e');
    }
  }

  @override
  Future<void> togglesavePost(String postId, String userId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        final hassaved = post.saves.contains(userId);
        if (hassaved) {
          post.saves.remove(userId);
        } else {
          post.saves.add(userId);
        }
        await postsCollection.doc(postId).update({'saves': post.saves});
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error toggling save $e');
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        post.comments.add(comment);
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error adding comment $e');
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);
        post.comments.removeWhere((comment) => comment.id == commentId);
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception('Post not found');
      }
    } catch (e) {
      throw Exception('Error deleting comment $e');
    }
  }
}
