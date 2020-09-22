import 'package:flame/position.dart';

import 'package:lama/lama_game.dart';
import 'package:lama/components/back_card.dart';
import 'package:lama/constants/card_state.dart';

class OtherHands {
  List<int> numbers = [];
  List<BackCard> _cardObjects = [];
  final LamaGame _game;
  int _order; // 自分から見て次の人が "0"

  OtherHands(this._game, this._order);

  void initialize(List<int> numbers) {
    numbers.sort();
    this.numbers = numbers;
    _render();
  }

  void _render() {
    _cardObjects.forEach((cardObject) {
      _game.markToRemove(cardObject);
    });
    _cardObjects = [];
    for (int i = 0; i < numbers.length; i++) {
      Position pos = Position(
        _game.screenSize.width / (_game.playerCount - 1) * _order +
            i * BackCard.cardSize.width / 4,
        80,
      );
      BackCard cardObject = BackCard(CardState.Other);
      _game.add(cardObject
        ..x = pos.x
        ..y = pos.y);
      _cardObjects.add(cardObject);
    }
  }

  int get points {
    if (this.numbers.length == 0) {
      return 0;
    }
    return this.numbers.toSet().toList().fold(0, (acc, number) {
      if (number == 7) {
        return acc + 10;
      }
      return acc + number;
    });
  }
}
