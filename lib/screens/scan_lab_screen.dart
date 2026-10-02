import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../cubit/health_cubit.dart';
import '../models/lab_marker.dart';
import '../services/ocr_parser_service.dart';

class ScanLabScreen extends StatefulWidget {
  const ScanLabScreen({super.key});

  @override
  State<ScanLabScreen> createState() => _ScanLabScreenState();
}

class _ScanLabScreenState extends State<ScanLabScreen> {
  CameraController? _controller;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isBusy = false;
  String _status = 'Наведите камеру на бланк анализа';
  List<LabMarker> _parsedMarkers = [];
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _status = 'Камера не найдена');
        return;
      }

      _controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      setState(() => _status = 'Ошибка камеры: $e');
    }
  }

  Future<void> _scan() async {
    if (_controller == null || !_controller!.value.isInitialized || _isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
      _status = 'Распознавание...';
      _parsedMarkers = [];
      _saved = false;
    });

    try {
      final file = await _controller!.takePicture();
      final inputImage = InputImage.fromFilePath(file.path);
      final result = await _textRecognizer.processImage(inputImage);

      if (!mounted) return;

      final isMale = context.read<HealthCubit>().state.isMale;
      final markers = OcrParserService.parse(result.text, isMale: isMale);

      setState(() {
        _parsedMarkers = markers;
        _status = markers.isEmpty
            ? 'Показатели не распознаны. Попробуйте ещё раз.'
            : 'Найдено показателей: ${markers.length}';
      });
    } catch (e) {
      setState(() => _status = 'Ошибка: $e');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _save() async {
    if (_parsedMarkers.isEmpty) return;

    await context.read<HealthCubit>().addLabResult(
      title: 'Анализ от ${DateTime.now().day}.${DateTime.now().month}',
      date: DateTime.now(),
      markers: _parsedMarkers,
    );

    if (!mounted) return;

    setState(() => _saved = true);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Анализ сохранён')));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('Сканер бланка')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Сканер бланка')),
      body: Column(
        children: [
          Expanded(flex: 3, child: CameraPreview(_controller!)),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.grey.shade50,
              child: Column(
                children: [
                  Text(
                    _status,
                    style: const TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  if (_parsedMarkers.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _parsedMarkers.length,
                        itemBuilder: (_, i) {
                          final m = _parsedMarkers[i];
                          return ListTile(
                            dense: true,
                            title: Text(m.name),
                            trailing: Text(
                              '${m.value} ${m.unit}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: m.isNormal ? Colors.teal : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isBusy ? null : _scan,
                          icon: const Icon(Icons.camera_alt),
                          label: Text(
                            _isBusy ? 'Распознаю...' : 'Сфотографировать',
                          ),
                        ),
                      ),
                      if (_parsedMarkers.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _saved ? null : _save,
                            icon: const Icon(Icons.save),
                            label: const Text('Сохранить'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
