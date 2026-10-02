import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../cubit/health_cubit.dart';
import '../cubit/health_state.dart';
import '../models/lab_marker.dart';
import '../models/lab_result.dart';
import '../models/symptom.dart';
import 'lab_detail_screen.dart';
import 'scan_lab_screen.dart';
import '../widgets/symptom_input.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Медицинский дневник'),
        centerTitle: true,
        actions: [
          BlocBuilder<HealthCubit, HealthState>(
            builder: (context, state) {
              return PopupMenuButton<bool>(
                icon: Icon(
                  state.isMale ? Icons.male : Icons.female,
                  color: state.isMale ? Colors.blue : Colors.pink,
                ),
                onSelected: (value) {
                  context.read<HealthCubit>().setGender(value);
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: true, child: Text('Мужской')),
                  const PopupMenuItem(value: false, child: Text('Женский')),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HealthCubit, HealthState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null &&
              state.labResults.isEmpty &&
              state.symptoms.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<HealthCubit>().loadAll(),
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<HealthCubit>().loadAll(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Кнопки
                ElevatedButton.icon(
                  onPressed: () => _showSymptomDialog(context),
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Добавить симптом'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => _addDemoAnalysis(context),
                  icon: const Icon(Icons.science),
                  label: const Text('Добавить тестовый анализ'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
                const SizedBox(height: 24),

                // График гемоглобина (если есть данные)
                if (state.labResults.isNotEmpty) ...[
                  const Text(
                    'Динамика гемоглобина',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _HemoglobinChart(results: state.labResults),
                  const SizedBox(height: 24),
                ],

                // Симптомы
                if (state.symptoms.isNotEmpty) ...[
                  const Text(
                    'Симптомы',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...state.symptoms
                      .take(6)
                      .map((s) => _SymptomTile(symptom: s)),
                  const SizedBox(height: 24),
                ],

                // Анализы
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Анализы',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${state.labResults.length}',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (state.labResults.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'Пока нет анализов.\nДобавьте тестовый или отсканируйте бланк.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...state.labResults.map((r) => _LabResultCard(result: r)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<HealthCubit>(),
                child: const ScanLabScreen(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.document_scanner),
        label: const Text('Сканировать бланк'),
      ),
    );
  }

  void _showSymptomDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<HealthCubit>(),
        child: const SymptomInput(),
      ),
    );
  }

  void _addDemoAnalysis(BuildContext context) {
    final random = DateTime.now().millisecondsSinceEpoch % 3;

    List<LabMarker> markers;
    String title;
    String laboratory;

    if (random == 0) {
      title = 'Общий анализ крови';
      laboratory = 'Инвитро';
      markers = [
        const LabMarker(
          id: 'hgb',
          name: 'Гемоглобин',
          value: 112,
          unit: 'г/л',
          isNormal: false,
          refMin: 130,
          refMax: 160,
        ),
        const LabMarker(
          id: 'wbc',
          name: 'Лейкоциты',
          value: 11.4,
          unit: '×10⁹/л',
          isNormal: false,
          refMin: 4.0,
          refMax: 9.0,
        ),
        const LabMarker(
          id: 'glucose',
          name: 'Глюкоза',
          value: 6.8,
          unit: 'ммоль/л',
          isNormal: false,
          refMin: 3.3,
          refMax: 5.5,
        ),
        const LabMarker(
          id: 'plt',
          name: 'Тромбоциты',
          value: 265,
          unit: '×10⁹/л',
          isNormal: true,
          refMin: 180,
          refMax: 320,
        ),
        const LabMarker(
          id: 'esr',
          name: 'СОЭ',
          value: 22,
          unit: 'мм/ч',
          isNormal: false,
          refMin: 1,
          refMax: 10,
        ),
      ];
    } else if (random == 1) {
      title = 'Контрольный анализ';
      laboratory = 'Гемотест';
      markers = [
        const LabMarker(
          id: 'hgb',
          name: 'Гемоглобин',
          value: 142,
          unit: 'г/л',
          isNormal: true,
          refMin: 130,
          refMax: 160,
        ),
        const LabMarker(
          id: 'wbc',
          name: 'Лейкоциты',
          value: 6.1,
          unit: '×10⁹/л',
          isNormal: true,
          refMin: 4.0,
          refMax: 9.0,
        ),
        const LabMarker(
          id: 'glucose',
          name: 'Глюкоза',
          value: 4.9,
          unit: 'ммоль/л',
          isNormal: true,
          refMin: 3.3,
          refMax: 5.5,
        ),
        const LabMarker(
          id: 'plt',
          name: 'Тромбоциты',
          value: 210,
          unit: '×10⁹/л',
          isNormal: true,
          refMin: 180,
          refMax: 320,
        ),
        const LabMarker(
          id: 'esr',
          name: 'СОЭ',
          value: 7,
          unit: 'мм/ч',
          isNormal: true,
          refMin: 1,
          refMax: 10,
        ),
      ];
    } else {
      title = 'Биохимический анализ';
      laboratory = 'Хеликс';
      markers = [
        const LabMarker(
          id: 'hgb',
          name: 'Гемоглобин',
          value: 128,
          unit: 'г/л',
          isNormal: false,
          refMin: 130,
          refMax: 160,
        ),
        const LabMarker(
          id: 'alt',
          name: 'АЛТ',
          value: 48,
          unit: 'Ед/л',
          isNormal: false,
          refMin: 0,
          refMax: 41,
        ),
        const LabMarker(
          id: 'ast',
          name: 'АСТ',
          value: 29,
          unit: 'Ед/л',
          isNormal: true,
          refMin: 0,
          refMax: 37,
        ),
        const LabMarker(
          id: 'creatinine',
          name: 'Креатинин',
          value: 98,
          unit: 'мкмоль/л',
          isNormal: true,
          refMin: 62,
          refMax: 115,
        ),
        const LabMarker(
          id: 'urea',
          name: 'Мочевина',
          value: 9.1,
          unit: 'ммоль/л',
          isNormal: false,
          refMin: 2.5,
          refMax: 8.3,
        ),
        const LabMarker(
          id: 'cholesterol',
          name: 'Холестерин',
          value: 5.8,
          unit: 'ммоль/л',
          isNormal: false,
          refMin: 3.0,
          refMax: 5.2,
        ),
      ];
    }

    context.read<HealthCubit>().addLabResult(
      title: title,
      date: DateTime.now().subtract(Duration(days: random * 4)),
      laboratory: laboratory,
      markers: markers,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Тестовый анализ добавлен')));
  }
}

// ==================== ГРАФИК ====================

class _HemoglobinChart extends StatelessWidget {
  final List<LabResult> results;

  const _HemoglobinChart({required this.results});

  @override
  Widget build(BuildContext context) {
    final points = <FlSpot>[];
    final labels = <String>[];

    // Идём от старых к новым
    final sorted = List<LabResult>.from(results)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final result in sorted) {
      LabMarker? marker;
      for (final m in result.markers) {
        if (m.id == 'hgb' || m.name.toLowerCase().contains('гемоглобин')) {
          marker = m;
          break;
        }
      }
      if (marker != null) {
        points.add(FlSpot(points.length.toDouble(), marker.value));
        labels.add(DateFormat('dd.MM').format(result.date));
      }
    }

    if (points.length < 2) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Добавьте ещё анализы с гемоглобином\nдля построения графика',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 16, 12),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.shade200, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx >= 0 && idx < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[idx],
                            style: const TextStyle(fontSize: 11),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 100,
              maxY: 170,
              lineBarsData: [
                LineChartBarData(
                  spots: points,
                  isCurved: true,
                  color: Colors.teal,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.teal.withValues(alpha: 0.12),
                  ),
                ),
                // Нижняя граница нормы
                LineChartBarData(
                  spots: [
                    FlSpot(0, 130),
                    FlSpot((points.length - 1).toDouble(), 130),
                  ],
                  color: Colors.red.withValues(alpha: 0.45),
                  barWidth: 1.5,
                  dotData: const FlDotData(show: false),
                  dashArray: [6, 4],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== СИМПТОМ ====================

class _SymptomTile extends StatelessWidget {
  final Symptom symptom;

  const _SymptomTile({required this.symptom});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM.yyyy').format(symptom.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _severityColor(symptom.severity)
              .withValues(alpha: 0.15),
          child: Text(
            '${symptom.severity}',
            style: TextStyle(
              color: _severityColor(symptom.severity),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(symptom.name),
        subtitle: Text(dateStr),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () {
            context.read<HealthCubit>().deleteSymptom(symptom.id);
          },
        ),
      ),
    );
  }

  Color _severityColor(int severity) {
    if (severity <= 3) return Colors.green;
    if (severity <= 6) return Colors.orange;
    return Colors.red;
  }
}

// ==================== КАРТОЧКА АНАЛИЗА ====================

class _LabResultCard extends StatelessWidget {
  final LabResult result;

  const _LabResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM.yyyy').format(result.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LabDetailScreen(result: result)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: result.hasAbnormal
                      ? Colors.red.shade50
                      : Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  result.hasAbnormal ? Icons.warning_amber : Icons.check_circle,
                  color: result.hasAbnormal ? Colors.red : Colors.teal,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    if (result.hasAbnormal)
                      Text(
                        'Отклонений: ${result.abnormalCount}',
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 22),
                color: Colors.grey,
                onPressed: () {
                  context.read<HealthCubit>().deleteLabResult(result.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
