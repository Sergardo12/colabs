class OccupationModel {
  final String  id;
  final String  name;
  final String? image;

  const OccupationModel({
    required this.id,
    required this.name,
    this.image,
  });

  factory OccupationModel.fromJson(Map<String, dynamic> json) {
    return OccupationModel(
      id:    json['id']    as String,
      name:  json['name']  as String,
      image: json['image'] as String?,
    );
  }
}

class UserProfileModel {
  final String  id;
  final String  email;
  final String  name;
  final String  lastName;
  final String  phoneNumber;
  final String? imageProfile;
  final String? dateBirth;
  final String? gender;
  final String  registrationDate;

  const UserProfileModel({
    required this.id,
    required this.email,
    required this.name,
    required this.lastName,
    required this.phoneNumber,
    this.imageProfile,
    this.dateBirth,
    this.gender,
    required this.registrationDate,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
  return UserProfileModel(
    id:               json['id']               as String,
    email:            json['email']             as String,
    name:             json['name']              as String,
    lastName:         (json['lastName']         ?? json['last_name'])    as String,
    phoneNumber:      (json['phoneNumber']      ?? json['phone_number']  ?? '') as String,
    imageProfile:     json['imageProfile']      as String?,
    dateBirth:        json['dateBirth']         as String?,
    gender:           json['gender']            as String?,
    registrationDate: (json['registrationDate'] ?? json['registration_date'] ?? '') as String,
  );
  }
}

class ColabProfileModel {
  final String              id;
  final String              description;
  final String              experience;
  final String              verificationStatus;
  final List<OccupationModel> occupations;

  const ColabProfileModel({
    required this.id,
    required this.description,
    required this.experience,
    required this.verificationStatus,
    required this.occupations,
  });

  factory ColabProfileModel.fromJson(Map<String, dynamic> json) {
    return ColabProfileModel(
      id:                 json['id']                 as String,
      description:        json['description']        as String,
      experience:         json['experience']         as String,
      verificationStatus: json['verificationStatus'] as String,
      occupations: (json['occupations'] as List<dynamic>)
          .map((e) => OccupationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}