import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart';
import 'package:watch_bash/cubit/cubit.dart';

import 'game.dart';

enum CPUPosition { left, top, right }

class CPU extends BodyComponent<WatchBashArena>
    with FlameBlocListenable<BallCubit, BallState> {
  final Vector2 position;
  final CPUPosition side;
  final Color color;

  ScoreState scoreState = const ScoreState.initial();

  bool moveRight = true;
  bool isCentered = false;

  CPU({
    required this.position,
    required this.side,
    required this.color,
  });

  @override
  void renderPolygon(Canvas canvas, List<Offset> points) {
    super.renderPolygon(canvas, points);
    final paint = Paint()..color = color;
    canvas.drawPath(Path()..addPolygon(points, true), paint);
  }

  @override
  void update(double dt) {
    if (gameRef.gameCubit.isInitial && !isCentered) {
      isCentered = true;
      if (side == CPUPosition.top) {
        moveTowardsX(body.position.x, gameRef.size.x / 2, 0.2);
      } else {
        moveTowardsY(body.position.y, gameRef.size.y / 2, 0.2);
      }
    } else {
      isCentered = false;
    }
    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Listen score state
    await add(
      FlameBlocListener<ScoreCubit, ScoreState>(
        onNewState: (state) => scoreState = state,
      ),
    );
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position
      ..fixedRotation = true
      ..angularDamping = 1.0
      ..linearDamping = 10.0;

    final paddleBody = world.createBody(bodyDef);

    final shape = PolygonShape();

    if (side == CPUPosition.top) {
      shape.setAsBox(
        1.5,
        0.2,
        Vector2(0.0, 0.0),
        0.0,
      );
    } else {
      shape.setAsBox(
        0.2,
        1.5,
        Vector2(0.0, 0.0),
        0.0,
      );
    }

    paddleBody.createFixture(
      FixtureDef(shape)
        ..density = 10000.0
        ..friction = 0.0
        ..restitution = 1.0,
    );

    return paddleBody;
  }

  @override
  void onNewState(BallState state) {
    if (side == CPUPosition.top) {
      if (scoreState.cpuTopScore == 0) return;
      if (state.y < gameRef.size.y / 3 && state.y > 2.945) {
        final newX = respectLimits(state.x);
        moveTowardsX(body.position.x, newX, 0.48);
      }
    } else {
      // Default left
      bool condition = state.x < gameRef.size.x / 3;

      if (side == CPUPosition.right) {
        if (scoreState.cpuRightScore == 0) return;
        condition = state.x > gameRef.size.x / 1.5;
      } else {
        if (scoreState.cpuLeftScore == 0) return;
      }

      if (condition && state.x > 2.945) {
        final newY = respectLimitsY(state.y);
        moveTowardsY(body.position.y, newY, 0.48);
      }
    }
  }

  double respectLimits(double x) {
    return x.clamp(5.5, gameRef.size.x - 5.5);
  }

  double respectLimitsY(double y) {
    return y.clamp(5.5, gameRef.size.y - 5.5);
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

  void moveTowardsY(double currentY, double targetY, double speed) {
    double angle = 0.0;

    double dist = (targetY - currentY).abs();
    if (dist < speed) {
      body.setTransform(Vector2(body.position.x, targetY), angle);
    } else {
      double fraction = speed / dist;
      double newY = currentY + (targetY - currentY) * fraction;
      body.setTransform(Vector2(body.position.x, newY), angle);
    }
  }
}
