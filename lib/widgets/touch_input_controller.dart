import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';

class TouchInputController extends StatelessWidget {
  final Widget child;
  const TouchInputController({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _TouchInputControllerInner(
          constraints: constraints,
          child: child,
        );
      },
    );
  }
}

class _TouchInputControllerInner extends StatefulWidget {
  const _TouchInputControllerInner({
    required this.child,
    required this.constraints,
  });

  final Widget child;

  final BoxConstraints constraints;

  @override
  State<_TouchInputControllerInner> createState() =>
      _TouchInputControllerInnerState();
}

class _TouchInputControllerInnerState
    extends State<_TouchInputControllerInner> {
  late final playerCubit = context.read<PlayerCubit>();
  late final gameCubit = context.read<GameCubit>();

  Size get size => widget.constraints.biggest;

  bool isDragging = false;

  void handlePanStart(DragStartDetails details) {
    if (!gameCubit.isPlaying) {
      return;
    }

    final offsetToCenter = details.localPosition - size.center(Offset.zero);
    final distanceToCenter = offsetToCenter.distance;

    if (distanceToCenter < size.width * 0.1) {
      return;
    }

    setState(() {
      isDragging = true;
    });
  }

  void handlePanUpdate(DragUpdateDetails details) {
    if (!isDragging) {
      return;
    }

    final x = details.localPosition.dx / 10;
    playerCubit.setMovement(PlayerMovement(xPosition: x));
  }

  void handlePanEnd(DragEndDetails details) {
    setState(() {
      isDragging = false;
    });
  }

  void handlePanCancel() {
    setState(() {
      isDragging = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: handlePanStart,
      onPanUpdate: handlePanUpdate,
      onPanEnd: handlePanEnd,
      onPanCancel: handlePanCancel,
      child: widget.child,
    );
  }
}
