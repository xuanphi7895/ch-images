import 'package:flutter/material.dart';
import 'package:images/src/modules/features/ai_tutor/data/ai_tutor_model.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/screens/ai_tutor_chat_screen.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/widgets/tutor_card.dart';
import 'package:images/src/utils/color.dart';

class AiTutorSelectionScreen extends StatefulWidget {
  const AiTutorSelectionScreen({super.key});

  @override
  State<AiTutorSelectionScreen> createState() => _AiTutorSelectionScreenState();
}

class _AiTutorSelectionScreenState extends State<AiTutorSelectionScreen> {
  String _selectedLanguageFilter = 'All';

  @override
  Widget build(BuildContext context) {
    // Filter tutors based on selected language
    final filteredTutors = AiTutor.mockTutors.where((tutor) {
      if (_selectedLanguageFilter == 'All') return true;
      return tutor.language.toLowerCase() == _selectedLanguageFilter.toLowerCase();
    }).toList();

    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'AI Tutors',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2A3C44),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Headline Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meet Your AI Tutor',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.Purple900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Practice speaking with confidence. Get immediate feedback on grammar, pronunciation, and vocabulary.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.55),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            // Language Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: ['All', 'English', 'Spanish'].map((lang) {
                  final isSelected = _selectedLanguageFilter == lang;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(lang),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedLanguageFilter = lang;
                        });
                      },
                      selectedColor: CustomColors.Purple600,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      backgroundColor: Colors.black.withOpacity(0.04),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            // Tutors Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // Single column list for full details card
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.85,
                ),
                itemCount: filteredTutors.length,
                itemBuilder: (context, index) {
                  final tutor = filteredTutors[index];
                  return TutorCard(
                    tutor: tutor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AiTutorChatScreen(tutor: tutor),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
