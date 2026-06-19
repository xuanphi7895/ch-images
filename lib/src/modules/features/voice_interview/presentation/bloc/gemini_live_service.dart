// import 'dart:typed_data';

// import 'package:web_socket_channel/web_socket_channel.dart';

// class GeminiLiveService {
//   // final Dio dio;

//   // GeminiLiveService(this.dio);

//   // Future<String> evaluateAnswer(
//   //     String answer) async {

//   //   final response =
//   //       await dio.post(
//   //     '/api/interview/evaluate',
//   //     data: {
//   //       'answer': answer,
//   //     },
//   //   );

//   //   return response.data['feedback'];
//   // }

//   WebSocketChannel? _channel;

//   Future<void> connect() async {

//     _channel = WebSocketChannel.connect(
//       Uri.parse(
//         'wss://gemini-live-endpoint'
//       ),
//     );

//     _channel!.stream.listen(
//       _handleMessage,
//     );
//   }

//   void sendAudio(Uint8List audioBytes) {
//     _channel?.sink.add(audioBytes);
//   }

//   void _handleMessage(dynamic message) {
//     // audio response
//   }
// }

import 'dart:typed_data';

class GeminiLiveService {
  Future<void> connect() async {
    // Create Gemini Live session
    // Authenticate
    // Register listeners
  }

  Future<void> sendAudioChunk(Uint8List chunk) async {
    // Stream microphone bytes
    // to Gemini Live
  }

  Stream<Uint8List> get audioResponses {
    // Gemini audio stream
    throw UnimplementedError();
  }

  Stream<String> get textResponses {
    throw UnimplementedError();
  }

  Future<void> disconnect() async {}
}
