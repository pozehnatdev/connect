import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/post/domain/entities/comment.dart';
import 'package:connectapp/screens/post/domain/entities/post.dart';
import 'package:connectapp/screens/post/presentation/cubits/post_cubits.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  bool isOwnPost = false;
  Userr? currentUser;
  bool isLoading = true;
  bool isCommentLiked = false;
  final commentTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (snapshot.exists) {
        setState(() {
          currentUser = Userr.fromJson(snapshot.data() as Map<String, dynamic>);
          isOwnPost = (widget.post.userid == currentUser?.id);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<String?> getUserImageUrl() async {
    final userid = widget.post.userid;
    if (userid == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userid).get();
    return doc['imageUrl'];
  }

  String customTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  void toggleLikePost() {
    if (currentUser == null || currentUser!.id == null) return;

    final isLiked = widget.post.likes.contains(currentUser!.id);

    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser?.id);
      } else {
        widget.post.likes.add(currentUser!.id!);
      }
    });

    context
        .read<PostCubit>()
        .toggleLikePost(widget.post.id, currentUser!.id!)
        .catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.id!);
        } else {
          widget.post.likes.remove(currentUser!.id!);
        }
      });
    });
  }

  void toggleSavePost() {
    if (currentUser == null || currentUser!.id == null) return;

    final isSaved = widget.post.saves.contains(currentUser!.id);

    setState(() {
      if (isSaved) {
        widget.post.saves.remove(currentUser!.id);
      } else {
        widget.post.saves.add(currentUser!.id!);
      }
    });

    context
        .read<PostCubit>()
        .toggleSavePost(widget.post.id, currentUser!.id!)
        .catchError((error) {
      setState(() {
        if (isSaved) {
          widget.post.saves.add(currentUser!.id!);
        } else {
          widget.post.saves.remove(currentUser!.id);
        }
      });
    });
  }

  void toggleCommentLike() {
    setState(() {
      isCommentLiked = !isCommentLiked;
    });
  }

  void addComment() {
    if (currentUser == null) return;

    final text = commentTextController.text.trim();
    if (text.isEmpty || currentUser!.first_name == null) return;

    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.id ?? '',
      userName: "${currentUser!.first_name!} ${currentUser?.last_name ?? ''}",
      text: text,
      timeStamp: DateTime.now(),
    );

    context.read<PostCubit>().addComment(widget.post.id, newComment);

    setState(() {
      widget.post.comments.add(newComment); // ✅ Add the comment locally
      commentTextController.clear();
    });

    // Scroll to bottom after a short delay
    Future.delayed(Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    commentTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Post Detail'),
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // LinkedIn color scheme
    final Color linkedInBlue = Color(0xFF0A66C2);
    final Color linkedInBackground = Color(0xFFF3F2EF);
    final Color linkedInCardBackground = Colors.white;
    final Color linkedInSecondaryTextColor = Color(0xFF666666);

    return Scaffold(
      backgroundColor: linkedInBackground,
      appBar: AppBar(
        //title: Text('Post Detail'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: linkedInBlue,
        actions: [
          if (isOwnPost)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Delete Post'),
                    content: Text('Are you sure you want to delete this post?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<PostCubit>().DeletePost(widget.post.id);
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to previous screen
                        },
                        child: Text('Delete'),
                        style:
                            TextButton.styleFrom(foregroundColor: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Full post content
          Expanded(
            child: ListView(
              controller: _scrollController,
              children: [
                Container(
                  color: linkedInCardBackground,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post header
                      Row(
                        children: [
                          FutureBuilder<String?>(
                            future: getUserImageUrl(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              final url = snapshot.data;
                              return CircleAvatar(
                                backgroundImage:
                                    url != null ? NetworkImage(url) : null,
                                child: url == null ? Icon(Icons.person) : null,
                              );
                            },
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.post.userName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            customTimeAgo(widget.post.timeStamp),
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),

                      // Post content
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          widget.post.text,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),

                      // Post stats and actions
                      Row(
                        children: [
                          GestureDetector(
                            onTap: toggleLikePost,
                            child: Icon(
                              widget.post.likes.contains(currentUser?.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: widget.post.likes.contains(currentUser?.id)
                                  ? Colors.red
                                  : null,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            widget.post.likes.length.toString(),
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          SizedBox(width: 20),
                          Icon(Icons.comment_outlined, size: 18),
                          SizedBox(width: 4),
                          Text(
                            widget.post.comments.length.toString(),
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                          SizedBox(width: 20),
                          GestureDetector(
                            onTap: toggleSavePost,
                            child: Icon(
                              widget.post.saves.contains(currentUser?.id)
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            widget.post.saves.length.toString(),
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Comments section header
                Container(
                  color: linkedInCardBackground,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  margin: EdgeInsets.only(top: 8),
                  child: Text(
                    "Comments (${widget.post.comments.length})",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Comments list
                if (widget.post.comments.isEmpty)
                  Container(
                    color: linkedInCardBackground,
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        "No comments yet. Be the first to comment!",
                        style: TextStyle(
                          color: linkedInSecondaryTextColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    color: linkedInCardBackground,
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.post.comments.length,
                      itemBuilder: (context, index) {
                        final comment = widget.post.comments[index];
                        return CommentTile(
                          comment: comment,
                          currentUserId: currentUser?.id,
                          onLikeToggle: () => toggleCommentLike(),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Comment input field
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/default_profile.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: commentTextController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    maxLines: null,
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: linkedInBlue),
                  onPressed: addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final Comment comment;
  final String? currentUserId;
  final VoidCallback onLikeToggle;

  const CommentTile({
    super.key,
    required this.comment,
    this.currentUserId,
    required this.onLikeToggle,
  });

  String customTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '${difference.inSeconds}s';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            child: ClipOval(
              child: Image.asset(
                'assets/default_profile.jpg',
                fit: BoxFit.cover,
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFF3F2EF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comment.userName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Spacer(),
                          Text(
                            customTimeAgo(comment.timeStamp),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        comment.text,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onLikeToggle,
                        child: Text(
                          "Like",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "Reply",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
