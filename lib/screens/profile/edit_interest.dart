import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:flutter/material.dart';

class EditInterestsScreen extends StatefulWidget {
  final Userr user;
  const EditInterestsScreen({super.key, required this.user});

  @override
  State<EditInterestsScreen> createState() => _EditInterestsScreenState();
}

class _EditInterestsScreenState extends State<EditInterestsScreen> {
  late TextEditingController _interestController;
  late List<String> selectedInterests;
  int maxInterests = 50;

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

  final Color linkedInBlue = Color(0xFF0077B5);
  final Color borderGrey = Color(0xFFE1E9EE);
  final Color darkGrey = Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    selectedInterests = List.from(widget.user.interests ?? []);
    _interestController = TextEditingController();
  }

  void addInterest(String interest) {
    if (interest.isNotEmpty &&
        !selectedInterests.contains(interest) &&
        selectedInterests.length < maxInterests) {
      setState(() {
        selectedInterests.add(interest);
        _interestController.clear();
      });
    }
  }

  void removeInterest(String interest) {
    setState(() {
      selectedInterests.remove(interest);
    });
  }

  Future<void> _saveInterests() async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.user.id)
          .update({'interests': selectedInterests});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Interests updated successfully!'),
          backgroundColor: linkedInBlue,
        ),
      );

      Navigator.pop(context, selectedInterests);
    } catch (error) {
      print("Failed to update interests: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update interests'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Interests',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveInterests,
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
      body: _buildInterestEditor(),
    );
  }

  Widget _buildInterestEditor() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _interestController,
            decoration: InputDecoration(
              hintText: 'Add new interest',
              suffixIcon: IconButton(
                icon: Icon(Icons.add),
                onPressed: () => addInterest(_interestController.text),
              ),
            ),
            onSubmitted: addInterest,
          ),
          SizedBox(height: 16),
          Text(
            'Selected Interests (${selectedInterests.length}/$maxInterests)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedInterests
                .map((interest) => Chip(
                      label: Text(interest),
                      deleteIcon: Icon(Icons.close),
                      onDeleted: () => removeInterest(interest),
                    ))
                .toList(),
          ),
          SizedBox(height: 24),
          Text('Suggested Interests',
              style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestedSkills
                .map((skill) => FilterChip(
                      label: Text(skill),
                      selected: selectedInterests.contains(skill),
                      onSelected: (selected) {
                        if (selected) {
                          addInterest(skill);
                        } else {
                          removeInterest(skill);
                        }
                      },
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
