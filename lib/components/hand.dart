import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

import 'package:lama/lama_game.dart';

class Hand extends PositionComponent with HasGameRef<LamaGame> {
  static const SPEED = 0.25;

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    c.drawRect(Rect.fromLTWH(0, 0, width, height), BasicPalette.white.paint);
  }

  @override
  void update(double t) {
    super.update(t);
    angle += SPEED * t;
    angle %= 2 * math.pi;
  }

  @override
  void onMount() {
    width = height = gameRef.squareSize;
    anchor = Anchor.center;
  }
}
