import 'package:equatable/equatable.dart';
import 'package:images/src/utils/enum.dart';

class QuickPractice extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final SkillType skill;

  const QuickPractice({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.skill,
  });

  @override
  List<Object?> get props => [id, title, subtitle, skill];
}
