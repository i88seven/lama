import 'package:flame/position.dart';

import 'package:lama/lama_game.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/constants/card_state.dart';

class Hands {
  List<int> numbers = [];
  List<FrontCard> _cardObjects = [];
  bool _isActive = false;
  final LamaGame _game;

  Hands(this._game);

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

  void setActive(bool isActive) {
    _isActive = isActive;
    _render();
  }

  void _render() {
    _cardObjects.forEach((cardObject) {
      _game.markToRemove(cardObject);
    });
    _cardObjects = [];
    double cardPadding = FrontCard.cardSize.width / 2;
    if (_game.screenSize.width <
        (FrontCard.cardSize.width) / 2 * numbers.length) {
      cardPadding = _game.screenSize.width / numbers.length;
    }
    this.numbers.asMap().forEach((index, number) {
      Position pos = Position(
        index * cardPadding,
        _game.screenSize.height - FrontCard.cardSize.height - 42,
      );
      int numberDiff = number - _game.trashNumber;
      bool isActiveCard =
          _isActive && (numberDiff == 0 || numberDiff == 1 || numberDiff == -6);
      FrontCard cardObject = FrontCard(number, CardState.Hand, isActiveCard);
      _game.add(cardObject
        ..width = index < this.numbers.length - 1
            ? FrontCard.cardSize.width / 2
            : FrontCard.cardSize.width
        ..height = FrontCard.cardSize.height
        ..x = pos.x
        ..y = pos.y);
      _cardObjects.add(cardObject);
    });
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
