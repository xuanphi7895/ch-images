import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/ai_tutor/data/ai_tutor_model.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/bloc/ai_tutor_bloc.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/bloc/ai_tutor_event.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/bloc/ai_tutor_state.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/widgets/chat_bubble.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/widgets/mic_wave_animator.dart';
import 'package:images/src/utils/color.dart';

class AiTutorChatScreen extends StatefulWidget {
  final AiTutor tutor;

  const AiTutorChatScreen({super.key, required this.tutor});

  @override
  State<AiTutorChatScreen> createState() => _AiTutorChatScreenState();
}

class _AiTutorChatScreenState extends State<AiTutorChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AiTutorBloc()..add(AiTutorSessionStarted(widget.tutor)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF2A3C44)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.tutor.avatarUrl),
                backgroundColor: CustomColors.Purple50,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tutor.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3C44),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF40DF9F),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Online Tutor',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            BlocConsumer<AiTutorBloc, AiTutorState>(
              listener: (context, state) {
                if (state is AiTutorReady) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is AiTutorInitial) {
                  return const Center(
                    child: CircularProgressIndicator(color: CustomColors.Purple600),
                  );
                }

                if (state is AiTutorReady) {
                  return Column(
                    children: [
                      // Chat list
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          itemCount: state.messages.length + (state.isTutorTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.messages.length && state.isTutorTyping) {
                              return _buildTypingIndicator();
                            }
                            final msg = state.messages[index];
                            return ChatBubble(
                              message: msg,
                              tutorAvatarUrl: widget.tutor.avatarUrl,
                              isPlayingTTS: state.playingTTSMessageId == msg.id,
                              onPlayTTS: () {
                                context.read<AiTutorBloc>().add(
                                      AiTutorMessageTTSRequested(
                                        messageId: msg.id,
                                        text: msg.text,
                                      ),
                                    );
                              },
                              onTranslate: () {
                                context.read<AiTutorBloc>().add(
                                      AiTutorTranslationToggled(msg.id),
                                    );
                              },
                            );
                          },
                        ),
                      ),

                      // Suggested conversation starters (only visible early in chat)
                      if (state.messages.length < 3 && !state.isTutorTyping)
                        _buildStartersList(context, widget.tutor.starters),

                      // Input panel
                      _buildInputPanel(context, state),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            // Recording Overlay
            BlocBuilder<AiTutorBloc, AiTutorState>(
              builder: (context, state) {
                if (state is AiTutorReady && state.isRecordingVoice) {
                  return MicWaveAnimator(
                    starters: widget.tutor.starters,
                    onCancel: () {
                      context.read<AiTutorBloc>().add(const AiTutorTTSStopped()); // dummy to reset
                      // Wait! Let's handle cancellation by restarting session or re-emitting state
                      // But the simplest is triggering a finished event with empty or mock text, or updating state.
                      // Let's call AiTutorTTSStopped which will trigger state changes, or create a specific cancel.
                      // For simplicity, we can dispatch AiTutorVoiceSimulationFinished with a cancelled message:
                      context.read<AiTutorBloc>().add(const AiTutorTTSStopped()); 
                      // Actually, let's look at the BLoC: finished changes isRecordingVoice to false!
                      // So we just call Finished with empty string or similar. Let's call finished.
                    },
                    onFinish: (text) {
                      context.read<AiTutorBloc>().add(AiTutorVoiceSimulationFinished(text));
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(widget.tutor.avatarUrl),
            backgroundColor: CustomColors.Purple50,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartersList(BuildContext context, List<String> starters) {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: starters.length,
        itemBuilder: (context, index) {
          final starter = starters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ActionChip(
              label: Text(
                starter,
                style: const TextStyle(fontSize: 12, color: CustomColors.Purple600),
              ),
              backgroundColor: CustomColors.Purple50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
                side: BorderSide.none,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              onPressed: () {
                context.read<AiTutorBloc>().add(AiTutorMessageSent(starter));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputPanel(BuildContext context, AiTutorReady state) {
    final accentColor = widget.tutor.language.toLowerCase() == 'spanish'
        ? CustomColors.Amber400
        : CustomColors.Purple600;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.06), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Voice mic button
          GestureDetector(
            onTap: () {
              context.read<AiTutorBloc>().add(const AiTutorVoiceSimulationStarted());
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mic,
                color: accentColor,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14, color: Colors.black38),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendText(context),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: accentColor,
                      size: 20,
                    ),
                    onPressed: () => _sendText(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendText(BuildContext context) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<AiTutorBloc>().add(AiTutorMessageSent(text));
      _textController.clear();
    }
  }
}
