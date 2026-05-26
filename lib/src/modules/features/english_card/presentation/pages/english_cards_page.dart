import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/english_card_bloc.dart';
import '../bloc/english_card_event.dart';
import '../bloc/english_card_state.dart';
import '../widgets/english_study_card.dart';

class EnglishCardsPage extends StatelessWidget {
  const EnglishCardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('English Cards'),
        actions: [
          IconButton(
            tooltip: 'Reload',
            onPressed: () => context
                .read<EnglishCardBloc>()
                .add(const EnglishCardsLoadRequested()),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<EnglishCardBloc, EnglishCardState>(
        builder: (context, state) {
          if (state is EnglishCardInitial) {
            return const _Message('Loading cards…');
          }
          if (state is EnglishCardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EnglishCardError) {
            return _Message(state.message);
          }
          if (state is EnglishCardsLoaded) {
            return _LoadedView(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.state});
  final EnglishCardsLoaded state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<EnglishCardBloc>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Card ${state.currentIndex + 1} of ${state.cards.length}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: EnglishStudyCard(
              card: state.current,
              showBack: state.showBack,
              onFlip: () => bloc.add(const EnglishCardFlipToggled()),
              onFavorite: () => bloc.add(const EnglishCardFavoriteToggled()),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton.filledTonal(
                tooltip: 'Previous',
                onPressed: () => bloc.add(const EnglishCardPreviousPressed()),
                icon: const Icon(Icons.chevron_left),
              ),
              FilledButton.icon(
                onPressed: () => bloc.add(const EnglishCardFlipToggled()),
                icon: Icon(state.showBack ? Icons.flip : Icons.flip_outlined),
                label: Text(state.showBack ? 'Show word' : 'Show meaning'),
              ),
              IconButton.filledTonal(
                tooltip: 'Next',
                onPressed: () => bloc.add(const EnglishCardNextPressed()),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(text));
  }
}
