import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/health_cubit.dart';

class SymptomInput extends StatefulWidget {
  const SymptomInput({super.key});

  @override
  State<SymptomInput> createState() => _SymptomInputState();
}

class _SymptomInputState extends State<SymptomInput> {
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  int _severity = 5;

  final List<String> _commonSymptoms = [
    'Головная боль',
    'Слабость',
    'Тошнота',
    'Головокружение',
    'Боль в животе',
    'Кашель',
    'Повышенная температура',
    'Боль в горле',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    context.read<HealthCubit>().addSymptom(
      date: DateTime.now(),
      name: name,
      severity: _severity,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Новый симптом',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Быстрый выбор
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _commonSymptoms.map((s) {
              return ActionChip(
                label: Text(s),
                onPressed: () => _nameController.text = s,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Название симптома',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          Text('Сила: $_severity / 10'),
          Slider(
            value: _severity.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: '$_severity',
            onChanged: (v) => setState(() => _severity = v.round()),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Заметка (необязательно)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _save,
              child: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }
}
