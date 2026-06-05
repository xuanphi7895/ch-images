import 'package:flutter/material.dart';
import 'package:images/src/utils/color.dart';

class LessonBadge extends StatelessWidget {
  final String text;
  final bool isNew;
  const LessonBadge({super.key, required this.text, required this.isNew});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isNew ? CustomColors.Teal50 : CustomColors.Purple50,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: isNew ? CustomColors.Teal50 : CustomColors.Purple50,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
