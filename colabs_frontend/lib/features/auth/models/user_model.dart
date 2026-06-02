class UserModel {
  final String id;
  final String email;
  final String name;
  final String lastName;
  final String phoneNumber;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.lastName,
    required this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:          json['id']           as String,
      email:       json['email']        as String,
      name:        json['name']         as String,
      lastName:    (json['lastName']    ?? json['last_name']) as String,
      phoneNumber: (json['phoneNumber'] ?? json['phone_number']) as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':          id,
      'email':       email,
      'name':        name,
      'lastName':    lastName,
      'phoneNumber': phoneNumber,
    };
  }
}