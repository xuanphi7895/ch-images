// class AudioRecorderService {
//   final Record _record = Record();

//   Future<void> start() async {
//     await _record.start();
//   }

//   Future<String?> stop() async {
//     return await _record.stop();
//   }
// }

import 'dart:typed_data';

class AudioRecorderService {
  Stream<Uint8List> startRecording() {
    // return PCM audio stream
    throw UnimplementedError();
  }

  Future<void> stopRecording() async {}
}
