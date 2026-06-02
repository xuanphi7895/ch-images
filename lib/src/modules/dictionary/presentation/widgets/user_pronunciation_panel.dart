import 'package:flutter/material.dart';

import '../../data/pronunciation_recorder.dart';
import '../../data/user_pronunciation_store.dart';

enum _MicState { idle, recording, saved }

class UserPronunciationPanel extends StatefulWidget {
  const UserPronunciationPanel({
    super.key,
    required this.word,
    this.recorder,
    this.store,
  });

  final String word;
  final PronunciationRecorder? recorder;
  final UserPronunciationStore? store;

  @override
  State<UserPronunciationPanel> createState() => _UserPronunciationPanelState();
}

class _UserPronunciationPanelState extends State<UserPronunciationPanel> {
  late final PronunciationRecorder _recorder;
  late final UserPronunciationStore _store;
  late final bool _ownsRecorder;

  _MicState _state = _MicState.idle;
  String? _savedPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ownsRecorder = widget.recorder == null;
    _recorder = widget.recorder ?? PronunciationRecorder();
    _store = widget.store ?? UserPronunciationStore();
    _loadExisting();
  }

  Future<void> _loadExisting() async {
    final path = await _store.getPathForWord(widget.word);
    if (!mounted) return;
    if (path != null) {
      setState(() {
        _savedPath = path;
        _state = _MicState.saved;
      });
    }
  }

  Future<void> _toggleRecord() async {
    setState(() => _error = null);

    if (_state == _MicState.recording) {
      final path = await _recorder.stopRecording();
      if (path == null) return;
      await _store.savePathForWord(widget.word, path);
      setState(() {
        _savedPath = path;
        _state = _MicState.saved;
      });
      return;
    }

    try {
      final path = await _store.newRecordingPath(widget.word);
      await _recorder.startRecording(path);
      setState(() => _state = _MicState.recording);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _playMine() async {
    if (_savedPath == null) return;
    await _recorder.playFile(_savedPath!);
  }

  Future<void> _delete() async {
    await _store.deleteForWord(widget.word);
    setState(() {
      _savedPath = null;
      _state = _MicState.idle;
    });
  }

  @override
  void dispose() {
    if (_ownsRecorder) _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRecording = _state == _MicState.recording;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your pronunciation', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _toggleRecord,
                  style: FilledButton.styleFrom(
                    backgroundColor: isRecording
                        ? theme.colorScheme.errorContainer
                        : null,
                  ),
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  label: Text(isRecording ? 'Stop' : 'Record'),
                ),
                const SizedBox(width: 8),
                if (_state == _MicState.saved) ...[
                  IconButton(
                    tooltip: 'Play your recording',
                    onPressed: _playMine,
                    icon: const Icon(Icons.play_arrow),
                  ),
                  IconButton(
                    tooltip: 'Delete recording',
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ],
            ),
            if (isRecording)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      size: 12,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Recording… tap Stop to save',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
