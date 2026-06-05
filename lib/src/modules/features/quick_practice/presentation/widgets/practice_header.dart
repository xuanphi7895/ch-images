// ─── Shared widgets ────────────────────────────────

import 'package:flutter/material.dart';

class PracticeHeader extends StatelessWidget {
  final String title;
  final double progress;
  final String trailing;
  final VoidCallback onClose;

  const PracticeHeader({
    required this.title,
    required this.progress,
    required this.trailing,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 28,
      ),
      color: Purple800,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Purple200, fontSize: 13),
              ),
              Row(
                children: [
                  Text(
                    trailing,
                    style: const TextStyle(color: Amber400, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: onClose,
                    child: const Icon(Icons.close, color: Purple200, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(Purple200),
            ),
          ),
        ],
      ),
    );
  }
}

const Purple900 = Color(0xFF26215C);
const Purple800 = Color(0xFF3C3489);
const Purple600 = Color(0xFF534AB7);
const Purple200 = Color(0xFFAFA9EC);
const Purple50 = Color(0xFFEEEDFE);
const Teal600 = Color(0xFF0F6E56);
const Teal50 = Color(0xFFE1F5EE);
const Blue600 = Color(0xFF185FA5);
const Blue200 = Color(0xFFB5D4F4);
const Blue50 = Color(0xFFE6F1FB);
const Coral600 = Color(0xFF993C1D);
const Coral50 = Color(0xFFFAECE7);
const Amber400 = Color(0xFFEF9F27);
