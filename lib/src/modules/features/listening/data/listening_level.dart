// 1. Data Model representing individual Level definitions
import 'package:flutter/material.dart';

class ListeningLevel {
  final int number;
  final String title;
  final double progress; // Value between 0.0 and 1.0
  final Color baseColor;
  final String description;

  ListeningLevel({
    required this.number,
    required this.title,
    required this.progress,
    required this.baseColor,
    required this.description,
  });
}
