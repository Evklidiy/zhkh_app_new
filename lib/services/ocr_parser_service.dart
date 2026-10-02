import '../models/lab_marker.dart';
import 'realm_service.dart';

class OcrParserService {
  static List<LabMarker> parse(String ocrText, {required bool isMale}) {
    final markers = <LabMarker>[];
    final lines = ocrText.split('\n');

    final regex = RegExp(
      r'([А-Яа-яA-Za-z\s\-]{3,40}?)\s*[:=]?\s*(\d+[.,]?\d*)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final matches = regex.allMatches(line);

      for (final match in matches) {
        final nameRaw = match.group(1)?.trim() ?? '';
        final valueStr = match.group(2)?.replaceAll(',', '.') ?? '';

        final value = double.tryParse(valueStr);
        if (value == null || nameRaw.length < 3) continue;

        final norm = RealmService.findByName(nameRaw);

        if (norm != null) {
          final isNormal = norm.isNormal(value, isMale: isMale);

          markers.add(
            LabMarker(
              id: norm.id,
              name: norm.name,
              value: value,
              unit: norm.unit,
              isNormal: isNormal,
              refMin: isMale ? norm.maleMin : norm.femaleMin,
              refMax: isMale ? norm.maleMax : norm.femaleMax,
            ),
          );
        } else {
          markers.add(
            LabMarker(
              id: nameRaw.toLowerCase().replaceAll(' ', '_'),
              name: nameRaw,
              value: value,
              unit: '',
              isNormal: true,
            ),
          );
        }
      }
    }

    final unique = <String, LabMarker>{};
    for (final m in markers) {
      unique[m.name.toLowerCase()] = m;
    }

    return unique.values.toList();
  }
}
