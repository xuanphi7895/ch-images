// quick_practice_screen.dart
// The hub screen the user sees when tapping "Quick Practice" from Home.
// Shows all 4 skill tiles, today's due counts, weekly stats, and a recent streak row.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/grammar_screen.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/pronun_screen.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/vocab_screen.dart';

// ─── Design tokens ──────────────────────────────────
const Purple800 = Color(0xFF3C3489);
const Purple600 = Color(0xFF534AB7);
const Purple200 = Color(0xFFAFA9EC);
const Purple50 = Color(0xFFEEEDFE);
const Teal600 = Color(0xFF0F6E56);
const Teal50 = Color(0xFFE1F5EE);
const Blue600 = Color(0xFF185FA5);
const Blue50 = Color(0xFFE6F1FB);
const Coral600 = Color(0xFF993C1D);
const Coral50 = Color(0xFFFAECE7);
const Amber400 = Color(0xFFEF9F27);
const _green600 = Color(0xFF3B6D11);
const _green50 = Color(0xFFEAF3DE);

// ─────────────────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────────────────

enum PracticeSkill { vocabulary, grammar, reading, pronunciation }

class SkillTileData extends Equatable {
  final PracticeSkill skill;
  final String title;
  final String subtitle; // e.g. "24 cards due"
  final int dueCount;
  final int totalXpThisWeek;
  final double weeklyProgress; // 0.0–1.0
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const SkillTileData({
    required this.skill,
    required this.title,
    required this.subtitle,
    required this.dueCount,
    required this.totalXpThisWeek,
    required this.weeklyProgress,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  List<Object?> get props => [skill, title, subtitle, dueCount];
}

class PracticeStats extends Equatable {
  final int totalMinutesToday;
  final int currentStreak;
  final int weeklyXp;
  final List<bool> weekActivity; // 7 days, true = practiced

  const PracticeStats({
    required this.totalMinutesToday,
    required this.currentStreak,
    required this.weeklyXp,
    required this.weekActivity,
  });

  @override
  List<Object?> get props => [
    totalMinutesToday,
    currentStreak,
    weeklyXp,
    weekActivity,
  ];
}

// ─────────────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────────────

abstract class QuickPracticeEvent extends Equatable {
  const QuickPracticeEvent();
  @override
  List<Object?> get props => [];
}

class QuickPracticeLoaded extends QuickPracticeEvent {
  const QuickPracticeLoaded();
}

class SkillTapped extends QuickPracticeEvent {
  final PracticeSkill skill;
  const SkillTapped(this.skill);
  @override
  List<Object?> get props => [skill];
}

class StartAllTapped extends QuickPracticeEvent {
  const StartAllTapped();
}

// ─────────────────────────────────────────────────────
// STATES
// ─────────────────────────────────────────────────────

abstract class QuickPracticeState extends Equatable {
  const QuickPracticeState();
  @override
  List<Object?> get props => [];
}

class QuickPracticeInitial extends QuickPracticeState {
  const QuickPracticeInitial();
}

class QuickPracticeLoading extends QuickPracticeState {
  const QuickPracticeLoading();
}

class QuickPracticeReady extends QuickPracticeState {
  final List<SkillTileData> skills;
  final PracticeStats stats;

  const QuickPracticeReady({required this.skills, required this.stats});

  int get totalDueItems => skills.fold(0, (sum, s) => sum + s.dueCount);

  @override
  List<Object?> get props => [skills, stats];
}

class QuickPracticeError extends QuickPracticeState {
  final String message;
  const QuickPracticeError(this.message);
  @override
  List<Object?> get props => [message];
}

// Side-effect state for navigation (handled via BlocListener)
class QuickPracticeNavigate extends QuickPracticeState {
  final PracticeSkill skill;
  const QuickPracticeNavigate(this.skill);
  @override
  List<Object?> get props => [skill];
}

class QuickPracticeNavigateAll extends QuickPracticeState {
  const QuickPracticeNavigateAll();
}

// ─────────────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────────────

class QuickPracticeBloc extends Bloc<QuickPracticeEvent, QuickPracticeState> {
  QuickPracticeBloc() : super(const QuickPracticeInitial()) {
    on<QuickPracticeLoaded>(_onLoaded);
    on<SkillTapped>(_onSkillTapped);
    on<StartAllTapped>(_onStartAll);
  }

  static const _mockSkills = [
    SkillTileData(
      skill: PracticeSkill.vocabulary,
      title: 'Vocabulary',
      subtitle: '24 cards due',
      dueCount: 24,
      totalXpThisWeek: 120,
      weeklyProgress: 0.72,
      icon: Icons.spellcheck_outlined,
      iconColor: Purple600,
      iconBg: Purple50,
    ),
    SkillTileData(
      skill: PracticeSkill.grammar,
      title: 'Grammar',
      subtitle: 'Past perfect',
      dueCount: 10,
      totalXpThisWeek: 80,
      weeklyProgress: 0.50,
      icon: Icons.edit_note_outlined,
      iconColor: Teal600,
      iconBg: Teal50,
    ),
    SkillTileData(
      skill: PracticeSkill.reading,
      title: 'Reading',
      subtitle: '2 articles',
      dueCount: 2,
      totalXpThisWeek: 60,
      weeklyProgress: 0.35,
      icon: Icons.menu_book_outlined,
      iconColor: Coral600,
      iconBg: Coral50,
    ),
    SkillTileData(
      skill: PracticeSkill.pronunciation,
      title: 'Pronunciation',
      subtitle: 'Vowel sounds',
      dueCount: 8,
      totalXpThisWeek: 40,
      weeklyProgress: 0.20,
      icon: Icons.mic_none_outlined,
      iconColor: Blue600,
      iconBg: Blue50,
    ),
  ];

  static const _mockStats = PracticeStats(
    totalMinutesToday: 15,
    currentStreak: 12,
    weeklyXp: 340,
    weekActivity: [true, true, false, true, true, true, false],
  );

  Future<void> _onLoaded(
    QuickPracticeLoaded event,
    Emitter<QuickPracticeState> emit,
  ) async {
    emit(const QuickPracticeLoading());
    // Replace with real repository call
    await Future.delayed(const Duration(milliseconds: 500));
    emit(const QuickPracticeReady(skills: _mockSkills, stats: _mockStats));
  }

  void _onSkillTapped(SkillTapped event, Emitter<QuickPracticeState> emit) {
    // Navigation handled in BlocListener
    emit(QuickPracticeNavigate(event.skill));
    // Re-emit ready state so the screen stays rendered after navigation
    emit(const QuickPracticeReady(skills: _mockSkills, stats: _mockStats));
  }

  void _onStartAll(StartAllTapped event, Emitter<QuickPracticeState> emit) {
    emit(const QuickPracticeNavigateAll());
    emit(const QuickPracticeReady(skills: _mockSkills, stats: _mockStats));
  }
}

// ─────────────────────────────────────────────────────
// SCREEN ENTRY POINT
// ─────────────────────────────────────────────────────

class QuickPracticeScreen extends StatelessWidget {
  const QuickPracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QuickPracticeBloc()..add(const QuickPracticeLoaded()),
      child: const _QuickPracticeView(),
    );
  }
}

// ─────────────────────────────────────────────────────
// VIEW
// ─────────────────────────────────────────────────────

class _QuickPracticeView extends StatelessWidget {
  const _QuickPracticeView();

  void _navigate(BuildContext context, PracticeSkill skill) {
    // Replace these with your actual route pushes:
    // VocabScreen, GrammarScreen, ReadingScreen, PronunScreen
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Opening ${skill.name} practice…'),
    //     duration: const Duration(seconds: 1),
    //     backgroundColor: Purple600,
    //     behavior: SnackBarBehavior.floating,
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    //   ),
    // );
    // Example:
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          switch (skill) {
            case PracticeSkill.vocabulary:
              return const VocabScreen();
            case PracticeSkill.grammar:
              return const GrammarScreen();
            case PracticeSkill.reading:
              return const GrammarScreen();
            case PracticeSkill.pronunciation:
              return const PronunScreen();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<QuickPracticeBloc, QuickPracticeState>(
        listener: (context, state) {
          if (state is QuickPracticeNavigate) {
            _navigate(context, state.skill);
          }
          if (state is QuickPracticeNavigateAll) {
            // Launch multi-skill session flow
            _navigate(context, PracticeSkill.vocabulary);
          }
        },
        builder: (context, state) {
          if (state is QuickPracticeLoading || state is QuickPracticeInitial) {
            return const Center(
              child: CircularProgressIndicator(color: Purple600),
            );
          }
          if (state is QuickPracticeReady) {
            return _ReadyBody(state: state);
          }
          if (state is QuickPracticeError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// BODY
// ─────────────────────────────────────────────────────

class _ReadyBody extends StatelessWidget {
  final QuickPracticeReady state;
  const _ReadyBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _Header(stats: state.stats)),
        SliverToBoxAdapter(child: _StatsRow(stats: state.stats)),
        SliverToBoxAdapter(
          child: _WeekStreak(activity: state.stats.weekActivity),
        ),
        SliverToBoxAdapter(child: _DueCountBanner(total: state.totalDueItems)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _SkillTile(tile: state.skills[i]),
              childCount: state.skills.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.88,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _StartAllButton(total: state.totalDueItems)),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final PracticeStats stats;
  const _Header({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 28,
      ),
      color: Purple800,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Purple200,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Quick practice',
              style: TextStyle(
                color: Color(0xFFEEEDFE),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${stats.currentStreak} day streak',
                  style: const TextStyle(
                    color: Amber400,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final PracticeStats stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          _MiniStatCard(
            label: 'Today',
            value: '${stats.totalMinutesToday} min',
            icon: Icons.access_time_outlined,
            color: Purple600,
            bg: Purple50,
          ),
          const SizedBox(width: 10),
          _MiniStatCard(
            label: 'Weekly XP',
            value: '${stats.weeklyXp} XP',
            icon: Icons.bolt_outlined,
            color: Teal600,
            bg: Teal50,
          ),
          const SizedBox(width: 10),
          _MiniStatCard(
            label: 'Streak',
            value: '${stats.currentStreak} days',
            icon: Icons.local_fire_department_outlined,
            color: Coral600,
            bg: Coral50,
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekStreak extends StatelessWidget {
  final List<bool> activity; // 7 items, index 0 = Mon
  const _WeekStreak({required this.activity});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This week',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final active = i < activity.length && activity[i];
                final isToday = i == 5; // Saturday = today (example)
                return Column(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: active
                            ? Purple600
                            : Colors.black.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(color: Purple600, width: 2)
                            : null,
                      ),
                      child: active
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _days[i],
                      style: TextStyle(
                        fontSize: 11,
                        color: active
                            ? Purple600
                            : Colors.black.withOpacity(0.35),
                        fontWeight: active
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DueCountBanner extends StatelessWidget {
  final int total;
  const _DueCountBanner({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Choose a skill',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          if (total > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Coral50,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                '$total due',
                style: const TextStyle(
                  fontSize: 12,
                  color: Coral600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// SKILL TILE
// ─────────────────────────────────────────────────────

class _SkillTile extends StatelessWidget {
  final SkillTileData tile;
  const _SkillTile({required this.tile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<QuickPracticeBloc>().add(SkillTapped(tile.skill)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.09), width: 0.5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: tile.iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(tile.icon, color: tile.iconColor, size: 22),
                ),
                if (tile.dueCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: tile.iconBg,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      '${tile.dueCount}',
                      style: TextStyle(
                        fontSize: 12,
                        color: tile.iconColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              tile.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              tile.subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 10),
            // Weekly progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: tile.weeklyProgress,
                      minHeight: 4,
                      backgroundColor: Colors.black.withOpacity(0.07),
                      valueColor: AlwaysStoppedAnimation<Color>(tile.iconColor),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(tile.weeklyProgress * 100).round()}%',
                  style: TextStyle(
                    fontSize: 11,
                    color: tile.iconColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// START ALL BUTTON
// ─────────────────────────────────────────────────────

class _StartAllButton extends StatelessWidget {
  final int total;
  const _StartAllButton({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Purple600,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          icon: const Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 22,
          ),
          label: Text(
            total > 0
                ? 'Start all ($total items due)'
                : 'Start practice session',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () =>
              context.read<QuickPracticeBloc>().add(const StartAllTapped()),
        ),
      ),
    );
  }
}
