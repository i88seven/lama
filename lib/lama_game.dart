import 'dart:math' as math;
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:lama/components/hands.dart';
import 'package:lama/components/stocks.dart';
import 'package:lama/components/trashes.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/components/back_card.dart';
import 'package:lama/constants/card_state.dart';

class LamaGame extends BaseGame with TapDetector {
  bool isReady = true;
  Hands hands;
  Stocks stocks;
  Trashes trashes;
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
    hands = Hands(this);
    trashes = Trashes(this);
    stocks = Stocks(this);
  }

  void initialize() {
    _deal();

    _gameRef.child('cards').set({
      'players': this.hands.numbers,
      'stocks': this.stocks.numbers,
      'trashes': this.trashes.numbers,
    });
  }

  void _deal() {
    List<int> stocks = List<int>.generate(7 * 8, (int index) => index ~/ 8 + 1);
    stocks.shuffle();
    List<int> hands = stocks.sublist(0, 6);
    stocks.removeRange(0, 6);
    // player 分繰り返す
    List<int> trashes = stocks.sublist(0, 1);
    stocks.removeRange(0, 1);

    this.hands.initialize(hands);
    this.stocks.initialize(stocks);
    this.trashes.initialize(trashes);
  }

  @override
  void resize(Size size) {
    super.resize(size);
    this.screenSize = size;
  }

  @override
  void onTapUp(details) {
    if (isReady) {
      // TODO ホストかによって処理を分ける
      isReady = false;
      this.initialize();
      return;
    }
    final touchArea = Rect.fromCenter(
      center: details.localPosition,
      width: 2,
      height: 2,
    );

    for (final c in components) {
      if (c is FrontCard) {
        if (c.toRect().overlaps(touchArea)) {
          if (c.state == CardState.Hand) {
            this.discard(c);
            break;
          }
        }
      }

      if (c is BackCard) {
        if (c.toRect().overlaps(touchArea)) {
          if (c.state == CardState.Stock) {
            this.drawCard();
            break;
          }
        }
      }
    }
  }

  void drawCard() {
    int drawNumber = this.stocks.drawCard();
    this.hands.drawCard(drawNumber);
    _gameRef.child('cards').set({
      'players': this.hands.numbers,
      'stocks': this.stocks.numbers,
      'trashes': this.trashes.numbers,
    });
  }

  void discard(FrontCard card) {
    this.hands.discard(card);
    this.trashes.add(card.number);
    _gameRef.child('cards').set({
      'players': this.hands.numbers,
      'stocks': this.stocks.numbers,
      'trashes': this.trashes.numbers,
    });
  }
}
