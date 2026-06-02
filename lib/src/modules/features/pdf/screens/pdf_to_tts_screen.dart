import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfToTtsPage extends StatefulWidget {
  const PdfToTtsPage({super.key});

  @override
  State<PdfToTtsPage> createState() => _PdfToTtsPageState();
}

class _PdfToTtsPageState extends State<PdfToTtsPage> {
  final FlutterTts _tts = FlutterTts();

  String? _pdfPath;
  String _text = '';
  String? _error;

  bool _loading = false;
  bool _speaking = false;
  bool _stopRequested = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _speaking = false);
    });
  }

  Future<void> _pickPdf() async {
    setState(() {
      _error = null;
      _loading = true;
      _pdfPath = null;
      _text = '';
    });

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result == null || result.files.single.path == null) {
        setState(() => _loading = false);
        return;
      }

      final path = result.files.single.path!;

      // final buf = StringBuffer();
      // for (var i = 1; i <= doc.pages.length; i++) {
      //   final page = await doc.getPage(i);
      //   final textPage = await page.loadText(); // needs text layer in PDF
      //   buf.writeln(textPage.fullText);
      //   await page.close();
      // }
      // await doc.close();
      final doc = await PdfDocument.openFile(path);
      final buf = StringBuffer();
      for (final page in doc.pages) {
        final textPage = await page.loadText();
        buf.writeln(textPage.fullText);
      }

      setState(() {
        _pdfPath = path;
        _text = _cleanup(buf.toString());
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _cleanup(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

  List<String> _splitChunks(String text, {int maxLen = 220}) {
    final clean = _cleanup(text);
    if (clean.isEmpty) return [];

    final sentences = clean.split(RegExp(r'(?<=[.!?])\s+'));
    final chunks = <String>[];
    var current = StringBuffer();

    for (final sentence in sentences) {
      if ((current.length + sentence.length + 1) > maxLen &&
          current.isNotEmpty) {
        chunks.add(current.toString().trim());
        current = StringBuffer();
      }
      current.write('$sentence ');
    }
    if (current.isNotEmpty) chunks.add(current.toString().trim());
    return chunks;
  }

  Future<void> _speak() async {
    if (_text.isEmpty) return;

    setState(() {
      _error = null;
      _speaking = true;
      _stopRequested = false;
    });

    try {
      final chunks = _splitChunks(_text);
      for (final c in chunks) {
        if (_stopRequested) break;
        await _tts.speak(c);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _speaking = false);
    }
  }

  Future<void> _stop() async {
    setState(() => _stopRequested = true);
    await _tts.stop();
    if (!mounted) return;
    setState(() => _speaking = false);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSpeak = !_loading && _text.isNotEmpty && !_speaking;

    return Scaffold(
      appBar: AppBar(title: const Text('PDF → Text → TTS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(
            onPressed: _loading ? null : _pickPdf,
            icon: const Icon(Icons.upload_file),
            label: Text(_loading ? 'Loading…' : 'Upload PDF'),
          ),
          const SizedBox(height: 12),
          if (_pdfPath != null)
            Text(
              'File: $_pdfPath',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: canSpeak ? _speak : null,
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Read aloud'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _speaking ? _stop : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Preview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _text.isEmpty ? 'Upload a PDF to extract text.' : _text,
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Note: If your PDF is scanned images, text may be empty. You need OCR for that.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
