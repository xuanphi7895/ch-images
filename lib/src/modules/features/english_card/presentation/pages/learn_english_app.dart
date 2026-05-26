import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/core/app_theme.dart';

import 'package:images/src/modules/features/english_card/data/english_card_repository.dart';
import 'package:images/src/modules/features/english_card/presentation/bloc/english_card_bloc.dart';
import 'package:images/src/modules/features/english_card/presentation/bloc/english_card_event.dart';
import 'package:images/src/modules/features/english_card/presentation/pages/english_cards_page.dart';

class LearnEnglishApp extends StatelessWidget {
  const LearnEnglishApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Cards',
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) =>
            EnglishCardBloc(repository: EnglishCardRepository())
              ..add(const EnglishCardsLoadRequested()),
        child: const EnglishCardsPage(),
      ),
    );
  }
}
