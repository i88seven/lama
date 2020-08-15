import 'dart:ui';

import 'package:flame/gestures.dart';
import 'package:flame/components/component.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:lama/components/hands.dart';

class LamaGame extends BaseGame with TapDetector {
  final double squareSize = 128;
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
    hands.drawCard();
  }
}
