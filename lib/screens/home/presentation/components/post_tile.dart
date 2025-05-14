import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/post/domain/entities/comment.dart';
import 'package:connectapp/screens/post/domain/entities/post.dart';
import 'package:connectapp/screens/post/presentation/cubits/post_cubits.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final VoidCallback? onDeletePressed;
  const PostTile(
      {super.key, required this.post, required this.onDeletePressed});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  bool isOwnPost = false;
  Userr? currentUser;
  bool isLoading = true; // Add a loading state
  bool isExpanded = false;
  bool showComments = false;
  bool isTtsPlaying = false;
  bool isCommentLiked = false;

  void toggleCommentLike() {
    setState(() {
      isCommentLiked = !isCommentLiked;
    });
  }

  void toggleLikePost() {
    // Check if currentUser is null or id is null
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

  void togglesavePost() {
    // Check if currentUser is null or id is null
    if (currentUser == null || currentUser!.id == null) return;

    final issaved = widget.post.saves.contains(currentUser!.id!);

    setState(() {
      if (issaved) {
        widget.post.saves.remove(currentUser!.id!);
      } else {
        widget.post.saves.add(currentUser!.id!);
      }
    });

    context
        .read<PostCubit>()
        .toggleSavePost(widget.post.id, currentUser!.id!)
        .catchError((error) {
      setState(() {
        if (issaved) {
          widget.post.saves.add(currentUser!.id!);
        } else {
          widget.post.saves.remove(currentUser!.id);
        }
      });
    });
  }

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

  final CommentTextController = TextEditingController();

  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                content: MyTextField(
                  controller: CommentTextController,
                  hintText: 'Add a Comment',
                  obscureText: false,
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        addComment();
                        Navigator.pop(context);
                      },
                      child: Text('Post')),
                ]));
  }

  void addComment() {
    // Check if currentUser is null
    if (currentUser == null) return;

    final text = CommentTextController.text;

    // Only proceed if text is not empty and required fields exist
    if (text.isEmpty || currentUser!.first_name == null) return;

    final newcomment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        postId: widget.post.id,
        userId: widget.post.userid,
        userName:
            currentUser!.first_name! + " " + (currentUser?.last_name ?? ''),
        text: text,
        timeStamp: DateTime.now());

    context.read<PostCubit>().addComment(widget.post.id, newcomment);
    CommentTextController.clear();
  }

  @override
  void dispose() {
    CommentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is being fetched
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // If currentUser is still null after loading, show an error message
    if (currentUser == null) {
      return const Center(
        child: Text("Error loading user data. Please try again."),
      );
    }

    List<String> words = widget.post.text.split(' ');
    bool shouldShowViewMore = words.length > 20;
    String displayedText = isExpanded
        ? widget.post.text
        : (shouldShowViewMore
            ? words.take(17).join(' ') + '...'
            : widget.post.text);

    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 10),
                  CircleAvatar(
                    child: ClipOval(
                      child: FadeInImage(
                        placeholder: AssetImage('assets/img.png'),
                        image: AssetImage('assets/${widget.post.userName}.png'),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        imageErrorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/${widget.post.userName}.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/default_profile.jpg',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                  Text(
                    customTimeAgo(widget.post.timeStamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 17),
                ],
              ),
            ),
            if (isOwnPost)
              IconButton(
                onPressed: widget.onDeletePressed,
                icon: Icon(Icons.delete),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 55.0, right: 10.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: displayedText,
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  children: shouldShowViewMore && !isExpanded
                      ? [
                          TextSpan(
                            text: " View More",
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          )
                        ]
                      : [],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            const SizedBox(
              width: 55,
            ),
            GestureDetector(
                onTap: toggleLikePost,
                child: Icon(
                  widget.post.likes.contains(currentUser?.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.post.likes.contains(currentUser?.id)
                      ? Colors.red
                      : null,
                )),
            Text(widget.post.likes.length.toString(),
                style: TextStyle(color: Colors.grey[500])),
            const SizedBox(
              width: 20,
            ),
            GestureDetector(
              onTap: () {
                setState(() => showComments = !showComments);
              },
              child: Icon(Icons.comment_outlined, size: 18),
            ),
            Text(widget.post.comments.length.toString(),
                style: TextStyle(color: Colors.grey[500])),
            const SizedBox(
              width: 20,
            ),
            GestureDetector(
                onTap: togglesavePost,
                child: Icon(widget.post.saves.contains(currentUser?.id)
                    ? Icons.bookmark
                    : Icons.bookmark_border)),
            Text(widget.post.saves.length.toString(),
                style: TextStyle(color: Colors.grey[500])),
            const Spacer(),
            const SizedBox(
              width: 12,
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        //Divider(thickness: 2, color: Colors.grey[300]),
        if (showComments)
          Column(
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Text(
                    "Replies",
                    style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: openNewCommentBox,
                    icon: Icon(Icons.add_comment_outlined),
                    iconSize: 25,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 1,
                  ),
                ],
              ),
              //Divider(thickness: 1, color: Colors.grey[300]),
              for (int i = 0; i < widget.post.comments.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              CircleAvatar(
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/default_profile.jpg',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                              if (i < widget.post.comments.length - 1)
                                Container(
                                  width: 2,
                                  height:
                                      widget.post.comments[i].text.length * 0.6,
                                  color: Colors.grey[300],
                                ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      widget.post.comments[i].userName,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Text(
                                      customTimeAgo(
                                          widget.post.comments[i].timeStamp),
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  widget.post.comments[i].text,
                                  style: TextStyle(fontSize: 15),
                                  maxLines: null,
                                  softWrap: true,
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    GestureDetector(
                                        onTap: toggleCommentLike,
                                        child: Icon(
                                          isCommentLiked
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isCommentLiked
                                              ? Colors.red
                                              : null,
                                        )),
                                    Text(isCommentLiked ? '1' : '0',
                                        style:
                                            TextStyle(color: Colors.grey[500])),
                                    const SizedBox(width: 10),
                                    Icon(Icons.comment_outlined, size: 18),
                                    Text('0',
                                        style:
                                            TextStyle(color: Colors.grey[500])),
                                    const SizedBox(width: 10),
                                    Icon(Icons.bookmark_border, size: 18),
                                    Text('0',
                                        style:
                                            TextStyle(color: Colors.grey[500])),
                                    const Spacer(),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              // Divider(thickness: 1, color: Colors.grey[300]),
            ],
          ),
      ],
    );
  }
}

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black54,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black26,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.black26,
        ),
      ),
    );
  }
}
