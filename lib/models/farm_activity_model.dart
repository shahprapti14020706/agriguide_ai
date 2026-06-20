import '../core/utils/map_utils.dart';

class FarmActivityModel {
  const FarmActivityModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.activityDate,
    required this.createdAt,
    this.cropId,
    this.cropName,
    this.quantity,
    this.cost,
  });

  final String id;
  final String userId;
  final String type;
  final String title;
  final String description;
  final String? cropId;
  final String? cropName;
  final String? quantity;
  final double? cost;
  final DateTime activityDate;
  final DateTime createdAt;

  factory FarmActivityModel.fromMap(Map<String, dynamic> map, {String? id}) {
    return FarmActivityModel(
      id: id ?? map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      cropId: map['cropId'] as String?,
      cropName: map['cropName'] as String?,
      quantity: map['quantity'] as String?,
      cost: (map['cost'] as num?)?.toDouble(),
      activityDate:
          MapUtils.dateTimeFromValue(map['activityDate']) ?? DateTime.now(),
      createdAt: MapUtils.dateTimeFromValue(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'description': description,
      'cropId': cropId,
      'cropName': cropName,
      'quantity': quantity,
      'cost': cost,
      'activityDate': activityDate,
      'createdAt': createdAt,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory FarmActivityModel.fromJson(Map<String, dynamic> json) {
    return FarmActivityModel.fromMap(json);
  }
}
