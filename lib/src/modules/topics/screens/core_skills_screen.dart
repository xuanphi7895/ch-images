// core_skills_screen.dart
// Matches the dark "Core Skills" design exactly:
//  - Dark background #0D0D0F
//  - 4 skill cards with gradient icon boxes + gradient progress bars
//  - Per-skill gradients: Reading=cyan-blue, Speaking=purple-pink,
//    Listening=blue-cyan-teal, Writing=red-orange-yellow
//  - Level badge (star + text) top-right of each card
//  - % label below each icon
//  - Taps navigate to the correct skill screen

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:images/src/modules/features/listening/presentation/screen/listening_level_screen.dart';
import 'package:images/src/modules/features/reading/presentation/screens/reading_screen.dart';
import 'package:images/src/modules/features/speaking/presentation/screen/speaking_screen.dart';
import 'package:images/src/modules/features/listening/presentation/screen/listening_screen.dart';
import 'package:images/src/utils/enum.dart';
import 'package:images/src/utils/color.dart';
// ─── Replace with your actual screen imports ──────────
// import 'reading_screen.dart';
// import 'speaking_screen.dart';
// import 'listening_screen.dart';
// import 'writing_screen.dart';

// ─────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────

class CoreSkill {
  final EnglishSkillType type;
  final String title;
  final String description;
  final String metaLabel; // e.g. "12 TEXTS"
  final String levelLabel; // e.g. "ADV. I"
  final double progress; // 0.0 – 1.0
  final List<Color> iconGradient;
  final Color iconBorder;
  final List<Color> progressGradient;

  const CoreSkill({
    required this.type,
    required this.title,
    required this.description,
    required this.metaLabel,
    required this.levelLabel,
    required this.progress,
    required this.iconGradient,
    required this.iconBorder,
    required this.progressGradient,
  });
}

const _skills = [
  CoreSkill(
    type: EnglishSkillType.reading,
    title: 'Reading',
    description: 'Scan complex texts and decode subtle meanings.',
    metaLabel: '12 TEXTS',
    levelLabel: 'ADV. I',
    progress: 0.75,
    iconGradient: [Color(0xFF0D2A4A), Color(0xFF0A3D6E)],
    iconBorder: Color(0xFF1A4A80),
    progressGradient: [Color(0xFF00B4DB), Color(0xFF4A90E2), Color(0xFF7B5EA7)],
  ),
  CoreSkill(
    type: EnglishSkillType.speaking,
    title: 'Speaking',
    description: 'Perfect your accent with real-time AI feedback.',
    metaLabel: '48 MINS',
    levelLabel: 'INT. II',
    progress: 0.45,
    iconGradient: [Color(0xFF2A0A3E), Color(0xFF4A1060)],
    iconBorder: Color(0xFF6A1A8A),
    progressGradient: [Color(0xFFA044FF), Color(0xFFE044AB), Color(0xFFFF4488)],
  ),
  CoreSkill(
    type: EnglishSkillType.listening,
    title: 'Listening',
    description: 'Immerse in diverse dialects and sonic environments.',
    metaLabel: '15 AUDIO',
    levelLabel: 'MASTER',
    progress: 0.92,
    iconGradient: [Color(0xFF0A2A3E), Color(0xFF0A3D5E)],
    iconBorder: Color(0xFF0A5A80),
    progressGradient: [Color(0xFF0066FF), Color(0xFF00C6FF), Color(0xFF00E5AA)],
  ),
  CoreSkill(
    type: EnglishSkillType.writing,
    title: 'Writing',
    description: 'Craft sharp, persuasive prose for the digital age.',
    metaLabel: '8 ESSAYS',
    levelLabel: 'BEGINNER',
    progress: 0.30,
    iconGradient: [Color(0xFF2A0A0A), Color(0xFF4A1010)],
    iconBorder: Color(0xFF7A2020),
    progressGradient: [Color(0xFFFF4D4D), Color(0xFFFF8C00), Color(0xFFFFD700)],
  ),
];

// ─────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────

class CoreSkillsScreen extends StatelessWidget {
  const CoreSkillsScreen({super.key});

  void _navigate(BuildContext context, EnglishSkillType type) {
    // Replace with your actual routes:
    switch (type) {
      case EnglishSkillType.reading:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReadingScreen()),
        );
        break;
      case EnglishSkillType.speaking:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SpeakingScreen()),
        );
        break;
      case EnglishSkillType.listening:
        Navigator.push(
          context,
          // MaterialPageRoute(builder: (_) => const ListeningScreen()),
          MaterialPageRoute(builder: (_) => const ListeningLevelsScreen()),
        );
        break;
      case EnglishSkillType.writing:
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (_) => const WritingScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Force white status bar icons on dark bg
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: CustomColors.BlackBackground,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'English Skills',
                      style: TextStyle(
                        color: CustomColors.TitleColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Text(
                    //   'Select a skill to begin training.',
                    //   style: TextStyle(
                    //     color: CustomColors.DescColor,
                    //     fontSize: 14,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            // ── Skill cards ──
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _SkillCard(
                      skill: _skills[i],
                      onTap: () => _navigate(context, _skills[i].type),
                    ),
                  ),
                  childCount: _skills.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// SKILL CARD
// ─────────────────────────────────────────────────────

class _SkillCard extends StatefulWidget {
  final CoreSkill skill;
  final VoidCallback onTap;

  const _SkillCard({required this.skill, required this.onTap});

  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.skill;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: CustomColors.CardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CustomColors.CardBorder, width: 0.5),
          ),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon box
                  _IconBox(skill: s),
                  const SizedBox(width: 14),

                  // Title + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          s.title,
                          style: const TextStyle(
                            color: CustomColors.TitleColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          s.description,
                          style: const TextStyle(
                            color: CustomColors.DescColor,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Level badge
                  _LevelBadge(label: s.levelLabel),
                ],
              ),

              const SizedBox(height: 14),

              // ── Meta + progress ──
              Row(
                children: [
                  const _ClockIcon(),
                  const SizedBox(width: 5),
                  Text(
                    s.metaLabel,
                    style: const TextStyle(
                      color: CustomColors.CardBorder,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Gradient progress bar
              _GradientProgressBar(
                progress: s.progress,
                colors: s.progressGradient,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// ICON BOX  (gradient bg + SVG icon + % label)
// ─────────────────────────────────────────────────────

class _IconBox extends StatelessWidget {
  final CoreSkill skill;
  const _IconBox({required this.skill});

  Widget _icon(EnglishSkillType type) {
    switch (type) {
      case EnglishSkillType.reading:
        return CustomPaint(
          size: const Size(24, 24),
          painter: _ReadingIconPainter(),
        );
      case EnglishSkillType.speaking:
        return CustomPaint(
          size: const Size(24, 24),
          painter: _SpeakingIconPainter(),
        );
      case EnglishSkillType.listening:
        return CustomPaint(
          size: const Size(24, 24),
          painter: _ListeningIconPainter(),
        );
      case EnglishSkillType.writing:
        return CustomPaint(
          size: const Size(24, 24),
          painter: _WritingIconPainter(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = '${(skill.progress * 100).round()}%';

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: skill.iconGradient,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: skill.iconBorder, width: 1),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 10, child: _icon(skill.type)),
          Positioned(
            bottom: 5,
            child: Text(
              pct,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// LEVEL BADGE
// ─────────────────────────────────────────────────────

class _LevelBadge extends StatelessWidget {
  final String label;
  const _LevelBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: CustomColors.BadgeBg,
        border: Border.all(color: CustomColors.BadgeBorder, width: 0.5),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: CustomColors.StarColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: CustomColors.StarColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// GRADIENT PROGRESS BAR
// ─────────────────────────────────────────────────────

class _GradientProgressBar extends StatelessWidget {
  final double progress;
  final List<Color> colors;

  const _GradientProgressBar({required this.progress, required this.colors});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final totalW = constraints.maxWidth;
        final fillW = totalW * progress;

        return Container(
          height: 3,
          width: totalW,
          decoration: BoxDecoration(
            color: CustomColors.ProgTrack,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: fillW,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: LinearGradient(colors: colors),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────
// CLOCK ICON
// ─────────────────────────────────────────────────────

class _ClockIcon extends StatelessWidget {
  const _ClockIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(12, 12), painter: _ClockPainter());
  }
}

// ─────────────────────────────────────────────────────
// CUSTOM PAINTERS — icons matching the design
// ─────────────────────────────────────────────────────

class _ReadingIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final s = size.width / 24;

    // Book outline
    final book = Path()
      ..moveTo(4 * s, 19.5 * s)
      ..arcToPoint(
        Offset(6.5 * s, 17 * s),
        radius: Radius.circular(2.5 * s),
        clockwise: false,
      )
      ..lineTo(20 * s, 17 * s)
      ..moveTo(6.5 * s, 2 * s)
      ..lineTo(20 * s, 2 * s)
      ..lineTo(20 * s, 22 * s)
      ..lineTo(6.5 * s, 22 * s)
      ..arcToPoint(Offset(4 * s, 19.5 * s), radius: Radius.circular(2.5 * s))
      ..lineTo(4 * s, 4.5 * s)
      ..arcToPoint(Offset(6.5 * s, 2 * s), radius: Radius.circular(2.5 * s));
    canvas.drawPath(book, p);

    // Lines
    canvas.drawLine(Offset(9 * s, 7 * s), Offset(15 * s, 7 * s), p);
    canvas.drawLine(Offset(9 * s, 11 * s), Offset(15 * s, 11 * s), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _SpeakingIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final s = size.width / 24;

    // Microphone body
    final mic = Path()
      ..moveTo(12 * s, 1 * s)
      ..arcToPoint(Offset(15 * s, 4 * s), radius: Radius.circular(3 * s))
      ..lineTo(15 * s, 12 * s)
      ..arcToPoint(Offset(9 * s, 12 * s), radius: Radius.circular(3 * s))
      ..lineTo(9 * s, 4 * s)
      ..arcToPoint(Offset(12 * s, 1 * s), radius: Radius.circular(3 * s));
    canvas.drawPath(mic, p);

    // Arc
    final arc = Path()
      ..moveTo(19 * s, 10 * s)
      ..lineTo(19 * s, 12 * s)
      ..arcToPoint(
        Offset(5 * s, 12 * s),
        radius: Radius.circular(7 * s),
        clockwise: false,
      )
      ..lineTo(5 * s, 10 * s);
    canvas.drawPath(arc, p);

    // Stand
    canvas.drawLine(Offset(12 * s, 19 * s), Offset(12 * s, 23 * s), p);
    canvas.drawLine(Offset(8 * s, 23 * s), Offset(16 * s, 23 * s), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ListeningIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final s = size.width / 24;

    // Headphone arc
    final arc = Path()
      ..moveTo(3 * s, 18 * s)
      ..lineTo(3 * s, 12 * s)
      ..arcToPoint(
        Offset(21 * s, 12 * s),
        radius: Radius.circular(9 * s),
        clockwise: false,
      )
      ..lineTo(21 * s, 18 * s);
    canvas.drawPath(arc, p);

    // Left ear
    final leftEar = Path()
      ..moveTo(3 * s, 19 * s)
      ..arcToPoint(
        Offset(5 * s, 21 * s),
        radius: Radius.circular(2 * s),
        clockwise: false,
      )
      ..lineTo(6 * s, 21 * s)
      ..arcToPoint(
        Offset(8 * s, 19 * s),
        radius: Radius.circular(2 * s),
        clockwise: false,
      )
      ..lineTo(8 * s, 16 * s)
      ..arcToPoint(
        Offset(6 * s, 14 * s),
        radius: Radius.circular(2 * s),
        clockwise: false,
      )
      ..lineTo(3 * s, 14 * s);
    canvas.drawPath(leftEar, p);

    // Right ear
    final rightEar = Path()
      ..moveTo(21 * s, 19 * s)
      ..arcToPoint(Offset(19 * s, 21 * s), radius: Radius.circular(2 * s))
      ..lineTo(18 * s, 21 * s)
      ..arcToPoint(Offset(16 * s, 19 * s), radius: Radius.circular(2 * s))
      ..lineTo(16 * s, 16 * s)
      ..arcToPoint(Offset(18 * s, 14 * s), radius: Radius.circular(2 * s))
      ..lineTo(21 * s, 14 * s);
    canvas.drawPath(rightEar, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _WritingIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final s = size.width / 24;

    // Pen path
    final pen = Path()
      ..moveTo(16.5 * s, 3.5 * s)
      ..lineTo(19.5 * s, 6.5 * s)
      ..lineTo(7 * s, 19 * s)
      ..lineTo(3 * s, 20 * s)
      ..lineTo(4 * s, 16 * s)
      ..close();
    canvas.drawPath(pen, p);

    // Bottom line
    canvas.drawLine(Offset(12 * s, 20 * s), Offset(21 * s, 20 * s), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = CustomColors.CardBorder
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 0.5;
    canvas.drawCircle(c, r, p);

    // Hour + minute hands
    canvas.drawLine(c, Offset(c.dx, c.dy - r * 0.55), p);
    canvas.drawLine(c, Offset(c.dx + r * 0.4, c.dy + r * 0.2), p);
  }

  @override
  bool shouldRepaint(_) => false;
}
