class usersModel {
  String DOB = "";
  String email = "";
  String id = "";
  String bio = "";
  String name = "";
  String password = "";
  String phone_number = "";
  String disability = "";
  String type = "";
  String gender = "";
  usersModel({
    required this.DOB,
    required this.disability,
    required this.id,
    required this.email,
    required this.type,
    required this.bio,
    required this.gender,
    required this.name,
    required this.phone_number,
  });

  Map<String, dynamic> toJson() => {
        'DOB': DOB,
        'id': id,
        'Disability': disability,
        'Email': email,
        'Type': type,
        'bio': bio,
        'gender': gender,
        'name': name,
        'phone number': phone_number,
      };

  static usersModel fromJson(Map<String, dynamic> json) => usersModel(
        DOB: json['DOB'],
        id: json['id'],
        disability: json['Disability'],
        email: json['Email'],
        type: json['Type'],
        bio: json['bio'],
        gender: json['gender'],
        name: json['name'],
        phone_number: json['phone number'],
      );
}
