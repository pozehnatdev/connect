import 'package:connectapp/screens/post/domain/entities/comment.dart';
import 'package:connectapp/screens/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchAllPost();
  Future<List<Post>> fetchPostbyUserId(String userId);
  Future<void> togglelikePost(String postId, String userId);
  Future<void> togglesavePost(String postId, String userId);
  Future<void> addComment(String postId, Comment comment);
  Future<void> deleteComment(String postId, String commentId);
}
