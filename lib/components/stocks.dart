import 'package:lama/lama_game.dart';
import 'package:lama/components/back_card.dart';
import 'package:lama/constants/card_state.dart';

class Stocks {
  List<int> numbers = [0];
  BackCard _cardObject;
  final LamaGame _game;

  Stocks(this._game);

  void initialize(List<int> numbers) {
    if (_cardObject != null) {
      _game.markToRemove(_cardObject);
    }
    this.numbers = numbers;
    if (numbers.length == 0) {
      return;
    }
    _cardObject = BackCard(CardState.Stock)
      ..x = 200 / 2
      ..y = 500 / 2;
    _game.add(_cardObject);
  }

  int drawCard() {
    int drawNumber = this.numbers[0];
    this.numbers.removeAt(0);
    return drawNumber;
  }
}
