import 'dart:math' as math;
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:lama/components/hands.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/constants/card_state.dart';

class LamaGame extends BaseGame with TapDetector {
  bool running = true;
  Hands hands;
  Size screenSize;
  math.Random rand;
  DatabaseReference _databaseReference;
  DatabaseReference _gameRef;
  String hostName = 'i88seven'; // TODO

  LamaGame() {
    _databaseReference = FirebaseDatabase.instance.reference();
    _gameRef = _databaseReference.child(hostName);
    _gameRef.keepSynced(true);
    rand = math.Random();
    hands = Hands(this, _gameRef);
    int number = rand.nextInt(7) + 1;
    add(FrontCard(number, CardState.Trash)
      ..x = 300 / 2
      ..y = 500 / 2);
  }

  @override
  void resize(Size size) {
    super.resize(size);
    this.screenSize = size;
  }

  @override
  void onTapUp(details) {
    final touchArea = Rect.fromCenter(
      center: details.localPosition,
      width: 2,
      height: 2,
    );

    bool handled = false;
    for (final c in components) {
      if (c is FrontCard) {
        if (c.toRect().overlaps(touchArea)) {
          if (c.state == CardState.Hand) {
            handled = true;
            hands.discard(c);
            break;
          }
        }
      }
    }

    if (!handled) {
      hands.drawCard();
    }
  }
}
