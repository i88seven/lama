import 'package:lama/lama_game.dart';
import 'package:lama/components/back_card.dart';
import 'package:lama/constants/card_state.dart';

class Stocks {
  List<int> numbers = [0];
  final LamaGame _game;

  Stocks(this._game);

  void initialize(numbers) {
    this.numbers = numbers;
    _game.add(BackCard(CardState.Stock)
      ..x = 200 / 2
      ..y = 500 / 2);
  }

  int drawCard() {
    int drawNumber = this.numbers[0];
    this.numbers.removeAt(0);
    return drawNumber;
  }
}
