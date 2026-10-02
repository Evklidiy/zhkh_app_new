import 'package:equatable/equatable.dart';

import '../models/lab_result.dart';
import '../models/symptom.dart';

class HealthState extends Equatable {
  final List<LabResult> labResults;
  final List<Symptom> symptoms;
  final bool isLoading;
  final String? error;
  final bool isMale; // для проверки норм

  const HealthState({
    this.labResults = const [],
    this.symptoms = const [],
    this.isLoading = false,
    this.error,
    this.isMale = true,
  });

  HealthState copyWith({
    List<LabResult>? labResults,
    List<Symptom>? symptoms,
    bool? isLoading,
    String? error,
    bool? isMale,
    bool clearError = false,
  }) {
    return HealthState(
      labResults: labResults ?? this.labResults,
      symptoms: symptoms ?? this.symptoms,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isMale: isMale ?? this.isMale,
    );
  }

  @override
  List<Object?> get props => [labResults, symptoms, isLoading, error, isMale];
}
