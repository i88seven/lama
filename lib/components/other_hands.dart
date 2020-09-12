import 'package:flame/position.dart';

import 'package:lama/lama_game.dart';
import 'package:lama/components/back_card.dart';
import 'package:lama/constants/card_state.dart';

class OtherHands {
  List<int> numbers = [];
  final LamaGame game;
  int order; // 自分から見て次の人が "0"

  OtherHands(this.game);

  void initialize(List<int> numbers, int order) {
    numbers.sort();
    this.numbers = numbers;
    this.order = order;
    _render();
  }

  void set(List<int> numbers) {
    numbers.sort();
    this.numbers = numbers;
    _render();
  }

  void _render() {
    for (int i = 0; i < numbers.length; i++) {
      Position pos = Position(
        this.game.screenSize.width / (this.game.playerCount - 1) * this.order +
            i * BackCard.cardSize.width / 4,
        0,
      );
      this.game.add(BackCard(CardState.Other)
        ..x = pos.x
        ..y = pos.y);
    }
  }
}
