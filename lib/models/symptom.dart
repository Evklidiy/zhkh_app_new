class Symptom {
  final String id;
  final DateTime date;
  final String name; // "Головная боль", "Слабость" и т.д.
  final int severity; // 1–10
  final String? note;

  const Symptom({
    required this.id,
    required this.date,
    required this.name,
    required this.severity,
    this.note,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'name': name,
    'severity': severity,
    'note': note,
  };

  factory Symptom.fromMap(Map<String, dynamic> map) {
    return Symptom(
      id: map['id'] as String,
      date: DateTime.parse(map['date'] as String),
      name: map['name'] as String,
      severity: map['severity'] as int,
      note: map['note'] as String?,
    );
  }
}
