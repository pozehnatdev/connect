class Userr {
  String? id;
  String? first_name;
  String? middle_name;
  String? last_name;
  String? email;
  String? phone;
  String? imageUrl;
  Map<String, dynamic>? address_details;
  List<Map<String, dynamic>>? proffesional_details;
  List<Map<String, dynamic>>? educational_details;
  List<String>? interests;

  Userr({
    this.id,
    required this.first_name,
    this.middle_name,
    required this.last_name,
    required this.email,
    this.phone,
    this.imageUrl,
    this.address_details,
    this.proffesional_details,
    this.educational_details,
    this.interests,
  });

  Userr.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    first_name = json['first_name'];
    middle_name = json['middle_name'];
    last_name = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    imageUrl = json['imageUrl'];
    address_details = json['address_details'] != null
        ? Map<String, dynamic>.from(json['address_details'])
        : null;
    proffesional_details = json['proffesional_details'] != null
        ? List<Map<String, dynamic>>.from(json['proffesional_details'])
        : null;
    educational_details = json['educational_details'] != null
        ? List<Map<String, dynamic>>.from(json['educational_details'])
        : null;
    interests =
        json['interests'] != null ? List<String>.from(json['interests']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': first_name,
      'middle_name': middle_name,
      'last_name': last_name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'address_details': address_details != null
          ? Map<String, dynamic>.from(address_details!)
          : null,
      'proffesional_details': proffesional_details != null
          ? List<Map<String, dynamic>>.from(proffesional_details!)
          : null,
      'educational_details': educational_details != null
          ? List<Map<String, dynamic>>.from(educational_details!)
          : null,
      'interests': interests != null ? List<String>.from(interests!) : null,
    };
  }
}
