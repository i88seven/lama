import 'package:lama/lama_game.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/constants/card_state.dart';

class Stocks {
  List<int> numbers = [];
  final LamaGame game;

  Stocks(this.game);

  void initialize(numbers) {
    this.numbers = numbers;
    this.game.add(FrontCard(1, CardState.Trash)
      ..x = 200 / 2
      ..y = 500 / 2);
  }
}
