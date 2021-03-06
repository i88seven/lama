import 'package:lama/lama_game.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/constants/card_state.dart';

class Trashes {
  List<int> numbers = [];
  final LamaGame _game;

  Trashes(this._game);

  void initialize(List<int> numbers) {
    this.numbers = numbers;
    _render(numbers.last);
  }

  void add(number) {
    this.numbers.add(number);
    _render(number);
  }

  void _render(number) {
    _game.add(FrontCard(number, CardState.Trash, false)
      ..x = 210
      ..y = 250);
  }
}
