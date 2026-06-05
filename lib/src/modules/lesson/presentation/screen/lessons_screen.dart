// lessons_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/lesson/domain/lessons_models.dart';
// import 'package:images/src/modules/home/domain/lesson_model.dart';
import 'package:images/src/modules/lesson/domain/lessons_unit.dart';
import 'package:images/src/modules/lesson/presentation/bloc/lessons_bloc.dart';
import 'package:images/src/modules/lesson/presentation/bloc/lessons_event.dart';
import 'package:images/src/modules/lesson/presentation/bloc/lessons_state.dart';
import 'package:images/src/utils/enum.dart';
import 'package:images/src/utils/extension.dart';

// ─── Design tokens ────────────────────────────────────
const _purple800 = Color(0xFF3C3489);
const _purple600 = Color(0xFF534AB7);
const _purple200 = Color(0xFFAFA9EC);
const _purple50 = Color(0xFFEEEDFE);
const _teal600 = Color(0xFF0F6E56);
const _teal50 = Color(0xFFE1F5EE);
const _blue600 = Color(0xFF185FA5);
const _blue50 = Color(0xFFE6F1FB);
const _coral600 = Color(0xFF993C1D);
const _coral50 = Color(0xFFFAECE7);
const _amber400 = Color(0xFFEF9F27);
const _amber50 = Color(0xFFFAEEDA);
const _green600 = Color(0xFF3B6D11);
const _green50 = Color(0xFFEAF3DE);
const _gray400 = Color(0xFF888780);
const _gray50 = Color(0xFFF1EFE8);

// ─────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LessonsBloc()..add(const LessonsLoaded()),
      child: const _LessonsView(),
    );
  }
}

// ─────────────────────────────────────────────────────
// VIEW
// ─────────────────────────────────────────────────────

class _LessonsView extends StatelessWidget {
  const _LessonsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<LessonsBloc, LessonsState>(
        listener: (context, state) {
          if (state is LessonsNavigateToLesson) {
            // Replace with your actual lesson player route:
            // Navigator.push(context, MaterialPageRoute(
            //   builder: (_) => LessonPlayerScreen(lessonId: state.lessonId),
            // ));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening lesson ${state.lessonId}…'),
                backgroundColor: _purple600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is LessonsLoading || state is LessonsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: _purple600),
            );
          }
          if (state is LessonsReady) {
            return _ReadyBody(state: state);
          }
          if (state is LessonsError) {
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
  final LessonsReady state;
  const _ReadyBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── Sticky header ──
        SliverPersistentHeader(
          pinned: true,
          delegate: _LessonsHeaderDelegate(state: state),
        ),

        // ── No results ──
        if (state.filteredUnits.isEmpty)
          const SliverFillRemaining(child: _EmptyState()),

        // ── Unit accordion list ──
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => _UnitCard(unit: state.filteredUnits[i]),
            childCount: state.filteredUnits.length,
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// STICKY HEADER DELEGATE
// ─────────────────────────────────────────────────────

class _LessonsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final LessonsReady state;
  const _LessonsHeaderDelegate({required this.state});

  @override
  double get minExtent => 120; // collapsed: just filter chips
  @override
  double get maxExtent => 280; // expanded: hero + progress + search + chips

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final shrinkRatio = (shrinkOffset / (maxExtent - minExtent)).clamp(
      0.0,
      1.0,
    );
    final showHero = shrinkRatio < 0.6;

    return Material(
      color: Colors.white,
      elevation: overlapsContent ? 1 : 0,
      child: Column(
        children: [
          // Hero — fades out on scroll
          AnimatedOpacity(
            opacity: showHero ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: showHero
                ? _HeroHeader(state: state)
                : const SizedBox.shrink(),
          ),
          // Search bar
          if (showHero) _SearchBar(),
          // Filter chips — always visible
          _FilterChips(filters: state.filters, activeId: state.activeFilterId),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_LessonsHeaderDelegate old) => old.state != state;
}

// ─────────────────────────────────────────────────────
// HERO HEADER
// ─────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final LessonsReady state;
  const _HeroHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final pct = (state.overallProgress * 100).round();
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 16),
      color: _purple800,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: _purple200,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Lessons',
                  style: TextStyle(
                    color: Color(0xFFEEEDFE),
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  'B1 level',
                  style: const TextStyle(color: _purple200, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.totalCompleted} / ${state.totalLessons} lessons',
                style: const TextStyle(color: _purple200, fontSize: 13),
              ),
              Text(
                '$pct% complete',
                style: const TextStyle(
                  color: _purple200,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: state.overallProgress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(_amber400),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        onChanged: (q) =>
            context.read<LessonsBloc>().add(LessonsSearchChanged(q)),
        decoration: InputDecoration(
          hintText: 'Search lessons…',
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.35),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.black.withOpacity(0.35),
            size: 20,
          ),
          filled: true,
          fillColor: Colors.black.withOpacity(0.05),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// FILTER CHIPS
// ─────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final List<LessonFilter> filters;
  final String activeId;
  const _FilterChips({required this.filters, required this.activeId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final f = filters[i];
          final isActive = f.id == activeId;
          return GestureDetector(
            onTap: () =>
                context.read<LessonsBloc>().add(LessonsFilterChanged(f.id)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _purple600 : Colors.transparent,
                border: Border.all(
                  color: isActive ? _purple600 : Colors.black.withOpacity(0.15),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                f.label,
                style: TextStyle(
                  fontSize: 13,
                  color: isActive ? Colors.white : Colors.black54,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// UNIT CARD (accordion)
// ─────────────────────────────────────────────────────

class _UnitCard extends StatelessWidget {
  final LessonUnit unit;
  const _UnitCard({required this.unit});

  Color get _levelColor {
    switch (unit.level) {
      case LessonLevel.a1:
        return _teal600;
      case LessonLevel.a2:
        return _green600;
      case LessonLevel.b1:
        return _blue600;
      case LessonLevel.b2:
        return _purple600;
      case LessonLevel.c1:
        return _coral600;
    }
  }

  Color get _levelBg {
    switch (unit.level) {
      case LessonLevel.a1:
        return _teal50;
      case LessonLevel.a2:
        return _green50;
      case LessonLevel.b1:
        return _blue50;
      case LessonLevel.b2:
        return _purple50;
      case LessonLevel.c1:
        return _coral50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = (unit.progress * 100).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withOpacity(0.09), width: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // ── Unit header ──
          GestureDetector(
            onTap: () =>
                context.read<LessonsBloc>().add(LessonsUnitToggled(unit.id)),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unit number circle
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: unit.isFullyCompleted ? _teal600 : _levelBg,
                          shape: BoxShape.circle,
                        ),
                        child: unit.isFullyCompleted
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : Center(
                                child: Text(
                                  '${unit.unitNumber}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: _levelColor,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    unit.title,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _levelBg,
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    unit.level.label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: _levelColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              unit.description,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black.withOpacity(0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: unit.isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.black.withOpacity(0.35),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: unit.progress,
                            minHeight: 5,
                            backgroundColor: Colors.black.withOpacity(0.07),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              unit.isFullyCompleted ? _teal600 : _levelColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$pct%',
                        style: TextStyle(
                          fontSize: 12,
                          color: _levelColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Lesson rows (expanded) ──
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Colors.black.withOpacity(0.08),
                ),
                ...unit.lessons.asMap().entries.map((entry) {
                  final isLast = entry.key == unit.lessons.length - 1;
                  return _LessonRow(
                    lesson: entry.value,
                    isLast: isLast,
                    levelColor: _levelColor,
                  );
                }),
              ],
            ),
            crossFadeState: unit.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// LESSON ROW
// ─────────────────────────────────────────────────────

class _LessonRow extends StatelessWidget {
  final Lesson lesson;
  final bool isLast;
  final Color levelColor;
  const _LessonRow({
    required this.lesson,
    required this.isLast,
    required this.levelColor,
  });

  bool get _isInteractable =>
      lesson.status == LessonStatus.available ||
      lesson.status == LessonStatus.inProgress;

  Color get _typeColor {
    switch (lesson.type) {
      case LessonType.listening:
        return _purple600;
      case LessonType.speaking:
        return _teal600;
      case LessonType.reading:
        return _coral600;
      case LessonType.writing:
        return _blue600;
      case LessonType.grammar:
        return _amber400;
      case LessonType.vocabulary:
        return _green600;
    }
  }

  Color get _typeBg {
    switch (lesson.type) {
      case LessonType.listening:
        return _purple50;
      case LessonType.speaking:
        return _teal50;
      case LessonType.reading:
        return _coral50;
      case LessonType.writing:
        return _blue50;
      case LessonType.grammar:
        return _amber50;
      case LessonType.vocabulary:
        return _green50;
    }
  }

  IconData get _typeIcon {
    switch (lesson.type) {
      case LessonType.listening:
        return Icons.headphones_outlined;
      case LessonType.speaking:
        return Icons.chat_bubble_outline;
      case LessonType.reading:
        return Icons.menu_book_outlined;
      case LessonType.writing:
        return Icons.edit_outlined;
      case LessonType.grammar:
        return Icons.edit_note_outlined;
      case LessonType.vocabulary:
        return Icons.spellcheck_outlined;
    }
  }

  Widget _statusWidget() {
    switch (lesson.status) {
      case LessonStatus.completed:
        return Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: _teal600,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 15),
        );
      case LessonStatus.inProgress:
        return SizedBox(
          width: 28,
          height: 28,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: lesson.progress,
                strokeWidth: 2.5,
                backgroundColor: Colors.black.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(levelColor),
              ),
              Icon(Icons.play_arrow_rounded, color: levelColor, size: 14),
            ],
          ),
        );
      case LessonStatus.available:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            border: Border.all(color: levelColor, width: 1.5),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.play_arrow_rounded, color: levelColor, size: 14),
        );
      case LessonStatus.locked:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.lock_outline,
            color: Colors.black.withOpacity(0.3),
            size: 14,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = lesson.status == LessonStatus.locked;

    return GestureDetector(
      onTap: _isInteractable
          ? () => context.read<LessonsBloc>().add(LessonTapped(lesson.id))
          : null,
      child: Opacity(
        opacity: isLocked ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: Colors.black.withOpacity(0.06),
                      width: 0.5,
                    ),
                  ),
          ),
          child: Row(
            children: [
              // Type icon
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _typeBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 18),
              ),
              const SizedBox(width: 12),
              // Title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isLocked ? Colors.black54 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        _TypeBadge(
                          label: lesson.type.label,
                          color: _typeColor,
                          bg: _typeBg,
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.black.withOpacity(0.35),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${lesson.durationMinutes} min',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.bolt_outlined,
                          size: 12,
                          color: Colors.black.withOpacity(0.35),
                        ),
                        Text(
                          '+${lesson.xpReward} XP',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                    // In-progress bar
                    if (lesson.status == LessonStatus.inProgress) ...[
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: lesson.progress,
                          minHeight: 3,
                          backgroundColor: Colors.black.withOpacity(0.07),
                          valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _statusWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _TypeBadge({
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.search_off_outlined,
          size: 52,
          color: Colors.black.withOpacity(0.2),
        ),
        const SizedBox(height: 16),
        Text(
          'No lessons found',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Try a different filter or search term',
          style: TextStyle(fontSize: 13, color: Colors.black.withOpacity(0.35)),
        ),
      ],
    );
  }
}
