import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/home_screen.dart';
import 'package:connectapp/screens/onboarding/interest.dart';
import 'package:connectapp/widgets/onboarding/education.dart';
import 'package:connectapp/widgets/onboarding/proffesion.dart';
import 'package:flutter/material.dart';

class Onboard_screen4 extends StatefulWidget {
  final Userr? user;
  const Onboard_screen4({super.key, required this.user});

  @override
  State<Onboard_screen4> createState() => _Onboard_screen4State();
}

class _Onboard_screen4State extends State<Onboard_screen4> {
  List<Map<String, dynamic>> educationList = [];

  // LinkedIn colors
  final Color linkedInBlue = Color(0xFF0077B5);
  final Color lightBlue = Color(0xFF0A66C2);
  final Color whiteBackground = Color(0xFFF3F2EF);
  final Color borderGrey = Color(0xFFE1E9EE);

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
      educationList.removeAt(index);
    });
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
              'Connect',
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

              // Experience tiles
              ...educationList.asMap().entries.map((entry) {
                final index = entry.key;
                final exp = entry.value;
                // Use the new ProfessionTile widget
                return EducationTile(
                  institutionController: exp['institution'],
                  qualificationController: exp['qualification'],
                  specializationController: exp['specialization'],
                  achievementsController: exp['achievements'],
                  startDate: exp['startDate'],
                  endDate: exp['endDate'],
                  onStartDateChanged: (date) {
                    setState(() => educationList[index]['startDate'] = date);
                  },
                  onEndDateChanged: (date) {
                    setState(() => educationList[index]['endDate'] = date);
                  },
                );
              }),

              // Add more experience button (LinkedIn style)
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

              if (educationList.length > 1)
                // Remove last experience button (LinkedIn style)
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
              // Submit button (LinkedIn style)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
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

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Onboard_screen5(
                                  user: widget.user,
                                )));
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
                    'Next',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Onboard_screen5(
                                  user: widget.user,
                                )));
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
            ],
          ),
        ),
      ),
    );
  }
}
