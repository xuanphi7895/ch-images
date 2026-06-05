import 'package:flutter/material.dart';
import 'package:images/src//modules/dashboard/screens/dashboard_screen.dart';
import 'package:images/src/app/english_app.dart';
import 'package:images/src/modules/dictionary/presentation/screens/dictionary_screen.dart';
import 'package:images/src/modules/dictionary/presentation/screens/word_lookup_screen.dart';
import 'package:images/src/modules/features/english_card/presentation/pages/learn_english_app.dart';
import 'package:images/src/modules/features/pdf/screens/pdf_to_tts_screen.dart';
import 'package:images/src/modules/features/quick_practice/presentation/screen/quick_pratice_sreen.dart';
import 'package:images/src/modules/login/screens/login_screen.dart';
import 'package:images/src/widgets/custom_colors.dart';
import 'package:images/src/modules/home/presentation/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gift Wallet',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: CustomColors.primary,
          secondary: CustomColors.secondary,
        ),
      ),
      initialRoute: '/home',
      routes: {
        '/word': (context) => const WordLookupScreen(),
        '/dictionary': (context) => const DictionaryScreen(),
        // '/home': (context) => const EnglishApp(),
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/learn': (context) => const LearnEnglishApp(),
        '/quick': (context) => const QuickPracticeScreen(),
        // '/pdf': (context) => const PdfToTtsPage(),
      },
    );
  }
}

// 1. For apk (Android) you need to run the command :
// flutter build apk --release 
// flutter build appbundle
    // If you want to split the apks per abi (Split Apk) then run
    // flutter build apk --target-platform android-arm, android-arm64, android-x64 --split-per-abi
// flutter build appbundle
// D:\flutter\images\build\app\outputs\bundle\release
// 2. For ipa (iOS) you need to run the command:
// flutter build ios --release


