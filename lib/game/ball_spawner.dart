import 'dart:math';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'game.dart';

class BallSpawner extends BodyComponent<WatchBashArena> {
  BallSpawner({required this.position});

  final Vector2 position;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: position,
    );
    const numPieces = 12;
    const radius = 0.45;
    final body = world.createBody(bodyDef);

    for (var i = 0; i < numPieces; i++) {
      final xPos = radius * cos(2 * pi * (i / numPieces));
      final yPos = radius * sin(2 * pi * (i / numPieces));

      final shape = CircleShape()
        ..radius = 0.052
        ..position.setValues(xPos, yPos);

      final fixtureDef = FixtureDef(
        shape,
        density: 50.0,
        friction: .1,
        restitution: .9,
      );

      body.createFixture(fixtureDef);
    }

    final groundBody = world.createBody(BodyDef());

    final revoluteJointDef = RevoluteJointDef()
      ..initialize(body, groundBody, body.position)
      ..motorSpeed = pi
      ..maxMotorTorque = 1000000.0
      ..enableMotor = false;

    world.createJoint(RevoluteJoint(revoluteJointDef));
    return body;
  }
}
