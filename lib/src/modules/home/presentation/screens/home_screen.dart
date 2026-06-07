// // ============================================================
// // LEARN ENGLISH APP — HOME SCREEN with BLoC
// // ============================================================
// // File structure (all in one file for convenience):
// //
// //  1. Models
// //  2. HomeEvent
// //  3. HomeState
// //  4. HomeBloc
// //  5. Widgets (HomeScreen, LessonCard, QuickPracticeGrid, StatsRow)
// //  6. main.dart entry point
// // ============================================================
// ── HomeScreen ─────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/grammar_screen.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/pronun_screen.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/quick_pratice_sreen.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/vocab_screen.dart';
import 'package:images/src/modules/topics/screens/topic_list_screen.dart';
import 'package:images/src/modules/home/presentation/bloc/home_bloc.dart';
import 'package:images/src/modules/home/presentation/bloc/home_event.dart';
import 'package:images/src/modules/home/presentation/bloc/home_state.dart';
import 'package:images/src/modules/home/presentation/widgets/bottom_navigation.dart';
import 'package:images/src/modules/home/presentation/widgets/daily_goal_bar.dart';
import 'package:images/src/modules/home/presentation/widgets/hero_header.dart';
import 'package:images/src/modules/home/presentation/widgets/lesson_card.dart';
import 'package:images/src/modules/home/presentation/widgets/quick_practice_grid.dart';
import 'package:images/src/modules/home/presentation/widgets/section_header.dart';
import 'package:images/src/modules/lesson/presentation/screen/lessons_screen.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/screens/ai_tutor_selection_screen.dart';
import 'package:images/src/modules/settings/presentation/screens/settings_screen.dart';
import 'package:images/src/modules/dictionary/presentation/widgets/dictionary_fab.dart';
import 'package:images/src/utils/color.dart';
import 'package:images/src/utils/enum.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc()..add(const HomeLoaded()),
      child: const _HomeView(),
    );
  }
}

// class _HomeView extends StatefulWidget {
//   const _HomeView();

//   @override
//   State<_HomeView> createState() => _HomeViewState();
// }

// class _HomeViewState extends State<_HomeView> {
//   int _index = 0;

//   static const _pages = [
//     HomeScreen(),
//     // TopicListScreen(),
//     // WordLookupScreen(),
//     // DictionaryScreen(),
//     // ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_index],
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _index,
//         onDestinationSelected: (i) => setState(() => _index = i),
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.home_outlined),
//             selectedIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.menu_book_outlined),
//             selectedIcon: Icon(Icons.menu_book),
//             label: 'Learn',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.translate_outlined),
//             selectedIcon: Icon(Icons.translate),
//             label: 'Dictionary',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.person_outline),
//             selectedIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }
// }

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeNavigateToQuickPracticeScreen) {
            // Use the navigator here based on the emitted state
            Widget screen = switch (state.skillType) {
              SkillType.vocabulary => const VocabScreen(),
              SkillType.grammar => const GrammarScreen(),
              SkillType.reading => const GrammarScreen(), // Placeholder
              SkillType.pronunciation => const PronunScreen(),
            };
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          }
        },
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(
              child: CircularProgressIndicator(color: CustomColors.Amber400),
            );
          }

          if (state is HomeError) {
            return Center(child: Text(state.message));
          }

          if (state is HomeReady) {
            return _ReadyBody(state: state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ReadyBody extends StatelessWidget {
  final HomeReady state;
  const _ReadyBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(child: _buildTabBody(context)),
            BottomNav(selectedIndex: state.selectedNavIndex),
          ],
        ),
        // Floating dictionary bubble — visible on all tabs
        const DictionaryFab(),
      ],
    );
  }

  Widget _buildTabBody(BuildContext context) {
    // This switches the "Screen" content based on the BottomNav index
    switch (state.selectedNavIndex) {
      case 0: // Home Tab
        return _HomeTabContent(state: state);
      case 1:
        return const LessonsScreen();
      case 2:
        return const AiTutorSelectionScreen();
      case 3:
        return const TopicListScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _HomeTabContent extends StatelessWidget {
  final HomeReady state;
  const _HomeTabContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HeroHeader(stats: state.stats)),
        SliverToBoxAdapter(child: DailyGoalBar(stats: state.stats)),
        SliverToBoxAdapter(child: _buildAiTutorBanner(context)),
        SliverToBoxAdapter(
          child: SectionHeader(title: 'Continue learning', onSeeAll: () {}),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => LessonCard(lesson: state.lessons[i]),
            childCount: state.lessons.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Quick practice',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: QuickPracticeGrid(items: state.quickPractices),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildAiTutorBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [CustomColors.Purple900, CustomColors.Purple600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColors.Purple900.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AiTutorSelectionScreen()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '✨ VIRTUAL AI TUTORS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Meet Your AI Tutor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Practice speaking 24/7 with immediate corrections & tips.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Tiny overlapping tutor faces avatar stack
                SizedBox(
                  width: 75,
                  height: 44,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: const NetworkImage(
                              'https://codewayimages.net/cdn-cgi/imagedelivery/rLEmnyzM9Rd0IW4YgVrjXg/aitutorweb/assets/images/landing/heros/hazel.png/w=432,q=85',
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: const NetworkImage(
                              'https://codewayimages.net/cdn-cgi/imagedelivery/rLEmnyzM9Rd0IW4YgVrjXg/aitutorweb/assets/images/landing/heros/mateo.png/w=594,q=85',
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 40,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: const NetworkImage(
                              'https://codewayimages.net/cdn-cgi/imagedelivery/rLEmnyzM9Rd0IW4YgVrjXg/aitutorweb/assets/images/landing/heros/learna-x.png/w=748,q=85',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
