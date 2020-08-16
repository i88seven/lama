import 'dart:math' as math;

import 'package:flame/position.dart';

import 'package:lama/lama_game.dart';
import 'package:lama/components/front_card.dart';

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
      this.numbers.length * FrontCard.cardSize.width / 2,
      this.game.screenSize.height - FrontCard.cardSize.height,
    );

    this.game.add(FrontCard(number)
      ..x = pos.x
      ..y = pos.y);
    this.numbers.add(number);
  }

  void discard(FrontCard card) {
    print(card.number);
    this.game.add(FrontCard(card.number)
      ..x = 300 / 2
      ..y = 500 / 2);
    this.game.markToRemove(card);
  }
}
