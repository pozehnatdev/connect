import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/home_screen.dart';
import 'package:flutter/material.dart';

class Onboard_screen5 extends StatefulWidget {
  final Userr? user;
  const Onboard_screen5({super.key, required this.user});

  @override
  State<Onboard_screen5> createState() => _Onboard_screen5State();
}

class _Onboard_screen5State extends State<Onboard_screen5> {
  TextEditingController _interestController = TextEditingController();
  List<String> selectedSkills = [];
  int maxInterests = 50;

  // Suggested interests based on profile
  final List<String> suggestedSkills = [
    'Singing',
    'Dancing',
    'Cricket',
    'Photography',
    'Cooking',
    'Painting',
    'Reading',
    'Swimming',
    'Hiking',
    'Yoga',
    'Gardening',
    'Chess',
    'Football',
    'Basketball',
    'Writing',
    'Traveling',
    'Gaming',
    'Music',
    'Cycling',
    'Meditation'
  ];

  // LinkedIn colors
  final Color linkedInBlue = Color(0xFF0077B5);
  final Color lightBlue = Color(0xFF0A66C2);
  final Color whiteBackground = Color(0xFFF3F2EF);
  final Color borderGrey = Color(0xFFE1E9EE);
  final Color darkGrey = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    // Add Singing as a default selected interest for demo purposes
    selectedSkills.add('Singing');
  }

  void addInterest(String interest) {
    if (interest.isNotEmpty &&
        !selectedSkills.contains(interest) &&
        selectedSkills.length < maxInterests) {
      setState(() {
        selectedSkills.add(interest);
        _interestController.clear();
      });
    }
  }

  void removeInterest(String interest) {
    setState(() {
      selectedSkills.remove(interest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Interest',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Save selected skills to user model
              widget.user!.interests = selectedSkills;

              // Save to Firestore
              FirebaseFirestore.instance
                  .collection("users")
                  .doc(widget.user!.id)
                  .set(widget.user!.toJson())
                  .then((value) => print("User Interests Added"))
                  .catchError(
                      (error) => print("Failed to add interests: $error"));

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Interests saved successfully!'),
                  backgroundColor: linkedInBlue,
                ),
              );

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
                (route) => false,
              );
            },
            child: Text(
              'Save',
              style: TextStyle(
                color: linkedInBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification banner
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.grey[100],
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'We no longer share changes to interests with your network. ',
                      style: TextStyle(
                        color: darkGrey,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    'Learn what\'s shared',
                    style: TextStyle(
                      color: linkedInBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: borderGrey),

            // Skill input field
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _interestController,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Interest (ex: Photography)',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                onSubmitted: (value) => addInterest(value),
              ),
            ),

            // Remaining interests count
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'You can add ${maxInterests - selectedSkills.length} more interests',
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 14,
                ),
              ),
            ),

            // Selected skills
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedSkills.map((skill) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          skill,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            Divider(height: 24, thickness: 1, color: borderGrey),

            // Suggested interests section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Suggested interests based off your profile:',
                style: TextStyle(
                  color: darkGrey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Suggested skills list
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: suggestedSkills.map((skill) {
                      final isSelected = selectedSkills.contains(skill);
                      return GestureDetector(
                        onTap: () {
                          if (isSelected) {
                            removeInterest(skill);
                          } else {
                            addInterest(skill);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.green : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isSelected ? Colors.green : Colors.grey[400]!,
                            ),
                          ),
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                skill,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (isSelected) ...[
                                SizedBox(width: 4),
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ] else ...[
                                SizedBox(width: 4),
                                Icon(
                                  Icons.add,
                                  color: Colors.grey[700],
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Add button at the bottom
            Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_interestController.text.isNotEmpty) {
                      addInterest(_interestController.text);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: linkedInBlue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Add',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
