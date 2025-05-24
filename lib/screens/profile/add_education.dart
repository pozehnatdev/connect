import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/home_screen.dart';
import 'package:connectapp/screens/onboarding/interest.dart';
import 'package:connectapp/widgets/onboarding/education.dart';
import 'package:connectapp/widgets/onboarding/proffesion.dart';
import 'package:flutter/material.dart';

class AddEducation extends StatefulWidget {
  final Userr? user;
  const AddEducation({super.key, required this.user});

  @override
  State<AddEducation> createState() => _AddEducationState();
}

class _AddEducationState extends State<AddEducation> {
  List<Map<String, dynamic>> educationList = [];

  // LinkedIn colors
  final Color linkedInBlue = const Color(0xFF0077B5);
  final Color lightBlue = const Color(0xFF0A66C2);
  final Color whiteBackground = const Color(0xFFF3F2EF);
  final Color borderGrey = const Color(0xFFE1E9EE);

  @override
  void initState() {
    super.initState();
    addEducationTile(); // Add first by default
  }

  void addEducationTile() {
    setState(() {
      educationList.add({
        'institution': TextEditingController(),
        'qualification': TextEditingController(),
        'specialization': TextEditingController(),
        'achievements': TextEditingController(),
        'startDate': null,
        'endDate': null,
      });
    });
  }

  void removeEducationTile(int index) {
    setState(() {
      final removed = educationList.removeAt(index);
      // Dispose controllers when removed
      removed['institution']?.dispose();
      removed['qualification']?.dispose();
      removed['specialization']?.dispose();
      removed['achievements']?.dispose();
    });
  }

  Future<void> addEducationToFirebase() async {
    try {
      // Create the education data
      List<Map<String, dynamic>> educationalDetails = educationList.map((edu) {
        return {
          'institution': (edu['institution'] as TextEditingController).text,
          'qualification': (edu['qualification'] as TextEditingController).text,
          'specialization':
              (edu['specialization'] as TextEditingController).text,
          'achievements': (edu['achievements'] as TextEditingController).text,
          'startDate': edu['startDate'],
          'endDate': edu['endDate'],
        };
      }).toList();

      // Update user's educational details locally
      widget.user!.educational_details = educationalDetails;

      // Save to Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.id)
          .update({
        'educational_details': educationalDetails,
      });

      print('Educational details saved successfully');
    } catch (e) {
      print('Error saving educational details: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving education: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    for (final edu in educationList) {
      edu['institution']?.dispose();
      edu['qualification']?.dispose();
      edu['specialization']?.dispose();
      edu['achievements']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.school, color: linkedInBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              'Add Education',
              style: TextStyle(
                color: linkedInBlue,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Education',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your Educational detail',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Education tiles
              ...educationList.asMap().entries.map((entry) {
                final index = entry.key;
                final edu = entry.value;
                return EducationTile(
                  institutionController:
                      edu['institution'] as TextEditingController,
                  qualificationController:
                      edu['qualification'] as TextEditingController,
                  specializationController:
                      edu['specialization'] as TextEditingController,
                  achievementsController:
                      edu['achievements'] as TextEditingController,
                  startDate: edu['startDate'] as DateTime?,
                  endDate: edu['endDate'] as DateTime?,
                  onStartDateChanged: (date) {
                    setState(() => educationList[index]['startDate'] = date);
                  },
                  onEndDateChanged: (date) {
                    setState(() => educationList[index]['endDate'] = date);
                  },
                );
              }),

              // Add more education button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  onPressed: addEducationTile,
                  icon: Icon(Icons.add, color: linkedInBlue),
                  label: Text(
                    "Add another education",
                    style: TextStyle(color: linkedInBlue),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: linkedInBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),

              // Remove button (only show if more than one education)
              if (educationList.length > 1)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        removeEducationTile(educationList.length - 1),
                    icon: Icon(Icons.remove, color: linkedInBlue),
                    label: Text(
                      "Remove last education",
                      style: TextStyle(color: linkedInBlue),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: linkedInBlue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Save education to Firebase and then navigate back
                    await addEducationToFirebase();

                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: linkedInBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save Education',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
