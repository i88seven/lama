import 'package:lama/lama_game.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/constants/card_state.dart';

class Trashes {
  List<int> numbers = [];
  final LamaGame game;

  Trashes(this.game);

  void initialize(List<int> numbers) {
    numbers.forEach((number) => this.add(number));
  }

  void add(number) {
    this.numbers.add(number);
    this.game.add(FrontCard(number, CardState.Trash)
      ..x = 400 / 2
      ..y = 500 / 2);
  }
}
