import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/services/voice/text_to_speech_service.dart';
import 'home_destination.dart';
import 'home_view_model.dart';
import 'widgets/buddy_greeting.dart';
import 'widgets/destination_grid.dart';
import 'widgets/explorer_log.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.progressRepository,
    required this.textToSpeech,
  });

  final ProgressRepository progressRepository;
  final TextToSpeechService textToSpeech;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeViewModel _viewModel = HomeViewModel(
    progressRepository: widget.progressRepository,
    textToSpeech: widget.textToSpeech,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_viewModel.load());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  final progress = _viewModel.progress;
                  return Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      _Header(
                        onGrownUps: () =>
                            Navigator.of(context).pushNamed(Routes.parentZone),
                      ),
                      const SizedBox(height: 20),
                      BuddyGreeting(
                        text: HomeViewModel.greeting,
                        onSpeak: _viewModel.canSpeak
                            ? () => unawaited(_viewModel.speakGreeting())
                            : null,
                      ),
                      if (progress != null) ...[
                        const SizedBox(height: 24),
                        ExplorerLog(
                          missionsSolved: progress.completedMissionIds.length,
                          storiesFinished: progress.completedStoryIds.length,
                        ),
                      ],
                      const SizedBox(height: 28),
                      Semantics(
                        header: true,
                        child: Text(
                          'Pick an adventure',
                          style: textTheme.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 14),
                      DestinationGrid(
                        destinations: HomeDestination.values,
                        onSelected: (destination) =>
                            Navigator.of(context).pushNamed(destination.route),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onGrownUps});

  final VoidCallback onGrownUps;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Curious Buddy',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        OutlinedButton.icon(
          onPressed: onGrownUps,
          icon: const Icon(Icons.lock_rounded, size: 20),
          label: const Text('Grown-ups'),
        ),
      ],
    );
  }
}
