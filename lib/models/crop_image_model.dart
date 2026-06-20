import '../core/utils/map_utils.dart';

class CropImageModel {
  const CropImageModel({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.cropName,
    required this.imageUrl,
    required this.storagePath,
    required this.createdAt,
    this.caption,
  });

  final String id;
  final String userId;
  final String cropId;
  final String cropName;
  final String imageUrl;
  final String storagePath;
  final String? caption;
  final DateTime createdAt;

  factory CropImageModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return CropImageModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      cropId: map['cropId'] as String? ?? '',
      cropName: map['cropName'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      storagePath: map['storagePath'] as String? ?? '',
      caption: map['caption'] as String?,
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'cropId': cropId,
      'cropName': cropName,
      'imageUrl': imageUrl,
      'storagePath': storagePath,
      'caption': caption,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory CropImageModel.fromJson(Map<String, dynamic> json) {
    return CropImageModel.fromMap(json);
  }
}
