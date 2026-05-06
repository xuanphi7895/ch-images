import 'package:flutter/material.dart';
import 'package:images/widgets/image_section.dart';
import './widgets/title_section.dart';
import './widgets/button_section.dart';
import './widgets/text_section.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String appTitle = 'Images Demo';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(title: const Text(appTitle)),
        body: const SingleChildScrollView(
          child: Column(
            children: [
              ImageSection(image: 'wwwroot/images/lake.jpg'),
              TitleSection(name: 'Phi', location: 'Da Nang City'),
              ButtonSection(),
              TextSection(description: 'Test flutter demo'),
            ],
          ),
        ),
      ),
    );
  }
}
