import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/screens/profile/edit_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connectapp/model/user/user_model.dart';

class ProfilePage extends StatefulWidget {
  final Userr user;

  ProfilePage({required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<String?> getUserImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc['imageUrl'];
  }

  late Userr currentUser;

  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  // LinkedIn colors from your onboarding screen
  final Color linkedInBlue = Color(0xFF0077B5);

  final Color lightBlue = Color(0xFF0A66C2);

  final Color whiteBackground = Color(0xFFF3F2EF);

  final Color borderGrey = Color(0xFFE1E9EE);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Icon(Icons.person_outline, color: linkedInBlue, size: 24),
            const SizedBox(width: 10),
            Text(
              'Profile',
              style: TextStyle(
                color: linkedInBlue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          if (currentUser.id == FirebaseAuth.instance.currentUser?.uid)
            IconButton(
              icon: Icon(Icons.edit, color: linkedInBlue),
              onPressed: () async {
                final updatedUser = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileEditPage(user: currentUser),
                  ),
                );
                if (updatedUser != null) {
                  setState(() {
                    currentUser = updatedUser;
                  });
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildAboutSection(),
            const SizedBox(height: 16),
            _buildProfessionalSection(),
            const SizedBox(height: 16),
            _buildEducationSection(),
            const SizedBox(height: 16),
            _buildInterestSection(),
            const SizedBox(height: 16),
            _buildLocationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: borderGrey)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Cover image
          Container(
            height: 100,
            width: double.infinity,
            color: lightBlue.withOpacity(0.1),
          ),

          // Profile image and name
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  margin: EdgeInsets.only(top: 60),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    color: Colors.grey[300],
                    image: NetworkImage(currentUser.imageUrl!) != null
                        ? DecorationImage(
                            image: NetworkImage(currentUser.imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: currentUser.imageUrl == null
                      ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFullName(),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      if (currentUser.proffesional_details != null &&
                          currentUser.proffesional_details!.isNotEmpty &&
                          currentUser.proffesional_details![0]['title'] != null)
                        Text(
                          currentUser.proffesional_details![0]['title'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      if (currentUser.proffesional_details != null &&
                          currentUser.proffesional_details!.isNotEmpty &&
                          currentUser.proffesional_details![0]['company'] !=
                              null)
                        Text(
                          currentUser.proffesional_details![0]['company'],
                          style: TextStyle(
                            fontSize: 14,
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

  Widget _buildInfoItem(IconData icon, String title, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(Icons.email_outlined, 'Email', currentUser.email),
          _buildInfoItem(Icons.phone_outlined, 'Phone', currentUser.phone),
        ],
      ),
    );
  }

  Widget _buildProfessionalSection() {
    if (currentUser.proffesional_details == null ||
        currentUser.proffesional_details!.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Professional Experience',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ...currentUser.proffesional_details!
              .map((exp) => _buildExperienceItem(exp))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildExperienceItem(Map<String, dynamic> experience) {
    final jobTitle = experience['title'] ?? 'Role';
    final company = experience['company'] ?? 'Company';

    // Fixed the date handling
    String fromDate = '';
    if (experience['startDate'] != null) {
      // Check the type and extract year appropriately
      if (experience['startDate'] is DateTime) {
        fromDate = (experience['startDate'] as DateTime).year.toString();
      } else {
        // If it's a Timestamp from Firestore that has toDate() method
        try {
          // Use dynamic to bypass the static type check
          dynamic startDate = experience['startDate'];
          fromDate = startDate.toDate().year.toString();
        } catch (e) {
          // If toDate() fails or for any other format, try to handle generically
          fromDate = experience['startDate'].toString();
        }
      }
    }

    String toDate = 'Present';
    if (experience['endDate'] != null) {
      // Check the type and extract year appropriately
      if (experience['endDate'] is DateTime) {
        toDate = (experience['endDate'] as DateTime).year.toString();
      } else {
        // If it's a Timestamp from Firestore that has toDate() method
        try {
          // Use dynamic to bypass the static type check
          dynamic endDate = experience['endDate'];
          toDate = endDate.toDate().year.toString();
        } catch (e) {
          // If toDate() fails or for any other format
          toDate = experience['endDate'].toString();
        }
      }
    }

    final description = experience['description'] ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderGrey),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.business, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  company,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '$fromDate - $toDate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    if (currentUser.educational_details == null ||
        currentUser.educational_details!.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ...currentUser.educational_details!
              .map((edu) => _buildEducationItem(edu))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildEducationItem(Map<String, dynamic> education) {
    final institution = education['institution'] ?? 'Institution';
    final degree = education['qualification'] ?? '';
    final fieldOfStudy = education['specialization'] ?? '';

    // Fixed the date handling for education dates
    String fromYear = '';
    if (education['startDate'] != null) {
      // Check the type and extract year appropriately
      if (education['startDate'] is DateTime) {
        fromYear = (education['startDate'] as DateTime).year.toString();
      } else {
        // If it's a Timestamp from Firestore that has toDate() method
        try {
          // Use dynamic to bypass the static type check
          dynamic startDate = education['startDate'];
          fromYear = startDate.toDate().year.toString();
        } catch (e) {
          // If toDate() fails or for any other format
          fromYear = education['startDate'].toString();
        }
      }
    }

    String toYear = 'Present';
    if (education['endDate'] != null) {
      // Check the type and extract year appropriately
      if (education['endDate'] is DateTime) {
        toYear = (education['endDate'] as DateTime).year.toString();
      } else {
        // If it's a Timestamp from Firestore that has toDate() method
        try {
          // Use dynamic to bypass the static type check
          dynamic endDate = education['endDate'];
          toYear = endDate.toDate().year.toString();
        } catch (e) {
          // If toDate() fails or for any other format
          toYear = education['endDate'].toString();
        }
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderGrey),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.school, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  institution,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                if (degree.isNotEmpty)
                  Text(
                    degree + (fieldOfStudy.isNotEmpty ? ', $fieldOfStudy' : ''),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                Text(
                  '$fromYear - $toYear',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestSection() {
    List<String>? interestsList;

    try {
      interestsList = currentUser.interests;
      print(interestsList?.length ?? "");
    } catch (e) {
      // Interests property doesn't exist in this way
      print("Could not access interests as List<String>: $e");
    }

    // If we couldn't get interests by any method, return empty widget
    final interests = interestsList;
    if (interests == null || interests.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          ...interests
              .map((interest) => _buildInterestItem(interest.toString()))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildInterestItem(String interest) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderGrey),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.star, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              interest,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    if (currentUser.address_details == null) {
      return SizedBox.shrink();
    }

    final address = currentUser.address_details!;
    final city = address['city'] ?? '';
    final state = address['state'] ?? '';
    final country = address['country'] ?? '';

    String locationText = '';
    if (city.isNotEmpty) locationText += city;
    if (state.isNotEmpty)
      locationText += locationText.isNotEmpty ? ', $state' : state;
    if (country.isNotEmpty)
      locationText += locationText.isNotEmpty ? ', $country' : country;

    if (locationText.isEmpty) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                locationText,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getFullName() {
    String name = currentUser.first_name ?? '';
    if (currentUser.middle_name != null &&
        currentUser.middle_name!.isNotEmpty) {
      name += ' ${currentUser.middle_name}';
    }
    if (currentUser.last_name != null && currentUser.last_name!.isNotEmpty) {
      name += ' ${currentUser.last_name}';
    }
    return name;
  }
}
