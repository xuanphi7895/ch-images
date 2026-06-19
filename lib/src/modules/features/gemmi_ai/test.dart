// main.dart
import 'package:flutter/material.dart';
// Import necessary packages for camera, audio, http/websockets

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Controllers for text input, camera, audio recorder/player
  TextEditingController _textController = TextEditingController();
  // CameraController _cameraController;
  // AudioRecorder _audioRecorder;
  // AudioPlayer _audioPlayer;

  List<String> _messages = []; // To display text responses

  @override
  void initState() {
    super.initState();
    // Initialize camera, audio recorder, etc.
  }

  @override
  void dispose() {
    _textController.dispose();
    // Dispose camera, audio recorder, player
    super.dispose();
  }

  void _sendToGeminiLiveAPI({
    String? textInput,
    // Stream<List<int>>? audioStream,
    // Stream<CameraImage>? videoStream,
  }) async {
    // This is where you'd make your API call
    // Example using http (for text-only for simplicity):
    if (textInput != null && textInput.isNotEmpty) {
      // Simulate API call and response
      setState(() {
        _messages.add("You: $textInput");
      });

      // In a real app, you'd send textInput to your backend/API
      // and await a response.
      // var response = await http.post(
      //   Uri.parse('YOUR_GEMINI_LIVE_API_ENDPOINT'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'text_input': textInput}),
      // );

      // Simulate API response
      await Future.delayed(Duration(seconds: 1));
      String apiResponseText =
          "This is a response from Gemini to: '$textInput'";
      // byte[] apiResponseAudio = ... // If Gemini sends audio back

      setState(() {
        _messages.add("Gemini: $apiResponseText");
      });
      // If audio is returned, play it:
      // _audioPlayer.play(apiResponseAudio);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gemini Live Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // IconButton(
                //   icon: Icon(Icons.mic),
                //   onPressed: () {
                //     // Start/stop audio recording and send stream
                //   },
                // ),
                // IconButton(
                //   icon: Icon(Icons.camera_alt),
                //   onPressed: () {
                //     // Start/stop camera stream
                //   },
                // ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    _sendToGeminiLiveAPI(textInput: _textController.text);
                    _textController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
