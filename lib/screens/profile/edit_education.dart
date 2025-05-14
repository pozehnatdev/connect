import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/home_screen.dart';
import 'package:connectapp/screens/onboarding/interest.dart';
import 'package:connectapp/widgets/onboarding/education.dart';
import 'package:flutter/material.dart';

class EditEducation extends StatefulWidget {
  final Userr? user;
  const EditEducation({super.key, required this.user});

  @override
  State<EditEducation> createState() => _EditEducationState();
}

class _EditEducationState extends State<EditEducation> {
  late List<Map<String, dynamic>> educationList;

  // LinkedIn colors
  final Color linkedInBlue = Color(0xFF0077B5);
  final Color lightBlue = Color(0xFF0A66C2);
  final Color whiteBackground = Color(0xFFF3F2EF);
  final Color borderGrey = Color(0xFFE1E9EE);

  @override
  void initState() {
    super.initState();
    // Initialize with existing data and create controllers
    educationList = widget.user?.educational_details?.map((detail) {
          return {
            'institution': TextEditingController(
                text: detail['institution']?.toString() ?? ''),
            'qualification': TextEditingController(
                text: detail['qualification']?.toString() ?? ''),
            'specialization': TextEditingController(
                text: detail['specialization']?.toString() ?? ''),
            'achievements': TextEditingController(
                text: detail['achievements']?.toString() ?? ''),
            'startDate': _parseDate(detail['startDate']),
            'endDate': _parseDate(detail['endDate']),
          };
        }).toList() ??
        [];

    // Add first education entry if the list is empty
    if (educationList.isEmpty) {
      addEducationTile();
    }
  }

  DateTime? _parseDate(dynamic date) {
    if (date is DateTime) return date;
    if (date is Timestamp) return date.toDate();
    return null;
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

  Future<void> updateEducation() async {
    if (widget.user?.id != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.id)
          .update({
        'educational_details': widget.user!.educational_details,
      });
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
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
              'Edit Education',
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
                'Add your Educational details',
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
                  onStartDateChanged: (date) =>
                      setState(() => educationList[index]['startDate'] = date),
                  onEndDateChanged: (date) =>
                      setState(() => educationList[index]['endDate'] = date),
                );
              }),

              // Add more education button (LinkedIn style)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
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

              if (educationList.isNotEmpty)
                // Remove last education button (LinkedIn style)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
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

              // Update button (LinkedIn style)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.user != null) {
                      widget.user!.educational_details = educationList.map((e) {
                        return {
                          'institution': e['institution'].text,
                          'qualification': e['qualification'].text,
                          'specialization': e['specialization'].text,
                          'achievements': e['achievements'].text,
                          'startDate': e['startDate'],
                          'endDate': e['endDate'],
                        };
                      }).toList();

                      updateEducation();

                      // For Onboarding flow
                      if (widget.user?.interests == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Onboard_screen5(
                              user: widget.user,
                            ),
                          ),
                        );
                      } else {
                        // For Edit profile flow
                        Navigator.pop(context);
                      }
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
                  child: Text(
                    widget.user?.interests == null
                        ? 'Next'
                        : 'Update Education',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Only show Skip button during onboarding
              if (widget.user?.interests == null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Onboard_screen5(
                              user: widget.user,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: linkedInBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(color: linkedInBlue),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Skip',
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
      ),
    );
  }
}
