// lib/features/profile/profile_screen.dart
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.flag),
            title: Text('Daily goal: 10 min'),
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Reminders'),
          ),
          ListTile(leading: Icon(Icons.dark_mode), title: Text('Dark mode')),
        ],
      ),
    );
  }
}
