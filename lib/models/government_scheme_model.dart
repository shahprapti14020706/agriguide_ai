import '../core/utils/map_utils.dart';

class GovernmentSchemeModel {
  const GovernmentSchemeModel({
    required this.id,
    required this.name,
    required this.department,
    required this.schemeLevel,
    required this.description,
    required this.eligibility,
    required this.benefits,
    required this.requiredDocuments,
    required this.applicationProcess,
    required this.officialLink,
    required this.deadline,
    required this.crops,
    required this.states,
    required this.minFarmSize,
    required this.maxFarmSize,
    required this.farmerCategories,
    required this.active,
  });

  final String id;
  final String name;
  final String department;
  final String schemeLevel;
  final String description;
  final List<String> eligibility;
  final List<String> benefits;
  final List<String> requiredDocuments;
  final List<String> applicationProcess;
  final String officialLink;
  final DateTime? deadline;
  final List<String> crops;
  final List<String> states;
  final double? minFarmSize;
  final double? maxFarmSize;
  final List<String> farmerCategories;
  final bool active;

  factory GovernmentSchemeModel.fromMap(
    Map<String, dynamic> map, {
    String? id,
  }) {
    return GovernmentSchemeModel(
      id: id ?? map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      department: map['department'] as String? ?? '',
      schemeLevel:
          (map['schemeLevel'] as String?) ?? (map['level'] as String?) ?? '',
      description: map['description'] as String? ?? '',
      eligibility: MapUtils.stringListFromValue(map['eligibility']),
      benefits: MapUtils.stringListFromValue(map['benefits']),
      requiredDocuments: MapUtils.stringListFromValue(map['requiredDocuments']),
      applicationProcess:
          MapUtils.stringListFromValue(map['applicationProcess']),
      officialLink: map['officialLink'] as String? ?? '',
      deadline: MapUtils.dateTimeFromValue(map['deadline']),
      crops: MapUtils.stringListFromValue(map['crops']),
      states: MapUtils.stringListFromValue(map['states']),
      minFarmSize: (map['minFarmSize'] as num?)?.toDouble(),
      maxFarmSize: (map['maxFarmSize'] as num?)?.toDouble(),
      farmerCategories: MapUtils.stringListFromValue(map['farmerCategories']),
      active: map['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'department': department,
      'schemeLevel': schemeLevel,
      'description': description,
      'eligibility': eligibility,
      'benefits': benefits,
      'requiredDocuments': requiredDocuments,
      'applicationProcess': applicationProcess,
      'officialLink': officialLink,
      'deadline': deadline,
      'crops': crops,
      'states': states,
      'minFarmSize': minFarmSize,
      'maxFarmSize': maxFarmSize,
      'farmerCategories': farmerCategories,
      'active': active,
    };
  }

  Map<String, dynamic> toJson() => MapUtils.jsonReady(toMap());

  factory GovernmentSchemeModel.fromJson(Map<String, dynamic> json) {
    return GovernmentSchemeModel.fromMap(json);
  }
}
