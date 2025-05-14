// Post States

import 'package:connectapp/screens/post/domain/entities/post.dart';

abstract class PostState {}

class PostInitial extends PostState {}

//loading
class PostLoading extends PostState {}

//uploading
class PostUploading extends PostState {}

//errror

class PostError extends PostState {
  final String message;

  PostError(this.message);
}

//loaded

class PostLoaded extends PostState {
  final List<Post> posts;

  PostLoaded(this.posts);
}
