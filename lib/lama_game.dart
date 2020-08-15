import 'dart:ui';

import 'package:flame/gestures.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:lama/components/hand.dart';

class LamaGame extends BaseGame with TapDetector {
  final double squareSize = 128;
  bool running = true;

  LamaGame() {
    add(Hand()
      ..x = 100
      ..y = 100);
  }

  @override
  void onTapUp(details) {
    final touchArea = Rect.fromCenter(
      center: details.localPosition,
      width: 20,
      height: 20,
    );

    bool handled = false;
    components.forEach((c) {
      if (c is PositionComponent && c.toRect().overlaps(touchArea)) {
        handled = true;
        markToRemove(c);
      }
    });

    if (!handled) {
      addLater(Hand()
        ..x = touchArea.left
        ..y = touchArea.top);
    }
  }
}
