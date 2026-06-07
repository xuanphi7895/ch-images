import 'package:flutter/material.dart';
import 'package:images/src/utils/color.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ── Learning preferences ─────────────────
  int _dailyGoalMinutes = 15;
  String _selectedLevel = 'Intermediate';
  String _selectedAccent = 'American English';

  // ── Notifications ────────────────────────
  bool _dailyReminder = true;
  bool _streakAlert = true;
  bool _newLessonAlert = false;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);

  // ── Appearance ───────────────────────────
  bool _darkMode = false;
  double _textSize = 1.0; // scale factor: 0.8 / 1.0 / 1.2

  // ── Audio ────────────────────────────────
  bool _autoPlay = true;
  double _speechSpeed = 0.9;
  bool _soundEffects = true;

  // ─────────────────────────────────────────

  final List<int> _goalOptions = [5, 10, 15, 20, 30];
  final List<String> _levels = ['Beginner', 'Elementary', 'Intermediate', 'Upper-Intermediate', 'Advanced'];
  final List<String> _accents = ['American English', 'British English', 'Australian English'];

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildProfileCard(context)),
          SliverToBoxAdapter(child: _buildSection('🎯 Learning', _learningTiles(context))),
          SliverToBoxAdapter(child: _buildSection('🔔 Notifications', _notificationTiles(context))),
          SliverToBoxAdapter(child: _buildSection('🔊 Audio & Speech', _audioTiles())),
          SliverToBoxAdapter(child: _buildSection('🎨 Appearance', _appearanceTiles())),
          SliverToBoxAdapter(child: _buildSection('🔒 Account', _accountTiles(context))),
          SliverToBoxAdapter(child: _buildSection('ℹ️ About', _aboutTiles(context))),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ── Sliver AppBar ────────────────────────
  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 100,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color(0xFF26215C),
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEEEDFE), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }

  // ── Profile card ─────────────────────────
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CustomColors.Purple900, CustomColors.Purple600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CustomColors.Purple600.withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
              border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
            ),
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phi Tran Xuan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Intermediate · 🔥 12-day streak',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Edit
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section wrapper ───────────────────────
  Widget _buildSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF534AB7),
              letterSpacing: 0.4,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: tiles
                .asMap()
                .entries
                .map((entry) => Column(
                      children: [
                        entry.value,
                        if (entry.key < tiles.length - 1)
                          Divider(
                            height: 0.5,
                            thickness: 0.5,
                            indent: 56,
                            color: Colors.black.withOpacity(0.06),
                          ),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  // ── Learning tiles ───────────────────────
  List<Widget> _learningTiles(BuildContext context) {
    return [
      // Daily goal
      _SettingsTile(
        icon: Icons.flag_outlined,
        iconColor: CustomColors.Teal600,
        iconBg: CustomColors.Teal50,
        title: 'Daily Goal',
        subtitle: '$_dailyGoalMinutes min / day',
        trailing: _PillSelector(
          options: _goalOptions.map((e) => '${e}m').toList(),
          selectedIndex: _goalOptions.indexOf(_dailyGoalMinutes),
          onSelected: (i) => setState(() => _dailyGoalMinutes = _goalOptions[i]),
        ),
      ),
      // Level
      _SettingsTile(
        icon: Icons.signal_cellular_alt_outlined,
        iconColor: CustomColors.Blue600,
        iconBg: CustomColors.Blue50,
        title: 'My Level',
        subtitle: _selectedLevel,
        onTap: () => _showPicker(
          context,
          title: 'Choose your level',
          options: _levels,
          selected: _selectedLevel,
          onSelected: (v) => setState(() => _selectedLevel = v),
        ),
      ),
      // Accent
      _SettingsTile(
        icon: Icons.language_outlined,
        iconColor: CustomColors.Purple600,
        iconBg: CustomColors.Purple50,
        title: 'Preferred Accent',
        subtitle: _selectedAccent,
        onTap: () => _showPicker(
          context,
          title: 'Choose accent',
          options: _accents,
          selected: _selectedAccent,
          onSelected: (v) => setState(() => _selectedAccent = v),
        ),
      ),
    ];
  }

  // ── Notification tiles ───────────────────
  List<Widget> _notificationTiles(BuildContext context) {
    return [
      _SettingsTile(
        icon: Icons.alarm_outlined,
        iconColor: CustomColors.Amber400,
        iconBg: const Color(0xFFFFF7E6),
        title: 'Daily Reminder',
        subtitle: _dailyReminder ? 'At ${_formatTime(_reminderTime)}' : 'Off',
        trailing: Switch.adaptive(
          value: _dailyReminder,
          activeColor: CustomColors.Purple600,
          onChanged: (v) => setState(() => _dailyReminder = v),
        ),
        onTap: _dailyReminder
            ? () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime,
                );
                if (t != null) setState(() => _reminderTime = t);
              }
            : null,
      ),
      _SettingsTile(
        icon: Icons.local_fire_department_outlined,
        iconColor: Colors.deepOrange,
        iconBg: const Color(0xFFFFF0EC),
        title: 'Streak Alert',
        subtitle: 'Remind when streak at risk',
        trailing: Switch.adaptive(
          value: _streakAlert,
          activeColor: CustomColors.Purple600,
          onChanged: (v) => setState(() => _streakAlert = v),
        ),
      ),
      _SettingsTile(
        icon: Icons.new_releases_outlined,
        iconColor: CustomColors.Teal600,
        iconBg: CustomColors.Teal50,
        title: 'New Lessons',
        subtitle: 'Get notified about new content',
        trailing: Switch.adaptive(
          value: _newLessonAlert,
          activeColor: CustomColors.Purple600,
          onChanged: (v) => setState(() => _newLessonAlert = v),
        ),
      ),
    ];
  }

  // ── Audio tiles ──────────────────────────
  List<Widget> _audioTiles() {
    return [
      _SettingsTile(
        icon: Icons.play_circle_outline,
        iconColor: CustomColors.Blue600,
        iconBg: CustomColors.Blue50,
        title: 'Auto-play Audio',
        subtitle: 'Play pronunciation automatically',
        trailing: Switch.adaptive(
          value: _autoPlay,
          activeColor: CustomColors.Purple600,
          onChanged: (v) => setState(() => _autoPlay = v),
        ),
      ),
      _SettingsTile(
        icon: Icons.speed_outlined,
        iconColor: CustomColors.Purple600,
        iconBg: CustomColors.Purple50,
        title: 'Speech Speed',
        subtitle: _speechSpeed == 0.6
            ? 'Slow'
            : _speechSpeed == 0.9
                ? 'Normal'
                : 'Fast',
        trailing: null,
        customBottom: Padding(
          padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
          child: Row(
            children: [
              const Text('🐢', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Slider(
                  value: _speechSpeed,
                  min: 0.6,
                  max: 1.2,
                  divisions: 2,
                  activeColor: CustomColors.Purple600,
                  onChanged: (v) => setState(() => _speechSpeed = v),
                ),
              ),
              const Text('🚀', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      _SettingsTile(
        icon: Icons.music_note_outlined,
        iconColor: CustomColors.Coral600,
        iconBg: CustomColors.Coral50,
        title: 'Sound Effects',
        subtitle: 'Play sounds on correct/wrong answers',
        trailing: Switch.adaptive(
          value: _soundEffects,
          activeColor: CustomColors.Purple600,
          onChanged: (v) => setState(() => _soundEffects = v),
        ),
      ),
    ];
  }

  // ── Appearance tiles ─────────────────────
  List<Widget> _appearanceTiles() {
    return [
      _SettingsTile(
        icon: Icons.dark_mode_outlined,
        iconColor: const Color(0xFF6B5CE7),
        iconBg: CustomColors.Purple50,
        title: 'Dark Mode',
        subtitle: _darkMode ? 'On' : 'Off',
        trailing: Switch.adaptive(
          value: _darkMode,
          activeColor: CustomColors.Purple600,
          onChanged: (v) => setState(() => _darkMode = v),
        ),
      ),
      _SettingsTile(
        icon: Icons.text_fields_outlined,
        iconColor: CustomColors.Teal600,
        iconBg: CustomColors.Teal50,
        title: 'Text Size',
        subtitle: _textSize == 0.8 ? 'Small' : _textSize == 1.0 ? 'Normal' : 'Large',
        trailing: _PillSelector(
          options: const ['S', 'M', 'L'],
          selectedIndex: [0.8, 1.0, 1.2].indexOf(_textSize),
          onSelected: (i) => setState(() => _textSize = [0.8, 1.0, 1.2][i]),
        ),
      ),
    ];
  }

  // ── Account tiles ─────────────────────────
  List<Widget> _accountTiles(BuildContext context) {
    return [
      _SettingsTile(
        icon: Icons.sync_outlined,
        iconColor: CustomColors.Blue600,
        iconBg: CustomColors.Blue50,
        title: 'Sync Progress',
        subtitle: 'Last synced just now',
        onTap: () {},
      ),
      _SettingsTile(
        icon: Icons.lock_outline,
        iconColor: CustomColors.Purple600,
        iconBg: CustomColors.Purple50,
        title: 'Change Password',
        onTap: () {},
      ),
      _SettingsTile(
        icon: Icons.logout_outlined,
        iconColor: Colors.red,
        iconBg: const Color(0xFFFFF0F0),
        title: 'Sign Out',
        titleColor: Colors.red,
        onTap: () => _showConfirmDialog(
          context,
          title: 'Sign Out?',
          body: 'You will be signed out of your account.',
          confirmLabel: 'Sign Out',
          confirmColor: Colors.red,
          onConfirm: () {},
        ),
      ),
    ];
  }

  // ── About tiles ───────────────────────────
  List<Widget> _aboutTiles(BuildContext context) {
    return [
      _SettingsTile(
        icon: Icons.info_outline,
        iconColor: CustomColors.Blue600,
        iconBg: CustomColors.Blue50,
        title: 'App Version',
        subtitle: '1.0.0 (build 42)',
      ),
      _SettingsTile(
        icon: Icons.description_outlined,
        iconColor: CustomColors.Purple600,
        iconBg: CustomColors.Purple50,
        title: 'Terms of Service',
        onTap: () {},
      ),
      _SettingsTile(
        icon: Icons.privacy_tip_outlined,
        iconColor: CustomColors.Teal600,
        iconBg: CustomColors.Teal50,
        title: 'Privacy Policy',
        onTap: () {},
      ),
      _SettingsTile(
        icon: Icons.star_outline,
        iconColor: CustomColors.Amber400,
        iconBg: const Color(0xFFFFF7E6),
        title: 'Rate the App',
        onTap: () {},
      ),
    ];
  }

  // ── Helpers ──────────────────────────────
  void _showPicker(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(title,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: CustomColors.Purple900)),
            ),
            ...options.map((o) => ListTile(
                  leading: Icon(
                    selected == o ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: selected == o ? CustomColors.Purple600 : Colors.black26,
                  ),
                  title: Text(o, style: TextStyle(fontWeight: selected == o ? FontWeight.w600 : FontWeight.normal)),
                  onTap: () {
                    onSelected(o);
                    Navigator.pop(ctx);
                  },
                )),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String body,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable tile
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final Widget? customBottom;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.customBottom,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                // Icon bubble
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                // Labels
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? const Color(0xFF1A1A2E),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(fontSize: 13, color: Colors.black45),
                        ),
                      ],
                    ],
                  ),
                ),
                // Trailing
                if (trailing != null)
                  trailing!
                else if (onTap != null)
                  const Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 20),
              ],
            ),
          ),
          if (customBottom != null) customBottom!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pill selector widget (e.g. S / M / L or 5m / 10m / 15m)
// ─────────────────────────────────────────────────────────────────────────────
class _PillSelector extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _PillSelector({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: options.asMap().entries.map((entry) {
        final i = entry.key;
        final label = entry.value;
        final selected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(left: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: selected ? CustomColors.Purple600 : CustomColors.Purple50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : CustomColors.Purple600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
