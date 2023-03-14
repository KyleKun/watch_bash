import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../cubit/cubit.dart';

import 'game.dart';

class Walls extends BodyComponent<WatchBashArena>
    with FlameBlocListenable<ScoreCubit, ScoreState>, ContactCallbacks {
  late Vector2 wallsSize;

  // Controlls the general size of the square composed by walls
  // The greater the number, the smaller the square
  final double sizeSubtraction = 2.5;

  // Distance of the walls from the screen borders
  final double delimiter = 2.945;

  ScoreState scoreState = const ScoreState.initial();

  @override
  Future<void> onLoad() {
    wallsSize = gameRef.size;
    return super.onLoad();
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ball) {
      // Determine which wall was hit
      final ballPosition = contact.bodyB.position;

      if (ballPosition.y <= delimiter) {
        computeScore(scoreState.cpuTopScore, ScoreOwner.cpuTop, 2, other);
      } else if (ballPosition.y >= wallsSize.y - delimiter) {
        computeScore(scoreState.playerScore, ScoreOwner.player, 0, other);
      } else if (ballPosition.x <= delimiter) {
        computeScore(scoreState.cpuLeftScore, ScoreOwner.cpuLeft, 1, other);
      } else if (ballPosition.x >= wallsSize.x - delimiter) {
        computeScore(scoreState.cpuRightScore, ScoreOwner.cpuRight, 3, other);
      }
    }
  }

  void computeScore(
    int score,
    ScoreOwner scoreOwner,
    int fixtureId,
    Ball ball,
  ) {
    if (score == 0) {
      return;
    }
    if (score == 1) {
      Future.delayed(const Duration(milliseconds: 350), () {
        body.fixtures[fixtureId].setSensor(false);
      });

      if (scoreOwner == ScoreOwner.player &&
          gameRef.gameCubit.state != GameState.won) {
        gameRef.gameCubit.gameOver();
      }
    }
    removeBall(ball);

    gameRef.scoreCubit.decreaseScore(scoreOwner, gameRef.buildContext!);
  }

  void removeBall(Ball ball) {
    Future.delayed(const Duration(seconds: 1), () {
      ball.removeFromParent();
    });
  }

  @override
  void onNewState(ScoreState state) {
    if (state == const ScoreState.invisible()) {
      for (var fixture in body.fixtures) {
        fixture.setSensor(true);
      }
    }

    scoreState = state;
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef()
      ..position = Vector2(0, 0)
      ..type = BodyType.static;

    final wallsBody = world.createBody(bodyDef);

    final vertices = <Vector2>[
      wallsSize - Vector2(sizeSubtraction, sizeSubtraction),
      Vector2(sizeSubtraction, wallsSize.y - sizeSubtraction),
      Vector2(sizeSubtraction, sizeSubtraction),
      Vector2(wallsSize.x - sizeSubtraction, sizeSubtraction),
    ];

    final chain = ChainShape()..createLoop(vertices);

    for (var index = 0; index < chain.childCount; index++) {
      wallsBody.createFixture(
        FixtureDef(chain.childEdge(index))
          ..userData = this
          ..density = 2000.0
          ..friction = 0.0
          ..isSensor = true
          ..restitution = 0.4,
      );
    }

    return wallsBody;
  }
}
