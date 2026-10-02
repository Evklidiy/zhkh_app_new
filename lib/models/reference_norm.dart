class ReferenceNorm {
  final String id;
  final String name; // например "Гемоглобин"
  final String unit; // г/л
  final double? maleMin;
  final double? maleMax;
  final double? femaleMin;
  final double? femaleMax;
  final String category; // "ОАК", "Биохимия" и т.д.

  const ReferenceNorm({
    required this.id,
    required this.name,
    required this.unit,
    this.maleMin,
    this.maleMax,
    this.femaleMin,
    this.femaleMax,
    required this.category,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'unit': unit,
    'maleMin': maleMin,
    'maleMax': maleMax,
    'femaleMin': femaleMin,
    'femaleMax': femaleMax,
    'category': category,
  };

  factory ReferenceNorm.fromMap(Map<dynamic, dynamic> map) {
    return ReferenceNorm(
      id: map['id'] as String,
      name: map['name'] as String,
      unit: map['unit'] as String,
      maleMin: (map['maleMin'] as num?)?.toDouble(),
      maleMax: (map['maleMax'] as num?)?.toDouble(),
      femaleMin: (map['femaleMin'] as num?)?.toDouble(),
      femaleMax: (map['femaleMax'] as num?)?.toDouble(),
      category: map['category'] as String,
    );
  }

  /// Проверка, входит ли значение в норму
  bool isNormal(double value, {required bool isMale}) {
    final min = isMale ? maleMin : femaleMin;
    final max = isMale ? maleMax : femaleMax;

    if (min != null && value < min) return false;
    if (max != null && value > max) return false;
    return true;
  }
}
