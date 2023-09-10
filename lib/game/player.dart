import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../cubit/cubit.dart';
import 'game.dart';

class Player extends BodyComponent<WatchBashArena>
    with FlameBlocListenable<PlayerCubit, PlayerState> {
  bool isCentered = false;

  @override
  Body createBody() {
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = Vector2(
        gameRef.size.x / 2.0,
        gameRef.size.y - 2.85,
      )
      ..fixedRotation = true
      ..angularDamping = 1.0
      ..linearDamping = 10.0;

    final paddleBody = world.createBody(bodyDef);

    final shape = PolygonShape()
      ..setAsBox(
        2.0,
        0.2,
        Vector2(0.0, 0.0),
        0.0,
      );

    paddleBody.createFixture(
      FixtureDef(shape)
        ..density = 10000.0
        ..friction = 0.0
        ..restitution = 1.0,
    );

    return paddleBody;
  }

  double respectLimits(double x) {
    return x.clamp(5.5, gameRef.size.x - 5.5);
  }

  void moveTowardsX(double currentX, double targetX, double speed) {
    double angle = 0.0;

    double dist = (targetX - currentX).abs();
    if (dist < speed) {
      body.setTransform(Vector2(targetX, body.position.y), angle);
    } else {
      double fraction = speed / dist;
      double newX = currentX + (targetX - currentX) * fraction;
      body.setTransform(Vector2(newX, body.position.y), angle);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameRef.gameCubit.isInitial && !isCentered) {
      isCentered = true;

      moveTowardsX(body.position.x, gameRef.size.x / 2, 0.2);
    } else {
      isCentered = false;
    }
  }

  @override
  void onNewState(PlayerState state) {
    if (gameRef.scoreCubit.state.playerScore == 0) return;
    final newX = respectLimits(state.movement.xPosition);

    if (state.movement.isTouch) {
      moveTowardsX(body.position.x, newX, 0.44);
    } else {
      body.setTransform(Vector2(newX, body.position.y), angle);
    }
  }
}
