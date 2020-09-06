import 'package:flame/position.dart';

import 'package:lama/lama_game.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/constants/card_state.dart';

class Hands {
  List<int> numbers = [];
  final LamaGame game;

  Hands(this.game);

  void initialize(List<int> numbers) {
    numbers.forEach((number) => drawCard(number));
  }

  void drawCard(number) {
    Position pos = Position(
      this.numbers.length * FrontCard.cardSize.width / 2,
      this.game.screenSize.height - FrontCard.cardSize.height,
    );
    this.game.add(FrontCard(number, CardState.Hand)
      ..x = pos.x
      ..y = pos.y);
    this.numbers.add(number);
  }

  void discard(FrontCard card) {
    this.game.markToRemove(card);
    this.numbers.remove(card.number);
  }
}
