class LabMarker {
  final String id;
  final String name;
  final double value;
  final String unit;
  final bool isNormal;
  final double? refMin;
  final double? refMax;

  const LabMarker({
    required this.id,
    required this.name,
    required this.value,
    required this.unit,
    required this.isNormal,
    this.refMin,
    this.refMax,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'value': value,
    'unit': unit,
    'isNormal': isNormal ? 1 : 0,
    'refMin': refMin,
    'refMax': refMax,
  };

  factory LabMarker.fromMap(Map<String, dynamic> map) {
    return LabMarker(
      id: map['id'] as String,
      name: map['name'] as String,
      value: (map['value'] as num).toDouble(),
      unit: map['unit'] as String,
      isNormal: (map['isNormal'] as int) == 1,
      refMin: (map['refMin'] as num?)?.toDouble(),
      refMax: (map['refMax'] as num?)?.toDouble(),
    );
  }
}
