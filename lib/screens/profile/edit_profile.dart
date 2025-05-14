import 'package:connectapp/model/user/user_model.dart';
import 'package:connectapp/screens/profile/edit_education.dart';
import 'package:connectapp/screens/profile/edit_profesion.dart';
import 'package:connectapp/screens/profile/user_profile.dart';
import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  final Userr user;

  ProfileEditPage({required this.user});

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // Create controllers for all text fields
  late TextEditingController firstNameController;
  late TextEditingController middleNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  // Address controllers
  late TextEditingController address1Controller;
  late TextEditingController address2Controller;
  late TextEditingController address3Controller;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController pincodeController;
  late TextEditingController countryController;

  // LinkedIn colors
  final Color linkedInBlue = Color(0xFF0077B5);
  final Color lightBlue = Color(0xFF0A66C2);
  final Color whiteBackground = Color(0xFFF3F2EF);
  final Color borderGrey = Color(0xFFE1E9EE);

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing user data
    firstNameController = TextEditingController(text: widget.user.first_name);
    middleNameController = TextEditingController(text: widget.user.middle_name);
    lastNameController = TextEditingController(text: widget.user.last_name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);

    // Initialize address controllers
    final addressDetails = widget.user.address_details ?? {};
    address1Controller =
        TextEditingController(text: addressDetails['address_line1'] ?? '');
    address2Controller =
        TextEditingController(text: addressDetails['address_line2'] ?? '');
    address3Controller =
        TextEditingController(text: addressDetails['address_line3'] ?? '');
    cityController = TextEditingController(text: addressDetails['city'] ?? '');
    stateController =
        TextEditingController(text: addressDetails['state'] ?? '');
    pincodeController =
        TextEditingController(text: addressDetails['pincode'] ?? '');
    countryController =
        TextEditingController(text: addressDetails['country'] ?? '');
  }

  @override
  void dispose() {
    // Dispose controllers
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    address3Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
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
          icon: Icon(Icons.close, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveProfile,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileImageSection(),
            const SizedBox(height: 16),
            _buildPersonalInfoSection(),
            const SizedBox(height: 16),
            _buildAddressSection(),
            const SizedBox(height: 16),
            _buildProfessionalSection(),
            const SizedBox(height: 16),
            _buildEducationSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.grey[300],
                  image: widget.user.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.user.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: widget.user.imageUrl == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                    : null,
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: linkedInBlue,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Change Profile Photo',
            style: TextStyle(
              color: linkedInBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          _buildTextField('First Name', firstNameController),
          SizedBox(height: 16),
          _buildTextField('Middle Name', middleNameController),
          SizedBox(height: 16),
          _buildTextField('Last Name', lastNameController),
          SizedBox(height: 16),
          _buildTextField('Email', emailController),
          SizedBox(height: 16),
          _buildTextField('Phone', phoneController),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          _buildTextField('Address Line 1', address1Controller),
          SizedBox(height: 16),
          _buildTextField('Address Line 2', address2Controller),
          SizedBox(height: 16),
          _buildTextField('Address Line 3 (Optional)', address3Controller),
          SizedBox(height: 16),
          _buildTextField('City', cityController),
          SizedBox(height: 16),
          _buildTextField('State', stateController),
          SizedBox(height: 16),
          _buildTextField('Pincode', pincodeController),
          SizedBox(height: 16),
          _buildTextField('Country', countryController),
        ],
      ),
    );
  }

  Widget _buildProfessionalSection() {
    if (widget.user.proffesional_details == null ||
        widget.user.proffesional_details!.isEmpty) {
      return _buildAddNewSection(
          'Add Professional Experience', Icons.work_outline);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Professional Experience',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: linkedInBlue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfesion(user: widget.user),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          ...widget.user.proffesional_details!
              .map((exp) => _buildExperienceEditItem(exp))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildExperienceEditItem(Map<String, dynamic> experience) {
    final jobTitle = experience['title'] ?? 'Role';
    final company = experience['company'] ?? 'Company';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderGrey)),
      ),
      child: Row(
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
          SizedBox(width: 12),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    if (widget.user.educational_details == null ||
        widget.user.educational_details!.isEmpty) {
      return _buildAddNewSection('Add Education', Icons.school_outlined);
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Education',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit, color: linkedInBlue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditEducation(user: widget.user),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          ...widget.user.educational_details!
              .map((edu) => _buildEducationEditItem(edu))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildEducationEditItem(Map<String, dynamic> education) {
    final institution = education['institution'] ?? 'Institution';
    final degree = education['degree'] ?? '';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderGrey)),
      ),
      child: Row(
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
          SizedBox(width: 12),
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
                    degree,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddNewSection(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderGrey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: linkedInBlue, size: 24),
          SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: linkedInBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.grey[700]),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderGrey),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: linkedInBlue, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  void _saveProfile() {
    // Update user object with new values
    widget.user.first_name = firstNameController.text;
    widget.user.middle_name = middleNameController.text;
    widget.user.last_name = lastNameController.text;
    widget.user.email = emailController.text;
    widget.user.phone = phoneController.text;

    // Update address details
    widget.user.address_details = {
      "address_line1": address1Controller.text,
      "address_line2": address2Controller.text,
      "address_line3": address3Controller.text,
      "city": cityController.text,
      "state": stateController.text,
      "pincode": pincodeController.text,
      "country": countryController.text,
    };

    // Here you would typically save to a database or API

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile updated successfully'),
        backgroundColor: linkedInBlue,
      ),
    );

    // Navigate back to profile page with updated user data
    Navigator.pop(context);
  }
}
