import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/health_cubit.dart';
import 'screens/main_screen.dart';
import 'services/database_service.dart';
import 'services/realm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RealmService.init();

  final databaseService = DatabaseService();

  // Выводим путь к базе данных
  final db = await databaseService.database;
  print('========== DB PATH ==========');
  print(db.path);
  print('=============================');

  runApp(MedicalDiaryApp(databaseService: databaseService));
}

class MedicalDiaryApp extends StatelessWidget {
  final DatabaseService databaseService;

  const MedicalDiaryApp({super.key, required this.databaseService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Медицинский дневник',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      home: BlocProvider(
        create: (_) => HealthCubit(databaseService: databaseService)..loadAll(),
        child: const MainScreen(),
      ),
    );
  }
}
