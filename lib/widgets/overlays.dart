import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';

class InitialOverlay extends StatefulWidget {
  const InitialOverlay({super.key});

  @override
  State<InitialOverlay> createState() => _InitialOverlayState();
}

class _InitialOverlayState extends State<InitialOverlay> {
  bool showingCredits = false;

  @override
  Widget build(BuildContext context) {
    final mainMenu = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Column(
          children: [
            const Text(
              'Watch Bash',
              style: TextStyle(
                color: Colors.white60,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            BlocBuilder<StatsCubit, StatsState>(builder: (context, state) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Played: ${state.matchesPlayed}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Won: ${state.matchesWon}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Tap to Play',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Hold for Credits',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 8,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (showingCredits) {
          setState(() {
            showingCredits = false;
          });
          return;
        }
        final gameCubit = context.read<GameCubit>();
        if (gameCubit.isPlaying) {
          return;
        }
        gameCubit.startGame();
      },
      onLongPress: () {
        setState(() {
          showingCredits = !showingCredits;
        });
      },
      child: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Stack(
            fit: StackFit.expand,
            children: [
              !showingCredits ? mainMenu : const SizedBox.shrink(),
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: showingCredits ? 1 : 0),
                duration: const Duration(milliseconds: 250),
                builder: (context, value, _) {
                  return CreditsOverlay(
                    showing: showingCredits,
                    progress: value,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreditsOverlay extends StatelessWidget {
  const CreditsOverlay({
    super.key,
    required this.progress,
    required this.showing,
  });

  final double progress;
  final bool showing;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(
        sigmaX: 2 * progress,
        sigmaY: 4 * progress,
      ),
      child: Opacity(
        opacity: progress,
        child: !showing
            ? const SizedBox.shrink()
            : Column(
                children: [
                  const Spacer(),
                  const Text(
                    'Made by',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Caio Pedroso',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'kylekun.com',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton.icon(
                    label: const Text(
                      'View licenses',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      // Show about dialog
                      showLicensePage(context: context);
                    },
                    icon: const Icon(
                      Icons.article_outlined,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Powered by Flutter & Flame\nCopyright © Caio Pedroso, 2023\nversion 1.0',
                    style: TextStyle(
                      fontSize: 7,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

class GameWonOverlay extends StatelessWidget {
  const GameWonOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        final gameCubit = context.read<GameCubit>();
        final statsCubit = context.read<StatsCubit>();
        if (gameCubit.state != GameState.won) {
          return;
        }
        statsCubit.won();
        gameCubit.reset();
      },
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'You won!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tap to continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        final gameCubit = context.read<GameCubit>();
        final statsCubit = context.read<StatsCubit>();
        if (gameCubit.state != GameState.gameOver) {
          return;
        }
        statsCubit.lost();
        gameCubit.reset();
      },
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Game over',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Tap to continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
