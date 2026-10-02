import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/lab_result.dart';
import '../models/lab_marker.dart';

class LabDetailScreen extends StatelessWidget {
  final LabResult result;

  const LabDetailScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    // Простой формат без локали — не падает
    final dateStr = DateFormat('dd.MM.yyyy').format(result.date);

    return Scaffold(
      appBar: AppBar(title: Text(result.title), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr, style: TextStyle(color: Colors.grey.shade600)),
                  if (result.laboratory != null) ...[
                    const SizedBox(height: 4),
                    Text('Лаборатория: ${result.laboratory}'),
                  ],
                  if (result.hasAbnormal) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '⚠ Есть отклонения от нормы (${result.abnormalCount})',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Показатели',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...result.markers.map((m) => _MarkerTile(marker: m)),
        ],
      ),
    );
  }
}

class _MarkerTile extends StatelessWidget {
  final LabMarker marker;

  const _MarkerTile({required this.marker});

  @override
  Widget build(BuildContext context) {
    final isAbnormal = !marker.isNormal;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: isAbnormal ? Colors.red.shade50 : null,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    marker.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isAbnormal ? Colors.red.shade800 : null,
                    ),
                  ),
                  if (marker.refMin != null || marker.refMax != null)
                    Text(
                      'Норма: ${marker.refMin ?? "—"} – ${marker.refMax ?? "—"} ${marker.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${marker.value} ${marker.unit}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isAbnormal ? Colors.red : Colors.teal.shade700,
                  ),
                ),
                Icon(
                  isAbnormal ? Icons.warning_amber : Icons.check_circle,
                  size: 18,
                  color: isAbnormal ? Colors.red : Colors.teal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
