import 'package:flame/position.dart';

import 'package:lama/lama_game.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/constants/card_state.dart';

class Hands {
  List<int> numbers = [];
  List<FrontCard> _cardObjects = [];
  final LamaGame game;

  Hands(this.game);

  void initialize(List<int> numbers) {
    this.numbers = numbers;
    this.numbers.sort();
    _render();
  }

  void drawCard(number) {
    this.numbers.add(number);
    this.numbers.sort();
    _render();
  }

  void discard(FrontCard card) {
    this.numbers.remove(card.number);
    _render();
  }

  void _render() {
    _cardObjects.forEach((cardObject) {
      this.game.markToRemove(cardObject);
    });
    _cardObjects = [];
    this.numbers.asMap().forEach((index, number) {
      Position pos = Position(
        index * FrontCard.cardSize.width / 2,
        this.game.screenSize.height - FrontCard.cardSize.height,
      );
      FrontCard cardObject = FrontCard(number, CardState.Hand);
      this.game.add(cardObject
        ..x = pos.x
        ..y = pos.y);
      _cardObjects.add(cardObject);
    });
  }
}
