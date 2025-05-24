import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/onboarding/education_screen.dart';
import 'package:connectapp/screens/profile/edit_profile.dart';
import 'package:connectapp/widgets/onboarding/proffesion.dart';
import 'package:flutter/material.dart';

class AddProfesion extends StatefulWidget {
  final Userr? user;
  const AddProfesion({super.key, required this.user});

  @override
  State<AddProfesion> createState() => _AddProfesionState();
}

class _AddProfesionState extends State<AddProfesion> {
  List<Map<String, dynamic>> experienceList = [];

  // LinkedIn colors
  final Color linkedInBlue = const Color(0xFF0077B5);
  final Color lightBlue = const Color(0xFF0A66C2);
  final Color whiteBackground = const Color(0xFFF3F2EF);
  final Color borderGrey = const Color(0xFFE1E9EE);

  @override
  void initState() {
    super.initState();
    addExperienceTile(); // Add first by default
  }

  void addExperienceTile() {
    setState(() {
      experienceList.add({
        'company': TextEditingController(),
        'title': TextEditingController(),
        'description': TextEditingController(),
        'startDate': null,
        'endDate': null,
      });
    });
  }

  void removeExperienceTile(int index) {
    setState(() {
      final removed = experienceList.removeAt(index);
      // Dispose controllers when removed
      removed['company']?.dispose();
      removed['title']?.dispose();
      removed['description']?.dispose();
    });
  }

  Future<void> addExperienceToFirebase() async {
    try {
      // Create the experience data
      List<Map<String, dynamic>> professionalDetails =
          experienceList.map((exp) {
        return {
          'company': (exp['company'] as TextEditingController).text,
          'title': (exp['title'] as TextEditingController).text,
          'description': (exp['description'] as TextEditingController).text,
          'startDate': exp['startDate'],
          'endDate': exp['endDate'],
        };
      }).toList();

      // Update user's professional details locally
      widget.user!.proffesional_details = professionalDetails;

      // Save to Firebase
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.id)
          .update({
        'proffesional_details': professionalDetails,
      });

      print('Professional details saved successfully');
    } catch (e) {
      print('Error saving professional details: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving experience: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    for (final exp in experienceList) {
      exp['company']?.dispose();
      exp['title']?.dispose();
      exp['description']?.dispose();
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
            Icon(Icons.work, color: linkedInBlue, size: 24),
            const SizedBox(width: 8),
            Text(
              'Add Profession',
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
                'Experience',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add your work experience',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Experience tiles
              ...experienceList.asMap().entries.map((entry) {
                final index = entry.key;
                final exp = entry.value;
                return ProfessionTile(
                  companyController: exp['company'] as TextEditingController,
                  titleController: exp['title'] as TextEditingController,
                  descriptionController:
                      exp['description'] as TextEditingController,
                  startDate: exp['startDate'] as DateTime?,
                  endDate: exp['endDate'] as DateTime?,
                  onStartDateChanged: (date) {
                    setState(() => experienceList[index]['startDate'] = date);
                  },
                  onEndDateChanged: (date) {
                    setState(() => experienceList[index]['endDate'] = date);
                  },
                );
              }),

              // Add more experience button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  onPressed: addExperienceTile,
                  icon: Icon(Icons.add, color: linkedInBlue),
                  label: Text(
                    "Add another position",
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

              // Remove button (only show if more than one experience)
              if (experienceList.length > 1)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        removeExperienceTile(experienceList.length - 1),
                    icon: Icon(Icons.remove, color: linkedInBlue),
                    label: Text(
                      "Remove last position",
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

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Save experience to Firebase and then navigate back
                    await addExperienceToFirebase();

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
                    'Save Experience',
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
