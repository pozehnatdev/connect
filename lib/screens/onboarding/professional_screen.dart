import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/onboarding/education_screen.dart';
import 'package:connectapp/widgets/onboarding/proffesion.dart';
import 'package:flutter/material.dart';

// Note: Make sure to update the import to use the new ProfessionTile widget
// import 'package:connectapp/widgets/onboarding/profession.dart';

class Onboard_screen3 extends StatefulWidget {
  final Userr? user;
  const Onboard_screen3({super.key, required this.user});

  @override
  State<Onboard_screen3> createState() => _Onboard_screen3State();
}

class _Onboard_screen3State extends State<Onboard_screen3> {
  List<Map<String, dynamic>> experienceList = [];

  // LinkedIn colors
  final Color linkedInBlue = Color(0xFF0077B5);
  final Color lightBlue = Color(0xFF0A66C2);
  final Color whiteBackground = Color(0xFFF3F2EF);
  final Color borderGrey = Color(0xFFE1E9EE);

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
      experienceList.removeAt(index);
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
                // Use the new ProfessionTile widget
                return ProfessionTile(
                  companyController: exp['company'],
                  titleController: exp['title'],
                  descriptionController: exp['description'],
                  startDate: exp['startDate'],
                  endDate: exp['endDate'],
                  onStartDateChanged: (date) {
                    setState(() => experienceList[index]['startDate'] = date);
                  },
                  onEndDateChanged: (date) {
                    setState(() => experienceList[index]['endDate'] = date);
                  },
                );
              }),

              // Add more experience button (LinkedIn style)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12, bottom: 12),
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
              if (experienceList.length > 1)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
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
              // Submit button (LinkedIn style)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Save the professional experience data
                    // This is where you would typically save the experience data to the user model
                    // and navigate to the next screen or complete the onboarding process
                    widget.user!.proffesional_details =
                        experienceList.map((exp) {
                      return {
                        'company': exp['company'].text,
                        'title': exp['title'].text,
                        'description': exp['description'].text,
                        'startDate': exp['startDate'],
                        'endDate': exp['endDate'],
                      };
                    }).toList();

                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Onboard_screen4(
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
                            builder: (context) => Onboard_screen4(
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
