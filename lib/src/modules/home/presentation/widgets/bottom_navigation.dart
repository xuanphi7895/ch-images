// ── Bottom nav ─────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/home/presentation/bloc/home_bloc.dart';
import 'package:images/src/modules/home/presentation/bloc/home_event.dart';
import 'package:images/src/utils/color.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  const BottomNav({super.key, required this.selectedIndex});

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.library_books_outlined, 'Lessons'),
    (Icons.emoji_events_outlined, 'Leaderboard'),
    (Icons.bar_chart_outlined, 'Progress'),
    (Icons.settings_outlined, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.08), width: 0.5),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (i) {
          final selected = i == selectedIndex;
          return GestureDetector(
            onTap: () => context.read<HomeBloc>().add(NavTabChanged(i)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _items[i].$1,
                  size: 24,
                  color: selected ? CustomColors.Purple600 : Colors.black38,
                ),
                const SizedBox(height: 4),
                Text(
                  _items[i].$2,
                  style: TextStyle(
                    fontSize: 10,
                    color: selected ? CustomColors.Purple600 : Colors.black38,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
