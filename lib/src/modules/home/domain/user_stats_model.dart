import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final String name;
  final int streakDays;
  final int weeklyXp;
  final String level;
  final int dailyGoalMinutes;
  final int completedMinutes;

  const UserStats({
    required this.name,
    required this.streakDays,
    required this.weeklyXp,
    required this.level,
    required this.dailyGoalMinutes,
    required this.completedMinutes,
  });

  double get dailyProgress => completedMinutes / dailyGoalMinutes;

  @override
  List<Object?> get props => [
    name,
    streakDays,
    weeklyXp,
    level,
    dailyGoalMinutes,
    completedMinutes,
  ];
}
