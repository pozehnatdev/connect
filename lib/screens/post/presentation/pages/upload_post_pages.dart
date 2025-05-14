import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/post/domain/entities/post.dart';
import 'package:connectapp/screens/post/presentation/cubits/post_cubits.dart';
import 'package:connectapp/screens/post/presentation/cubits/post_states.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UploadPostPages extends StatefulWidget {
  UploadPostPages({
    super.key,
  });

  @override
  State<UploadPostPages> createState() => _UploadPostPagesState();
}

class _UploadPostPagesState extends State<UploadPostPages> {
  final textController = TextEditingController();
  // final captionController = TextEditingController();

  //String? _selectedImage;
  //bool _postAnonymously = false;

  Userr? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  /*Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to take more space
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ImagePickerBottomSheet(
        assetImages: assetImages,
        onImageSelected: (imagePath) {
          setState(() {
            _selectedImage = imagePath;
          });
        },
      ),
    );
  }*/

  void getCurrentUser() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (snapshot.exists) {
      currentUser = Userr.fromJson(snapshot.data() as Map<String, dynamic>);
    }
  }

  void uploadPost() {
    if (textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Caption is required'),
          backgroundColor: Colors.black54,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      );
      return;
    }
    final newPost;

    newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userid: currentUser?.id ?? "",
      userName: currentUser!.first_name! + " " + (currentUser?.last_name ?? ''),
      text: textController.text,
      //caption: captionController.text,

      timeStamp: DateTime.now(),
      likes: [],
      saves: [],
      comments: [],
      //imageUrl: _selectedImage,
      //anonymous: _postAnonymously,
    );

    final postCubit = context.read<PostCubit>();
    postCubit.createPost(newPost);
  }

  @override
  void dispose() {
    textController.dispose();
    //captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(builder: (context, state) {
      if (state is PostLoading || state is PostUploading) {
        return Scaffold(
          body: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      }
      return buildUploadPage();
    }, listener: (context, state) {
      if (state is PostLoaded) {
        Navigator.pop(context);
      }
    });
  }

  Widget buildUploadPage() {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        //backgroundColor: Colors.grey,
        title: const Text(
          'New Post',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: uploadPost,
              icon: const Icon(Icons.check_box_outlined, size: 28),
              tooltip: 'Upload Post',
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Selection Area

              /*GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: AssetImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_upload_outlined,
                                color: Colors.grey.shade500,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Upload image/video here',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ),*/
              /*const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: captionController,
                  decoration: const InputDecoration(
                    hintText: 'Write title here...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),*/

              const SizedBox(height: 12),

              // Content Field
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: 'Write content here...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(fontSize: 16),
                  maxLines: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
