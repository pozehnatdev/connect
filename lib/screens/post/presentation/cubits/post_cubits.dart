import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/screens/post/domain/entities/comment.dart';
import 'package:connectapp/screens/post/domain/entities/post.dart';
import 'package:connectapp/screens/post/domain/repos/post_repos.dart';
import 'package:connectapp/screens/post/presentation/cubits/post_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  //final NotificationCubit notificationCubit;

  PostCubit({
    required this.postRepo,
    /*required this.notificationCubit*/
  }) : super(PostInitial());

  Future<void> createPost(Post post) async {
    try {
      postRepo.createPost(post);
      FetchAllPosts();
    } catch (e) {
      emit(PostError("Error creating post $e"));
    }
  }

  Future<void> FetchAllPosts() async {
    try {
      emit(PostLoading());
      final posts = await postRepo.fetchAllPost();
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError("Error fetching posts $e"));
    }
  }

  Future<void> DeletePost(String postId) async {
    try {
      postRepo.deletePost(postId);
      //emit(PostInitial());
    } catch (e) {
      emit(PostError("Error deleting post $e"));
    }
  }

  Future<Map<String, dynamic>?> getPostById(String postId) async {
    try {
      DocumentSnapshot postSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();

      if (postSnapshot.exists) {
        return postSnapshot.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching post: $e');
      return null;
    }
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      // Get post details to know the post owner
      final posts = state is PostLoaded
          ? (state as PostLoaded).posts
          : await postRepo.fetchAllPost();
      final post = posts.firstWhere((post) => post.id == postId);

      // Check if the user is liking or unliking
      final isLiking = !post.likes.contains(userId);

      await postRepo.togglelikePost(postId, userId);

      // Only create notification if the user is liking (not unliking)
      // And don't notify if user likes their own post
      if (isLiking && post.userid != userId) {
        final currentUser = posts.firstWhere((post) => post.userid == userId,
            orElse: () => Post(
                  id: '',
                  userid: userId,
                  userName: 'User',
                  text: '',
                  timeStamp: DateTime.now(),
                  likes: [],
                  saves: [],
                  comments: [],
                  //imageUrl: null,
                ));
      }
    } catch (e) {
      emit(PostError("Error toggling like post $e"));
    }
  }

  Future<void> toggleSavePost(String postId, String userId) async {
    try {
      // Get post details to know the post owner
      final posts = state is PostLoaded
          ? (state as PostLoaded).posts
          : await postRepo.fetchAllPost();
      final post = posts.firstWhere((post) => post.id == postId);

      // Check if the user is saving or unsaving
      final isSaving = !post.saves.contains(userId);

      await postRepo.togglesavePost(postId, userId);

      // Only create notification if the user is saving (not unsaving)
      // And don't notify if user saves their own post
      if (isSaving && post.userid != userId) {
        final currentUser = posts.firstWhere((post) => post.userid == userId,
            orElse: () => Post(
                  id: '',
                  userid: userId,
                  userName: 'User',
                  text: '',
                  timeStamp: DateTime.now(),
                  likes: [],
                  saves: [],
                  comments: [],
                  //imageUrl: null,
                ));
      }
    } catch (e) {
      emit(PostError("Error toggling save post $e"));
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      // Get post details
      final posts = state is PostLoaded
          ? (state as PostLoaded).posts
          : await postRepo.fetchAllPost();
      final post = posts.firstWhere((post) => post.id == postId);

      await postRepo.addComment(postId, comment);

      FetchAllPosts();
    } catch (e) {
      emit(PostError("Error adding comment $e"));
    }
  }

  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await postRepo.deleteComment(postId, commentId);
      FetchAllPosts();
    } catch (e) {
      emit(PostError("Error deleting comment $e"));
    }
  }
}
