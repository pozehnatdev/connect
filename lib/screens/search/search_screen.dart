import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/chat/chatscreen.dart';
import 'package:connectapp/screens/notification/domain/entities/notification.dart';
import 'package:connectapp/screens/profile/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connectapp/model/user/user_model.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({Key? key}) : super(key: key);

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  //Map<String, bool> _isConnectingMap = {}; // Track connection state per user
  late final String _currentUserId;
  Userr? _currentUser;

  // Cache connection statuses for better performance
  //Map<String, String> _connectionStatusCache =
  //    {}; // 'connected', 'pending', or 'none'

  // Search results
  List<Userr> _searchResults = [];

  // LinkedIn-inspired colors
  final Color linkedInBlue = const Color(0xFF0077B5);
  final Color lightBlue = const Color(0xFF0A66C2);
  final Color whiteBackground = const Color(0xFFF3F2EF);
  final Color borderGrey = const Color(0xFFE1E9EE);

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
  }

  Future<void> _initializeCurrentUser() async {
    try {
      final currentFirebaseUser = FirebaseAuth.instance.currentUser;
      if (currentFirebaseUser == null) {
        throw Exception('No user logged in');
      }

      _currentUserId = currentFirebaseUser.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _currentUser = Userr.fromJson(userDoc.data() as Map<String, dynamic>);
        });
      } else {
        throw Exception('User document not found');
      }
    } catch (e) {
      debugPrint('Error initializing current user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load user profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<Userr>> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    setState(() => _isLoading = true);
    List<Userr> results = [];

    try {
      final collection = FirebaseFirestore.instance.collection('users');
      final lowercaseQuery = query.trim().toLowerCase();

      // Use a compound query if possible to improve performance
      // First try searching by name fields directly
      QuerySnapshot nameSnapshot = await collection
          .where('searchable_name', arrayContains: lowercaseQuery)
          .limit(20)
          .get();

      // Convert documents to user objects
      results = nameSnapshot.docs
          .map((doc) => Userr.fromJson(doc.data() as Map<String, dynamic>))
          .where((user) => user.id != _currentUserId) // Exclude current user
          .toList();

      // If we don't have enough results, fetch more and filter manually
      if (results.length < 5) {
        // Get more users and filter locally
        final snapshot = await collection.limit(50).get();

        final filteredResults = snapshot.docs
            .map((doc) => Userr.fromJson(doc.data() as Map<String, dynamic>))
            .where((user) {
          // Skip if this is the current user
          if (user.id == _currentUserId) return false;

          // Skip if already in results
          if (results.any((existingUser) => existingUser.id == user.id)) {
            return false;
          }

          // Check user name
          final firstName = (user.first_name ?? '').toLowerCase();
          final middleName = (user.middle_name ?? '').toLowerCase();
          final lastName = (user.last_name ?? '').toLowerCase();
          final fullName = '$firstName $middleName $lastName'.toLowerCase();

          bool nameMatch = firstName.contains(lowercaseQuery) ||
              lastName.contains(lowercaseQuery) ||
              (middleName.isNotEmpty && middleName.contains(lowercaseQuery)) ||
              fullName.contains(lowercaseQuery);

          // Check company names
          bool companyMatch = false;
          if (user.proffesional_details != null) {
            companyMatch = user.proffesional_details!.any((detail) {
              final company =
                  (detail['company'] ?? '').toString().toLowerCase();
              final jobTitle =
                  (detail['job_title'] ?? '').toString().toLowerCase();
              return company.contains(lowercaseQuery) ||
                  jobTitle.contains(lowercaseQuery);
            });
          }

          // Check education details
          bool educationMatch = false;
          if (user.educational_details != null) {
            educationMatch = user.educational_details!.any((detail) {
              final institution =
                  (detail['institution'] ?? '').toString().toLowerCase();
              final degree = (detail['degree'] ?? '').toString().toLowerCase();
              return institution.contains(lowercaseQuery) ||
                  degree.contains(lowercaseQuery);
            });
          }

          // Return true if any of the criteria match
          return nameMatch || companyMatch || educationMatch;
        }).toList();

        // Add filtered results to the main results list
        results.addAll(filteredResults);

        // Limit to 20 results
        if (results.length > 20) {
          results = results.sublist(0, 20);
        }
      }

      // Clear connection status cache when searching new users
      //_connectionStatusCache.clear();

      // Prefetch connection status for all results
      for (var user in results) {
        if (user.id != null) {
          _checkConnectionStatus(user.id!);
        }
      }
    } catch (e) {
      debugPrint('Error searching users: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error searching users. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
    return results;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _searchQuery = query;
    });

    searchUsers(query).then((results) {
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    });
  }

  // Check if users are connected, have a pending request, or neither
  Future<String> _checkConnectionStatus(String userId) async {
    // Return cached result if available to improve performance

    try {
      // First check if they are already connected (in each other's connections list)
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();

      if (currentUserDoc.exists) {
        final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
        /*final connections =
            currentUserData['users'] as Map<String, dynamic>? ?? {};*/
        final addedUsers =
            (currentUserData['addedUsers'] as List<dynamic>?) ?? [];

        if (addedUsers.contains(userId)) {
          // They are already connected
          //_connectionStatusCache[userId] = 'connected';
          return 'connected';
        }
      }

      // Then check if there's a pending connection request
      final pendingRequestsSnapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('type', isEqualTo: 1) // 1 for connection request
          .where('isAccepted', isEqualTo: false)
          .get();

      for (var doc in pendingRequestsSnapshot.docs) {
        final notification = doc.data();

        // Check if current user sent request to this user
        if (notification['triggerUserId'] == _currentUserId &&
            notification['userId'] == userId) {
          //_connectionStatusCache[userId] = 'pending';
          return 'pending';
        }

        // Check if this user sent request to current user
        if (notification['userId'] == _currentUserId &&
            notification['triggerUserId'] == userId) {
          //_connectionStatusCache[userId] = 'pending';
          return 'pending';
        }
      }

      // No connection found
      //_connectionStatusCache[userId] = 'none';
      return 'none';
    } catch (e) {
      debugPrint('Error checking connection status: $e');
      return 'none';
    }
  }

  Future<void> _sendConnectionRequest(Userr user) async {
    if (_currentUser == null || user.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot send request: user profile not loaded'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set connecting state for this specific user
    //setState(() => _isConnectingMap[user.id!] = true);

    try {
      // First check if users are already connected
      final currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUserId)
          .get();

      if (currentUserDoc.exists) {
        final currentUserData = currentUserDoc.data() as Map<String, dynamic>;
        /*final connections =
            currentUserData['connections'] as List<dynamic>? ?? [];*/
        final addedUsers =
            (currentUserData['addedUsers'] as List<dynamic>?) ?? [];

        if (addedUsers.contains(user.id)) {
          // They are already connected
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('You are already connected with ${user.first_name}'),
              backgroundColor: Colors.orange,
            ),
          );
          // Update connection status cache
          //_connectionStatusCache[user.id!] = 'connected';
          //setState(() => _isConnectingMap[user.id!] = false);
          return;
        }
      }

      // Then check if there's already a pending connection request
      final existingRequests = await FirebaseFirestore.instance
          .collection('notifications')
          .where('type', isEqualTo: 1) // 1 for connection request
          .get();

      bool requestExists = false;
      for (var doc in existingRequests.docs) {
        final notification = doc.data();

        // Check if current user already sent request to this user
        if ((notification['triggerUserId'] == _currentUserId &&
            notification['userId'] == user.id)) {
          requestExists = true;
          break;
        }

        // Check if this user already sent request to current user
        if ((notification['userId'] == _currentUserId &&
            notification['triggerUserId'] == user.id)) {
          requestExists = true;
          break;
        }
      }

      if (requestExists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Connection request with ${user.first_name} already exists'),
            backgroundColor: Colors.orange,
          ),
        );
        // Update connection status cache
        //_connectionStatusCache[user.id!] = 'pending';
        //setState(() => _isConnectingMap[user.id!] = false);
        return;
      }

      // If no existing connection or request, create a new connection request
      final connectionRequest = Notificationn(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id!,
        triggerUserId: _currentUserId,
        triggerUserName: _currentUser?.first_name ?? 'User',
        isAccepted: false,
        type: 1, // 1 for request
        timeStamp: DateTime.now(),
        isRead: false,
      );

      // Send the connection request to Firestore
      await FirebaseFirestore.instance
          .collection('notifications')
          .add(connectionRequest.toJson());

      // Update connection status cache
      //_connectionStatusCache[user.id!] = 'pending';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection request sent to ${user.first_name}'),
          backgroundColor: linkedInBlue,
        ),
      );

      // Force UI refresh
      setState(() {});
    } catch (e) {
      debugPrint('Error sending connection request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connection request failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      /*if (mounted) {
        setState(() => _isConnectingMap[user.id!] = false);
      }*/
    }
  }

  void _navigateToMessageScreen(Userr user) {
    // Implement navigation to message screen
    // This is a placeholder - you'll need to implement the actual messaging screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with ${user.first_name}'),
        backgroundColor: linkedInBlue,
      ),
    );

    // TODO: Add navigation to message screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(recieverUID: user.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.search, color: linkedInBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              'Search',
              style: TextStyle(
                color: linkedInBlue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Box
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name, company, or education',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      filled: true,
                      fillColor: whiteBackground,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderGrey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: borderGrey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: linkedInBlue),
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: linkedInBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Results or Initial State
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    // Show loading indicator
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: linkedInBlue),
      );
    }

    // Initial state - no search performed yet
    if (_searchQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Search for connections',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter name, company, education, or qualification',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // No results found
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results found for "$_searchQuery"',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try using different keywords',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    // Display search results
    return ListView.builder(
      itemCount: _searchResults.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(Userr user) {
    // Get current job if available
    String? currentPosition;
    String? currentCompany;

    if (user.proffesional_details != null &&
        user.proffesional_details!.isNotEmpty) {
      // Filter out null or empty values
      final details = user.proffesional_details!.firstWhere(
        (detail) =>
            (detail['job_title'] != null &&
                detail['job_title'].toString().isNotEmpty) ||
            (detail['company'] != null &&
                detail['company'].toString().isNotEmpty),
        orElse: () => {},
      );

      currentPosition = details['job_title']?.toString();
      currentCompany = details['company']?.toString();
    }

    // Get latest education if available
    String? latestEducation;

    if (user.educational_details != null &&
        user.educational_details!.isNotEmpty) {
      final edu = user.educational_details![0];
      final institution = edu['institution']?.toString();
      final degree = edu['degree']?.toString();

      if (institution != null && institution.isNotEmpty) {
        latestEducation = institution;
        if (degree != null && degree.isNotEmpty) {
          latestEducation = '$latestEducation, $degree';
        }
      }
    }

    // Format full name properly
    final firstName = user.first_name?.trim() ?? '';
    final middleName = user.middle_name?.trim() ?? '';
    final lastName = user.last_name?.trim() ?? '';

    String fullName = firstName;
    if (middleName.isNotEmpty) fullName += ' $middleName';
    if (lastName.isNotEmpty) fullName += ' $lastName';

    if (fullName.trim().isEmpty) {
      fullName = 'User';
    }

    // Track if we're connecting with this user
    //bool isConnecting = _isConnectingMap[user.id] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderGrey),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to user profile
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(user: user),
            ),
          ).then((_) {
            // Refresh connection status when returning from profile
            if (user.id != null) {
              //_connectionStatusCache.remove(user.id);
              setState(() {});
            }
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile image
              Hero(
                tag: 'profile-${user.id}',
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[300],
                    image: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(user.imageUrl!),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {
                              // Handle image loading error silently
                            },
                          )
                        : null,
                  ),
                  child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                      ? Icon(Icons.person, size: 36, color: Colors.grey[600])
                      : null,
                ),
              ),
              const SizedBox(width: 16),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Current position
                    if (currentPosition != null || currentCompany != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          [currentPosition, currentCompany]
                              .where((item) => item != null && item.isNotEmpty)
                              .join(' at '),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Education
                    if (latestEducation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          latestEducation,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              // Connect/Message button
              if (user.id != null)
                FutureBuilder<String>(
                  future: _checkConnectionStatus(user.id!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                            ConnectionState
                                .waiting /*||
                        isConnecting*/
                        ) {
                      return SizedBox(
                        height: 36,
                        width: 80, // Fixed width to prevent layout jumps
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: linkedInBlue,
                            ),
                          ),
                        ),
                      );
                    }

                    final status = snapshot.data ?? 'none';

                    if (status == 'connected') {
                      // Already connected - show message button
                      return ElevatedButton.icon(
                        onPressed: () => _navigateToMessageScreen(user),
                        icon:
                            Icon(Icons.message, size: 16, color: Colors.white),
                        label: const Text('Message'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: linkedInBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 0,
                        ),
                      );
                    } else if (status == 'pending') {
                      // Pending connection - show pending button
                      return ElevatedButton(
                        onPressed: null, // Disabled
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.grey[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 0,
                        ),
                        child: const Text('Pending'),
                      );
                    } else {
                      // Not connected - show connect button
                      return ElevatedButton(
                        onPressed: () => _sendConnectionRequest(user),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: linkedInBlue,
                          side: BorderSide(color: linkedInBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 0,
                        ),
                        child: const Text('Connect'),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
