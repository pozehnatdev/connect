import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/events/presentation/pages/events_list_screen.dart';
import 'package:connectapp/screens/events/presentation/pages/events_screen.dart';
import 'package:connectapp/screens/home/presentation/components/post_tile.dart';
import 'package:connectapp/screens/message_screen.dart';
import 'package:connectapp/screens/notification/presentation/components/notification_badge.dart';
import 'package:connectapp/screens/notification/presentation/screens/notification_screen.dart';
import 'package:connectapp/screens/post/presentation/cubits/post_cubits.dart';
import 'package:connectapp/screens/post/presentation/cubits/post_states.dart';
import 'package:connectapp/screens/post/presentation/pages/post_details_screen.dart';
import 'package:connectapp/screens/post/presentation/pages/upload_post_pages.dart';
import 'package:connectapp/screens/profile/user_profile.dart' as profile;
import 'package:connectapp/screens/search/search_screen.dart';
import 'package:connectapp/screens/signInScreen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  late final Future<Userr> user = FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser?.uid)
      .withConverter<Userr>(
        fromFirestore: (snapshot, _) => Userr.fromJson(snapshot.data()!),
        toFirestore: (user, _) => user.toJson(),
      )
      .get()
      .then((value) => value.data()!);

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeFeedScreen(),
      UserSearchScreen(),
      EventsScreen(),
      MessageScreen(),
      FutureBuilder<Userr>(
        future: user,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return profile.ProfilePage(user: snapshot.data!);
          } else {
            return Center(child: Text('No user data available'));
          }
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Color(0xFF0A66C2), // LinkedIn blue
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget HomeScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Log out the user
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class HomeFeedScreen extends StatefulWidget {
  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  late final postCubit = context.read<PostCubit>();
  final ScrollController _scrollController = ScrollController();

  Future<String?> getUserImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc['imageUrl'];
  }

  // LinkedIn color scheme
  final Color linkedInBlue = Color(0xFF0A66C2);
  final Color linkedInBackground = Color(0xFFF3F2EF);
  final Color linkedInCardBackground = Colors.white;
  final Color linkedInTextColor = Color(0xFF000000);
  final Color linkedInSecondaryTextColor = Color(0xFF666666);
  final Color linkedInDividerColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    fetchAllPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchAllPosts() {
    postCubit.FetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.DeletePost(postId);
    fetchAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: linkedInBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text(
              'Connect',
              style: TextStyle(
                color: linkedInBlue,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationScreen(),
                  ),
                );
              },
              child: NotificationBadge(
                child: Icon(
                  Icons.notifications_none,
                  size: 30,
                ),
              )),
          IconButton(
            icon: const Icon(Icons.logout),
            color: linkedInBlue,
            onPressed: () {
              // Log out the user
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              );
            },
          ),
          /*IconButton(
            onPressed: () {},
            icon: Icon(Icons.message_outlined),
            color: linkedInBlue,
          ),*/
          /*IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadPostPages(),
              ),
            ),
            icon: Icon(Icons.add_box_outlined),
            color: linkedInBlue,
          ),*/
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Create post section
          Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: linkedInCardBackground,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              children: [
                FutureBuilder<String?>(
                  future: getUserImageUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    final url = snapshot.data;
                    return CircleAvatar(
                      backgroundImage: url != null ? NetworkImage(url) : null,
                      child: url == null ? Icon(Icons.person) : null,
                    );
                  },
                ),
                SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UploadPostPages(),
                      ),
                    ),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Start a Thread',
                        style: TextStyle(
                          color: linkedInSecondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 8,
            color: linkedInBackground,
          ),

          // Posts section
          Expanded(
            child: BlocBuilder<PostCubit, PostState>(
              builder: (context, state) {
                if (state is PostLoading && state is PostUploading) {
                  return Center(
                    child: CircularProgressIndicator(color: linkedInBlue),
                  );
                } else if (state is PostLoaded) {
                  return ListView.separated(
                    controller: _scrollController,
                    itemCount: state.posts.length,
                    separatorBuilder: (context, index) => Container(
                      height: 8,
                      color: linkedInBackground,
                    ),
                    itemBuilder: (context, index) {
                      final post = state.posts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailScreen(post: post),
                            ),
                          );
                        },
                        child: Container(
                          color: linkedInCardBackground,
                          child: PostTile(
                            post: post,
                            onDeletePressed: () => showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Delete Post'),
                                    content: Text(
                                        'Are you sure you want to delete this post?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          deletePost(post.id);
                                          Navigator.pop(context);
                                        },
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is PostError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          state.message,
                          style: TextStyle(
                            color: linkedInSecondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchAllPosts,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: linkedInBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadPostPages(),
          ),
        ),
        backgroundColor: linkedInBlue,
        child: Icon(Icons.edit),
      ),*/
    );
  }
}
