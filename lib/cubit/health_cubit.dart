import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/lab_marker.dart';
import '../services/database_service.dart';
import 'health_state.dart';

class HealthCubit extends Cubit<HealthState> {
  final DatabaseService databaseService;

  HealthCubit({required this.databaseService}) : super(const HealthState());

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final results = await databaseService.getAllLabResults();
      final symptoms = await databaseService.getAllSymptoms();

      emit(
        state.copyWith(
          labResults: results,
          symptoms: symptoms,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Ошибка загрузки: $e'));
    }
  }

  void setGender(bool isMale) {
    emit(state.copyWith(isMale: isMale));
  }

  Future<void> addLabResult({
    required String title,
    required DateTime date,
    String? laboratory,
    String? notes,
    required List<LabMarker> markers,
  }) async {
    try {
      await databaseService.insertLabResult(
        title: title,
        date: date,
        laboratory: laboratory,
        notes: notes,
        markers: markers,
      );
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: 'Не удалось сохранить анализ: $e'));
    }
  }

  Future<void> addSymptom({
    required DateTime date,
    required String name,
    required int severity,
    String? note,
  }) async {
    try {
      await databaseService.insertSymptom(
        date: date,
        name: name,
        severity: severity,
        note: note,
      );
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: 'Не удалось сохранить симптом: $e'));
    }
  }

  Future<void> deleteLabResult(String id) async {
    await databaseService.deleteLabResult(id);
    await loadAll();
  }

  Future<void> deleteSymptom(String id) async {
    await databaseService.deleteSymptom(id);
    await loadAll();
  }
}
