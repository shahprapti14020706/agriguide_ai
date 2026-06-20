import '../core/utils/map_utils.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.email,
    required this.village,
    required this.taluka,
    required this.district,
    required this.state,
    required this.farmSize,
    required this.soilType,
    required this.waterSource,
    required this.irrigationMethod,
    required this.preferredLanguage,
    required this.profileCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.profileImageUrl,
    this.farmerCategory,
  });

  final String id;
  final String name;
  final String mobileNumber;
  final String email;
  final String village;
  final String taluka;
  final String district;
  final String state;
  final double farmSize;
  final String soilType;
  final String waterSource;
  final String irrigationMethod;
  final String preferredLanguage;
  final String? profileImageUrl;
  final bool profileCompleted;
  final String? farmerCategory;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserProfileModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return UserProfileModel(
      id: id ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      mobileNumber: map['mobileNumber'] as String? ?? '',
      email: map['email'] as String? ?? '',
      village: map['village'] as String? ?? '',
      taluka: map['taluka'] as String? ?? '',
      district: map['district'] as String? ?? '',
      state: map['state'] as String? ?? '',
      farmSize: (map['farmSize'] as num?)?.toDouble() ?? 0,
      soilType: map['soilType'] as String? ?? '',
      waterSource: map['waterSource'] as String? ?? '',
      irrigationMethod: map['irrigationMethod'] as String? ?? '',
      preferredLanguage: map['preferredLanguage'] as String? ?? 'en',
      profileImageUrl: map['profileImageUrl'] as String?,
      profileCompleted: map['profileCompleted'] as bool? ?? false,
      farmerCategory: map['farmerCategory'] as String?,
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
      updatedAt: MapUtils.dateTimeFromValue(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mobileNumber': mobileNumber,
      'email': email,
      'village': village,
      'taluka': taluka,
      'district': district,
      'state': state,
      'farmSize': farmSize,
      'soilType': soilType,
      'waterSource': waterSource,
      'irrigationMethod': irrigationMethod,
      'preferredLanguage': preferredLanguage,
      'profileImageUrl': profileImageUrl,
      'profileCompleted': profileCompleted,
      'farmerCategory': farmerCategory,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel.fromMap(json);
  }

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? mobileNumber,
    String? email,
    String? village,
    String? taluka,
    String? district,
    String? state,
    double? farmSize,
    String? soilType,
    String? waterSource,
    String? irrigationMethod,
    String? preferredLanguage,
    String? profileImageUrl,
    bool? profileCompleted,
    String? farmerCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      email: email ?? this.email,
      village: village ?? this.village,
      taluka: taluka ?? this.taluka,
      district: district ?? this.district,
      state: state ?? this.state,
      farmSize: farmSize ?? this.farmSize,
      soilType: soilType ?? this.soilType,
      waterSource: waterSource ?? this.waterSource,
      irrigationMethod: irrigationMethod ?? this.irrigationMethod,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      farmerCategory: farmerCategory ?? this.farmerCategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
