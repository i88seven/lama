import 'dart:math' as math;
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'package:lama/components/hands.dart';
import 'package:lama/components/other_hands.dart';
import 'package:lama/components/stocks.dart';
import 'package:lama/components/trashes.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/components/back_card.dart';
import 'package:lama/constants/card_state.dart';

class LamaGame extends BaseGame with TapDetector {
  bool isReady = true;
  Hands _hands;
  List<OtherHands> _othersHands;
  Stocks _stocks;
  Trashes _trashes;
  Size screenSize;
  math.Random _rand;
  DatabaseReference _databaseReference;
  DatabaseReference _gameRef;
  String hostName = 'i88seven'; // TODO
  int playerCount = 4; // TODO
  int myOrder;
  int currentOrder;

  LamaGame() {
    _databaseReference = FirebaseDatabase.instance.reference();
    _gameRef = _databaseReference.child(hostName);
    _gameRef.keepSynced(true);
    _rand = math.Random();
    _hands = Hands(this);
    _othersHands = [];
    _trashes = Trashes(this);
    _stocks = Stocks(this);

    _gameRef.onChildChanged.listen(_onChange);
  }

  void initialize() {
    _deal();
    _setCardsAtDatabase();
  }

  void _onChange(Event e) {
    if (e.snapshot.key == 'cards') {
      List<List<dynamic>> playersCards =
          List<List<dynamic>>.from(e.snapshot.value['players']);
      playersCards.asMap().forEach((i, playerCards) {
        if (i == this.myOrder) {
          _hands.initialize(List<int>.from(playerCards));
        } else {
          _othersHands[(i - this.myOrder - 1) % this.playerCount]
              .set(List<int>.from(playerCards));
        }
      });
      _stocks.initialize(List<int>.from(e.snapshot.value['stocks']));
      _trashes.initialize(List<int>.from(e.snapshot.value['trashes']));
      return;
    }
    if (e.snapshot.key == 'current') {
      this.currentOrder = e.snapshot.value;
    }
  }

  void _deal() {
    this.myOrder = _rand.nextInt(this.playerCount);

    List<int> stocks = List<int>.generate(7 * 8, (int index) => index ~/ 8 + 1);
    stocks.shuffle();
    List<List<int>> playersCards = [];
    for (int i = 0; i < this.playerCount; i++) {
      playersCards.add(stocks.sublist(0, 6));
      stocks.removeRange(0, 6);
    }
    List<int> trashes = stocks.sublist(0, 1);
    stocks.removeRange(0, 1);

    playersCards.asMap().forEach((i, playerCards) {
      if (i == this.playerCount - 1) {
        _hands.initialize(playerCards);
      } else {
        OtherHands otherHands = OtherHands(this);
        otherHands.initialize(playerCards, i);
        _othersHands.add(otherHands);
      }
    });
    _stocks.initialize(stocks);
    _trashes.initialize(trashes);

    this.currentOrder = 0;
    _gameRef.child('current').set(this.currentOrder);
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

    if (this.currentOrder != this.myOrder) {
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
            if (_discard(c)) {
              break;
            }
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
    int drawNumber = _stocks.drawCard();
    _hands.drawCard(drawNumber);
    _setCardsAtDatabase();
    _gameRef.child('current').set(this.myOrder + 1);
  }

  bool _discard(FrontCard card) {
    int numberDiff = card.number - _trashes.numbers.last;
    if (numberDiff != 0 && numberDiff != 1 && numberDiff != -6) {
      return false;
    }
    _hands.discard(card);
    _trashes.add(card.number);
    _setCardsAtDatabase();
    _gameRef.child('current').set(this.myOrder + 1);
    return true;
  }

  void _setCardsAtDatabase() {
    List<List<int>> playersCards = [
      _hands.numbers,
      ...(_othersHands.map((otherHands) => otherHands.numbers))
    ];
    _gameRef.child('cards').set({
      'players': [
        ...(playersCards.sublist(this.playerCount - this.myOrder)),
        ...(playersCards.sublist(0, (this.playerCount - this.myOrder)))
      ],
      'stocks': _stocks.numbers,
      'trashes': _trashes.numbers,
    });
  }
}
