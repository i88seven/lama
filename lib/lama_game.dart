import 'dart:ui';

import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:lama/components/hands.dart';
import 'package:lama/components/hand.dart';

class LamaGame extends BaseGame with TapDetector {
  bool running = true;
  Hands hands;
  Size screenSize;

  LamaGame() {
    hands = Hands(this);
  }

  @override
  void resize(Size size) {
    super.resize(size);
    this.screenSize = size;
  }

  @override
  void onTapUp(details) {
    final touchArea = Rect.fromCenter(
      center: details.localPosition,
      width: 2,
      height: 2,
    );

    bool handled = false;
    for (final c in components) {
      if (c is Hand) {
        if (c.toRect().overlaps(touchArea)) {
          handled = true;
          markToRemove(c);
          break;
        }
      }
    }

    if (!handled) {
      hands.drawCard();
    }
  }
}
