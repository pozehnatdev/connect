import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/onboarding/education_screen.dart';
import 'package:connectapp/widgets/onboarding/proffesion.dart';
import 'package:flutter/material.dart';

class EditProfesion extends StatefulWidget {
  final Userr user;
  const EditProfesion({super.key, required this.user});

  @override
  State<EditProfesion> createState() => _EditProfesionState();
}

class _EditProfesionState extends State<EditProfesion> {
  late List<Map<String, dynamic>> experienceList;
  final Color linkedInBlue = const Color(0xFF0077B5);
  final Color whiteBackground = const Color(0xFFF3F2EF);

  @override
  void initState() {
    super.initState();
    // Initialize with existing data and create controllers
    experienceList = widget.user.proffesional_details?.map((detail) {
          return {
            'company': TextEditingController(
                text: detail['company']?.toString() ?? ''),
            'title':
                TextEditingController(text: detail['title']?.toString() ?? ''),
            'description': TextEditingController(
                text: detail['description']?.toString() ?? ''),
            'startDate': _parseDate(detail['startDate']),
            'endDate': _parseDate(detail['endDate']),
          };
        }).toList() ??
        [];
  }

  DateTime? _parseDate(dynamic date) {
    if (date is DateTime) return date;
    if (date is Timestamp) return date.toDate();
    return null;
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

  Future<void> updateExperience() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .update({
      'proffesional_details': widget.user.proffesional_details,
    });
  }

  @override
  void dispose() {
    // Dispose all controllers
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
            Text('Edit Profession',
                style: TextStyle(
                    color: linkedInBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Experience',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800])),
              const SizedBox(height: 8),
              Text('Add your work experience',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              const SizedBox(height: 24),
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
                  onStartDateChanged: (date) =>
                      setState(() => experienceList[index]['startDate'] = date),
                  onEndDateChanged: (date) =>
                      setState(() => experienceList[index]['endDate'] = date),
                );
              }),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                child: OutlinedButton.icon(
                  onPressed: addExperienceTile,
                  icon: Icon(Icons.add, color: linkedInBlue),
                  label: Text("Add another position",
                      style: TextStyle(color: linkedInBlue)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: linkedInBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
              if (experienceList.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 12),
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        removeExperienceTile(experienceList.length - 1),
                    icon: Icon(Icons.remove, color: linkedInBlue),
                    label: Text("Remove last position",
                        style: TextStyle(color: linkedInBlue)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: linkedInBlue),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24)),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Save all changes
                    widget.user.proffesional_details =
                        experienceList.map((exp) {
                      return {
                        'company': exp['company'].text,
                        'title': exp['title'].text,
                        'description': exp['description'].text,
                        'startDate': exp['startDate'],
                        'endDate': exp['endDate'],
                      };
                    }).toList();

                    updateExperience();

                    Navigator.pop(
                      context,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: linkedInBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Update Profession',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
