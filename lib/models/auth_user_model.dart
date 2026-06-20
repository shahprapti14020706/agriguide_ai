import 'package:firebase_auth/firebase_auth.dart';

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.emailVerified,
    this.email,
    this.displayName,
    this.phoneNumber,
    this.photoUrl,
  });

  final String id;
  final String? email;
  final String? displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final bool emailVerified;

  factory AuthUserModel.fromFirebaseUser(User user) {
    return AuthUserModel(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }

  factory AuthUserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return AuthUserModel(
      id: id ?? map['id'] as String? ?? '',
      email: map['email'] as String?,
      displayName: map['displayName'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      photoUrl: map['photoUrl'] as String?,
      emailVerified: map['emailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel.fromMap(json);
  }
}
