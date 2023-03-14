import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/material.dart';

import '../cubit/cubit.dart';
import 'game.dart';

class ScoreText extends Component
    with
        FlameBlocListenable<ScoreCubit, ScoreState>,
        HasGameRef<WatchBashArena> {
  ScoreText({required this.position, required this.owner});

  Vector2 position;
  ScoreOwner owner;
  late int score;
  late final TextComponent textComp;

  final textPaint = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 1.0,
    ),
  );

  @override
  Future<void> onLoad() async {
    await add(
      textComp = TextComponent(
        text: '',
        textRenderer: textPaint,
      )
        ..anchor = Anchor.center
        ..x = position.x
        ..y = position.y,
    );
  }

  @override
  void onNewState(ScoreState state) {
    if (owner == ScoreOwner.cpuRight) {
      textComp.text = scoreText(state.cpuRightScore);
    } else if (owner == ScoreOwner.cpuTop) {
      textComp.text = scoreText(state.cpuTopScore);
    } else if (owner == ScoreOwner.cpuLeft) {
      textComp.text = scoreText(state.cpuLeftScore);
    } else if (owner == ScoreOwner.player) {
      textComp.text = scoreText(state.playerScore);
    }
  }

  String scoreText(int score) {
    return score < 0 ? '' : score.toString();
  }
}
