import 'dart:convert';

class UserModel {
  String? id;
  String userName;
  String email;
  String? photoURL;
  String? gender;
  String? bio;

  UserModel({
    this.id,
    this.photoURL,
    this.bio,
    this.gender,
    required this.userName,
    required this.email,
  });

  factory UserModel.fromMap({required Map<String, dynamic> map}) {
    return UserModel(
      id: map['id'],
      photoURL: map['photoURL'],
      userName: map['userName'],
      gender: map['gender'],
      email: map['email'],
      bio: map['bio'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'photoURL': photoURL,
      'gender': gender,
      'bio': bio
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'MyUser(id: $id,  userName: $userName, bio: $bio,  gender: $gender,email: $email, photoURL: $photoURL)';
  }
}
