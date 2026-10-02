import 'lab_marker.dart';

class LabResult {
  final String id;
  final String title; // "Общий анализ крови"
  final DateTime date;
  final String? laboratory;
  final List<LabMarker> markers;
  final String? notes;

  const LabResult({
    required this.id,
    required this.title,
    required this.date,
    this.laboratory,
    required this.markers,
    this.notes,
  });

  /// Есть ли хотя бы один выход за норму
  bool get hasAbnormal => markers.any((m) => !m.isNormal);

  int get abnormalCount => markers.where((m) => !m.isNormal).length;
}
