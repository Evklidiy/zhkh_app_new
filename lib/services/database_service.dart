import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

import '../models/lab_marker.dart';
import '../models/lab_result.dart';
import '../models/symptom.dart';

class DatabaseService {
  static Database? _db;
  final _uuid = const Uuid();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'medical_diary.db');

    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Результаты анализов
        await db.execute('''
          CREATE TABLE lab_results (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            laboratory TEXT,
            notes TEXT
          )
        ''');

        // Маркеры (показатели) внутри анализа
        await db.execute('''
          CREATE TABLE lab_markers (
            id TEXT PRIMARY KEY,
            labResultId TEXT NOT NULL,
            name TEXT NOT NULL,
            value REAL NOT NULL,
            unit TEXT NOT NULL,
            isNormal INTEGER NOT NULL,
            refMin REAL,
            refMax REAL,
            FOREIGN KEY (labResultId)
              REFERENCES lab_results (id)
              ON DELETE CASCADE
          )
        ''');

        // Дневник симптомов
        await db.execute('''
          CREATE TABLE symptoms (
            id TEXT PRIMARY KEY,
            date TEXT NOT NULL,
            name TEXT NOT NULL,
            severity INTEGER NOT NULL,
            note TEXT
          )
        ''');
      },
    );
  }

  // ============================================================
  // LAB RESULTS
  // ============================================================

  Future<String> insertLabResult({
    required String title,
    required DateTime date,
    String? laboratory,
    String? notes,
    required List<LabMarker> markers,
  }) async {
    final db = await database;
    final id = _uuid.v4();

    await db.transaction((txn) async {
      await txn.insert('lab_results', {
        'id': id,
        'title': title,
        'date': date.toIso8601String(),
        'laboratory': laboratory,
        'notes': notes,
      });

      for (final marker in markers) {
        await txn.insert('lab_markers', {
          'id': _uuid.v4(),
          'labResultId': id,
          'name': marker.name,
          'value': marker.value,
          'unit': marker.unit,
          'isNormal': marker.isNormal ? 1 : 0,
          'refMin': marker.refMin,
          'refMax': marker.refMax,
        });
      }
    });

    return id;
  }

  Future<List<LabResult>> getAllLabResults() async {
    final db = await database;

    final resultRows = await db.query('lab_results', orderBy: 'date DESC');

    final results = <LabResult>[];

    for (final row in resultRows) {
      final markers = await _getMarkersForResult(row['id'] as String);
      results.add(
        LabResult(
          id: row['id'] as String,
          title: row['title'] as String,
          date: DateTime.parse(row['date'] as String),
          laboratory: row['laboratory'] as String?,
          notes: row['notes'] as String?,
          markers: markers,
        ),
      );
    }

    return results;
  }

  Future<LabResult?> getLabResultById(String id) async {
    final db = await database;

    final rows = await db.query(
      'lab_results',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    final markers = await _getMarkersForResult(id);

    return LabResult(
      id: row['id'] as String,
      title: row['title'] as String,
      date: DateTime.parse(row['date'] as String),
      laboratory: row['laboratory'] as String?,
      notes: row['notes'] as String?,
      markers: markers,
    );
  }

  Future<List<LabMarker>> _getMarkersForResult(String labResultId) async {
    final db = await database;

    final rows = await db.query(
      'lab_markers',
      where: 'labResultId = ?',
      whereArgs: [labResultId],
    );

    return rows.map((r) => LabMarker.fromMap(r)).toList();
  }

  Future<void> deleteLabResult(String id) async {
    final db = await database;
    await db.delete('lab_results', where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  // SYMPTOMS
  // ============================================================

  Future<String> insertSymptom({
    required DateTime date,
    required String name,
    required int severity,
    String? note,
  }) async {
    final db = await database;
    final id = _uuid.v4();

    await db.insert('symptoms', {
      'id': id,
      'date': date.toIso8601String(),
      'name': name,
      'severity': severity,
      'note': note,
    });

    return id;
  }

  Future<List<Symptom>> getAllSymptoms() async {
    final db = await database;

    final rows = await db.query('symptoms', orderBy: 'date DESC');

    return rows.map((r) => Symptom.fromMap(r)).toList();
  }

  Future<void> deleteSymptom(String id) async {
    final db = await database;
    await db.delete('symptoms', where: 'id = ?', whereArgs: [id]);
  }

  // ============================================================
  // Очистка (для отладки)
  // ============================================================

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('lab_markers');
    await db.delete('lab_results');
    await db.delete('symptoms');
  }
}
