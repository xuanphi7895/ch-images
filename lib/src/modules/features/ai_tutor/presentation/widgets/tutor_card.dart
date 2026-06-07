import 'package:flutter/material.dart';
import 'package:images/src/modules/features/ai_tutor/data/ai_tutor_model.dart';
import 'package:images/src/utils/color.dart';

class TutorCard extends StatelessWidget {
  final AiTutor tutor;
  final VoidCallback onTap;

  const TutorCard({
    super.key,
    required this.tutor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSpanish = tutor.language.toLowerCase() == 'spanish';
    final accentColor = isSpanish ? CustomColors.Amber400 : CustomColors.Purple600;
    final bgLightColor = isSpanish ? CustomColors.Coral50 : CustomColors.Purple50;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Avatar Banner Area
            Stack(
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accentColor.withOpacity(0.15),
                        accentColor.withOpacity(0.02),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(3),
                      child: ClipOval(
                        child: Image.network(
                          tutor.avatarUrl,
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: bgLightColor,
                            child: Icon(
                              Icons.face_retouching_natural_outlined,
                              size: 32,
                              color: accentColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Language badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isSpanish ? '🇪🇸' : '🇬🇧',
                          style: const TextStyle(fontSize: 10),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tutor.language,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Level Tag
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: bgLightColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      tutor.level.split(' ').first,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info Area
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tutor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A3C44),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Color(0xFF40DF9F),
                        size: 14,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tutor.accent,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withOpacity(0.45),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tutor.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black.withOpacity(0.65),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Specialty chips
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tutor.specialties.take(2).map((s) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.black.withOpacity(0.55),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
