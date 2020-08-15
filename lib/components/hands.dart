import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';

import 'package:lama/lama_game.dart';
import 'package:lama/components/hand.dart';

class Hands extends PositionComponent with HasGameRef<LamaGame> {
  List<int> numbers = [];
  final LamaGame game;
  math.Random rand;

  Hands(this.game) {
    rand = math.Random();
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);
  }

  @override
  void update(double t) {
    super.update(t);
  }

  void drawCard() {
    int number = rand.nextInt(7) + 1;
    Position pos = Position(
      this.numbers.length * Hand.cardSize.width / 2,
      this.game.screenSize.height - Hand.cardSize.height,
    );

    this.game.add(Hand(number, pos));
    this.numbers.add(number);
  }
}
