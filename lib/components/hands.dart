import 'dart:math' as math;

import 'package:flame/position.dart';

import 'package:lama/lama_game.dart';
import 'package:lama/components/hand.dart';

class Hands {
  List<int> numbers = [];
  final LamaGame game;
  math.Random rand;

  Hands(this.game) {
    rand = math.Random();
  }

  void drawCard() {
    int number = rand.nextInt(7) + 1;
    Position pos = Position(
      this.numbers.length * Hand.cardSize.width / 2,
      this.game.screenSize.height - Hand.cardSize.height,
    );

    this.game.add(Hand(number)
      ..x = pos.x
      ..y = pos.y);
    this.numbers.add(number);
  }
}
