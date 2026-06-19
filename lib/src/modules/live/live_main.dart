import 'package:flutter/material.dart';

import 'package:images/src/utils/api_key_store.dart';
import 'package:images/src/utils/color.dart';
import 'chat_page.dart';
import 'function_calling_demo.dart';
import 'live_api_demo.dart';
import 'realtime_media_demo.dart';

class LiveApp extends StatelessWidget {
  const LiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Try the Live API',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const LivePage(),
    );
  }
}

class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  Future<void> _openApiKeySettings() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => const _ApiKeyDialog(),
    );

    if (changed == true && mounted) {
      setState(() {});
    }
  }

  void _openDemoPage(BuildContext context, Widget page) {
    if (!ApiKeyStore.hasApiKey) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'The Gemini API key has been set. Please enter it in the settings first.',
          ),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: _openApiKeySettings,
          ),
        ),
      );
      return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
        ),
        title: const Text('Gemini Live API Examples'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'API Key Settings',
            onPressed: _openApiKeySettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader('Basic Examples'),
          _buildDemoCard(
            context: context,
            title: 'Chat Interface',
            subtitle: 'Basic chat with text, image, and audio input',
            icon: Icons.chat,
            color: Colors.blue,
            page: const ChatPage(),
          ),
          const SizedBox(height: 16),
          _buildHeader('New Features'),
          _buildDemoCard(
            context: context,
            title: 'Live API Features',
            subtitle:
                'Demo of all new features: VAD, transcription, session resumption, etc.',
            icon: Icons.auto_awesome,
            color: Colors.purple,
            page: const LiveAPIDemoPage(),
          ),
          const SizedBox(height: 12),
          _buildDemoCard(
            context: context,
            title: 'Function Calling',
            subtitle: 'Tool calling with weather/time/fx/search/reminder',
            icon: Icons.functions,
            color: Colors.green,
            page: const FunctionCallingDemoPage(),
          ),
          const SizedBox(height: 12),
          _buildDemoCard(
            context: context,
            title: 'Realtime Media',
            subtitle:
                'Realtime camera preview, microphone streaming, and activity detection',
            icon: Icons.videocam,
            color: Colors.orange,
            page: const RealtimeMediaDemoPage(),
          ),
          const SizedBox(height: 24),
          _buildHeader('Setup'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'API Key Configuration',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Status:'),
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(
                          ApiKeyStore.hasApiKey
                              ? 'Configured (${ApiKeyStore.maskedApiKey})'
                              : 'Not configured',
                        ),
                        backgroundColor: ApiKeyStore.hasApiKey
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can enter or modify the API key in the Settings menu on the app screen.',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Get your API key from: https://aistudio.google.com/app/apikey',
                    style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _openApiKeySettings,
                    icon: const Icon(Icons.settings),
                    label: const Text('Open Settings'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // _buildHeader('New Features Included'),
          // _buildFeatureChip('toolCall / LiveServerToolCall'),
          // _buildFeatureChip('toolCallCancellation'),
          // _buildFeatureChip('goAway / LiveServerGoAway'),
          // _buildFeatureChip('sessionResumptionUpdate'),
          // _buildFeatureChip('voiceActivityDetection'),
          // _buildFeatureChip('realtimeInputConfig'),
          // _buildFeatureChip('audioTranscription'),
          // _buildFeatureChip('contextWindowCompression'),
          // _buildFeatureChip('proactivityConfig'),
          // _buildFeatureChip('mediaChunks'),
          // _buildFeatureChip('activityStart/End'),
          // _buildFeatureChip('sendClientContent()'),
          // _buildFeatureChip('sendToolResponse()'),
          // _buildFeatureChip('sendRealtimeInput()'),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDemoCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _openDemoPage(context, page),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Chip(
        label: Text(feature, style: const TextStyle(fontSize: 11)),
        backgroundColor: Colors.blue.shade50,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ApiKeyDialog extends StatefulWidget {
  const _ApiKeyDialog();

  @override
  State<_ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<_ApiKeyDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ApiKeyStore.apiKey);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Gemini API Key'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: 'Paste your API key',
          helperText: 'Get it from AI Studio',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await ApiKeyStore.save('');
            if (mounted) Navigator.pop(context, true);
          },
          child: const Text('Clear', style: TextStyle(color: Colors.red)),
        ),
        FilledButton(
          onPressed: () async {
            await ApiKeyStore.save(_controller.text);
            if (mounted) Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _ApiKeyStatusBadge extends StatelessWidget {
  final VoidCallback onTap;
  const _ApiKeyStatusBadge({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasKey = ApiKeyStore.hasApiKey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: hasKey ? CustomColors.Teal600 : CustomColors.Coral600,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasKey
                  ? Icons.vpn_key_outlined
                  : Icons.no_encryption_gmailerrorred_outlined,
              size: 10,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              hasKey ? 'Key Configured' : 'Setup Key',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
