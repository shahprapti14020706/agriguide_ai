class CropStageModel {
  const CropStageModel({
    required this.name,
    required this.startDay,
    required this.endDay,
    required this.recommendations,
    required this.upcomingActivities,
  });

  final String name;
  final int startDay;
  final int endDay;
  final List<String> recommendations;
  final List<String> upcomingActivities;

  factory CropStageModel.fromMap(Map<String, dynamic> map) {
    return CropStageModel(
      name: map['name'] as String? ?? '',
      startDay: (map['startDay'] as num?)?.toInt() ?? 0,
      endDay: (map['endDay'] as num?)?.toInt() ?? 0,
      recommendations: _stringList(map['recommendations']),
      upcomingActivities: _stringList(map['upcomingActivities']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startDay': startDay,
      'endDay': endDay,
      'recommendations': recommendations,
      'upcomingActivities': upcomingActivities,
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory CropStageModel.fromJson(Map<String, dynamic> json) {
    return CropStageModel.fromMap(json);
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.whereType<String>().toList(growable: false);
    }

    return const [];
  }
}

class CropStageCalendarModel {
  const CropStageCalendarModel({
    required this.cropName,
    required this.stages,
    this.variety,
  });

  final String cropName;
  final String? variety;
  final List<CropStageModel> stages;

  factory CropStageCalendarModel.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    final stageMaps = map['stages'];

    return CropStageCalendarModel(
      cropName: map['cropName'] as String? ?? id ?? '',
      variety: map['variety'] as String?,
      stages: stageMaps is List
          ? stageMaps
              .whereType<Map>()
              .map(
                (stage) => CropStageModel.fromMap(
                  Map<String, dynamic>.from(stage),
                ),
              )
              .toList(growable: false)
          : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cropName': cropName,
      'variety': variety,
      'stages': stages.map((stage) => stage.toMap()).toList(growable: false),
    };
  }

  Map<String, dynamic> toJson() => toMap();

  factory CropStageCalendarModel.fromJson(Map<String, dynamic> json) {
    return CropStageCalendarModel.fromMap(json);
  }
}
