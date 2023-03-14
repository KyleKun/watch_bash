import 'package:flame/timer.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;

import '../cubit/cubit.dart';
import 'game.dart';

class Ball extends BodyComponent<WatchBashArena>
    with FlameBlocListenable<BallCubit, BallState> {
  final Vector2 position;
  final double radius;

  late Timer interval;
  late Stopwatch stopwatch;

  Ball({required this.position, required this.radius});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    stopwatch = Stopwatch()..start();
    interval = Timer(0.01, repeat: true, onTick: () {
      if (stopwatch.elapsedMilliseconds > 1000) {
        bloc.setPosition(
          body.position.x,
          body.position.y,
        );
      }
    });
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef()
      ..userData = this
      ..type = BodyType.dynamic
      ..position = position;

    final ball = world.createBody(bodyDef);
    final shape = CircleShape()..radius = radius;
    final fixtureDef = FixtureDef(shape)
      ..restitution = 1.0
      ..density = 1.0;
    ball.createFixture(fixtureDef);

    return ball;
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
  }
}
