import 'package:equatable/equatable.dart';
import 'package:images/src/utils/enum.dart';

class SessionResult extends Equatable {
  final SkillType skill;
  final int xpEarned;
  final int accuracyPercent;
  final int durationSeconds;
  final int easyCount;
  final int hardCount;
  final int againCount;

  const SessionResult({
    required this.skill,
    required this.xpEarned,
    required this.accuracyPercent,
    required this.durationSeconds,
    required this.easyCount,
    required this.hardCount,
    required this.againCount,
  });

  int get totalCards => easyCount + hardCount + againCount;

  @override
  List<Object?> get props => [
    skill,
    xpEarned,
    accuracyPercent,
    durationSeconds,
    easyCount,
    hardCount,
    againCount,
  ];
}
