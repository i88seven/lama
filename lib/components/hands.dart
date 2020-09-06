import 'dart:math' as math;

import 'package:firebase_database/firebase_database.dart';
import 'package:flame/position.dart';

import 'package:lama/lama_game.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/constants/card_state.dart';

class Hands {
  List<int> numbers = [];
  final LamaGame game;
  final DatabaseReference gameRef;
  math.Random rand;

  Hands(this.game, this.gameRef) {
    rand = math.Random();
  }

  void drawCard() {
    int number = rand.nextInt(7) + 1;
    Position pos = Position(
      this.numbers.length * FrontCard.cardSize.width / 2,
      this.game.screenSize.height - FrontCard.cardSize.height,
    );

    this.game.add(FrontCard(number, CardState.Hand)
      ..x = pos.x
      ..y = pos.y);
    this.numbers.add(number);
    gameRef.set({
      'cards': {
        'players': [
          this.numbers,
        ],
      }
    });
  }

  void discard(FrontCard card) {
    print(card.number);
    this.game.add(FrontCard(card.number, CardState.Trash)
      ..x = 300 / 2
      ..y = 500 / 2);
    this.game.markToRemove(card);
  }
}
