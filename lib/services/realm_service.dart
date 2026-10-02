import 'package:hive_flutter/hive_flutter.dart';

import '../models/reference_norm.dart';

/// Вспомогательное хранилище (аналог Realm).
/// Хранит справочник медицинских референсных значений.
class RealmService {
  static const String boxName = 'reference_norms';

  static Future<void> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(boxName);

    if (box.isEmpty) {
      await _seedData(box);
    }
  }

  static Future<void> _seedData(Box box) async {
    final norms = [
      // === Общий анализ крови ===
      const ReferenceNorm(
        id: 'hgb',
        name: 'Гемоглобин',
        unit: 'г/л',
        maleMin: 130,
        maleMax: 160,
        femaleMin: 120,
        femaleMax: 140,
        category: 'ОАК',
      ),
      const ReferenceNorm(
        id: 'rbc',
        name: 'Эритроциты',
        unit: '×10¹²/л',
        maleMin: 4.0,
        maleMax: 5.0,
        femaleMin: 3.5,
        femaleMax: 4.7,
        category: 'ОАК',
      ),
      const ReferenceNorm(
        id: 'wbc',
        name: 'Лейкоциты',
        unit: '×10⁹/л',
        maleMin: 4.0,
        maleMax: 9.0,
        femaleMin: 4.0,
        femaleMax: 9.0,
        category: 'ОАК',
      ),
      const ReferenceNorm(
        id: 'plt',
        name: 'Тромбоциты',
        unit: '×10⁹/л',
        maleMin: 180,
        maleMax: 320,
        femaleMin: 180,
        femaleMax: 320,
        category: 'ОАК',
      ),
      const ReferenceNorm(
        id: 'hct',
        name: 'Гематокрит',
        unit: '%',
        maleMin: 40,
        maleMax: 48,
        femaleMin: 36,
        femaleMax: 42,
        category: 'ОАК',
      ),
      const ReferenceNorm(
        id: 'esr',
        name: 'СОЭ',
        unit: 'мм/ч',
        maleMin: 1,
        maleMax: 10,
        femaleMin: 2,
        femaleMax: 15,
        category: 'ОАК',
      ),

      // === Биохимия ===
      const ReferenceNorm(
        id: 'glucose',
        name: 'Глюкоза',
        unit: 'ммоль/л',
        maleMin: 3.3,
        maleMax: 5.5,
        femaleMin: 3.3,
        femaleMax: 5.5,
        category: 'Биохимия',
      ),
      const ReferenceNorm(
        id: 'cholesterol',
        name: 'Холестерин общий',
        unit: 'ммоль/л',
        maleMin: 3.0,
        maleMax: 5.2,
        femaleMin: 3.0,
        femaleMax: 5.2,
        category: 'Биохимия',
      ),
      const ReferenceNorm(
        id: 'alt',
        name: 'АЛТ',
        unit: 'Ед/л',
        maleMin: 0,
        maleMax: 41,
        femaleMin: 0,
        femaleMax: 31,
        category: 'Биохимия',
      ),
      const ReferenceNorm(
        id: 'ast',
        name: 'АСТ',
        unit: 'Ед/л',
        maleMin: 0,
        maleMax: 37,
        femaleMin: 0,
        femaleMax: 31,
        category: 'Биохимия',
      ),
      const ReferenceNorm(
        id: 'creatinine',
        name: 'Креатинин',
        unit: 'мкмоль/л',
        maleMin: 62,
        maleMax: 115,
        femaleMin: 53,
        femaleMax: 97,
        category: 'Биохимия',
      ),
      const ReferenceNorm(
        id: 'urea',
        name: 'Мочевина',
        unit: 'ммоль/л',
        maleMin: 2.5,
        maleMax: 8.3,
        femaleMin: 2.5,
        femaleMax: 8.3,
        category: 'Биохимия',
      ),
      const ReferenceNorm(
        id: 'bilirubin',
        name: 'Билирубин общий',
        unit: 'мкмоль/л',
        maleMin: 3.4,
        maleMax: 20.5,
        femaleMin: 3.4,
        femaleMax: 20.5,
        category: 'Биохимия',
      ),
    ];

    for (final norm in norms) {
      await box.put(norm.id, norm.toMap());
    }
  }

  /// Получить все нормы
  static List<ReferenceNorm> getAll() {
    final box = Hive.box(boxName);
    return box.values.map((e) => ReferenceNorm.fromMap(e as Map)).toList();
  }

  /// Найти норму по названию (нечёткий поиск)
  static ReferenceNorm? findByName(String name) {
    final all = getAll();
    final lower = name.toLowerCase().trim();

    // Точное совпадение
    for (final n in all) {
      if (n.name.toLowerCase() == lower) return n;
    }

    // Частичное
    for (final n in all) {
      if (n.name.toLowerCase().contains(lower) ||
          lower.contains(n.name.toLowerCase())) {
        return n;
      }
    }

    // Популярные сокращения
    final aliases = {
      'hb': 'hgb',
      'hgb': 'hgb',
      'гемоглобин': 'hgb',
      'эритроциты': 'rbc',
      'rbc': 'rbc',
      'лейкоциты': 'wbc',
      'wbc': 'wbc',
      'тромбоциты': 'plt',
      'plt': 'plt',
      'соэ': 'esr',
      'глюкоза': 'glucose',
      'холестерин': 'cholesterol',
      'алт': 'alt',
      'аст': 'ast',
      'креатинин': 'creatinine',
      'мочевина': 'urea',
      'билирубин': 'bilirubin',
    };

    final aliasId = aliases[lower];
    if (aliasId != null) {
      final box = Hive.box(boxName);
      final data = box.get(aliasId);
      if (data != null) return ReferenceNorm.fromMap(data as Map);
    }

    return null;
  }
}
