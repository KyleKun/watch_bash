import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wearable_rotary/wearable_rotary.dart';

import '../cubit/cubit.dart';

class RotaryInputController extends StatelessWidget {
  final Widget child;
  const RotaryInputController({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return _RotaryInputControllerInner(
      child: child,
    );
  }
}

class _RotaryInputControllerInner extends StatefulWidget {
  const _RotaryInputControllerInner({required this.child});

  final Widget child;

  @override
  State<_RotaryInputControllerInner> createState() =>
      _RotaryInputControllerState();
}

class _RotaryInputControllerState extends State<_RotaryInputControllerInner> {
  late final StreamSubscription<RotaryEvent> rotarySubscription;

  late final playerCubit = context.read<PlayerCubit>();
  late final gameCubit = context.read<GameCubit>();

  @override
  void initState() {
    super.initState();

    rotarySubscription = rotaryEvents.listen((RotaryEvent event) {
      if (!gameCubit.isPlaying) {
        return;
      }

      final double factor;
      if (event.direction == RotaryDirection.clockwise) {
        factor = 1;
      } else {
        factor = -1;
      }

      if (event.magnitude == 136.0) {
        // No idea if this ever happens
        playerCubit.setRotaryImpulse(1.72 * factor * (math.pi / 12));
      } else {
        // Magic numbers everywhere
        final maxMagn = math.max(event.magnitude ?? 10, 5);
        final magn = (math.pi / 10) * (maxMagn / 30);
        playerCubit.setRotaryImpulse(factor * magn);
      }
    });
  }

  @override
  void dispose() {
    rotarySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
