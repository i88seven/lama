import 'dart:math' as math;
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'package:lama/components/member.dart';
import 'package:lama/components/game_player.dart';
import 'package:lama/components/hands.dart';
import 'package:lama/components/other_hands.dart';
import 'package:lama/components/stocks.dart';
import 'package:lama/components/trashes.dart';
import 'package:lama/components/front_card.dart';
import 'package:lama/components/back_card.dart';
import 'package:lama/components/pass_button.dart';
import 'package:lama/constants/card_state.dart';

class LamaGame extends BaseGame with TapDetector {
  String _myUid;
  String roomId;
  bool isReadyGame = true;
  List<Member> _members;
  List<GamePlayer> _gamePlayers;
  Hands _hands;
  List<OtherHands> _othersHands;
  Stocks _stocks;
  Trashes _trashes;
  Size screenSize;
  math.Random _rand;
  DatabaseReference _databaseReference;
  DatabaseReference _gameRef;
  String _hostUid;
  int myOrder;
  int currentOrder;
  PassButton _passButton;

  int get playerCount {
    return _members.length;
  }

  LamaGame({this.roomId, this.screenSize}) {
    LocalStorage storage = LocalStorage('lama_game');
    _myUid = storage.getItem('myUid');
    _databaseReference = FirebaseDatabase.instance.reference();
    _hostUid = '';
    _rand = math.Random();
    _members = [];
    _gamePlayers = [];
    _hands = Hands(this);
    _othersHands = [];
    _trashes = Trashes(this);
    _stocks = Stocks(this);

    _addPassButton(disabled: false);
  }

  Future<void> initializeHost() async {
    DatabaseReference roomRef =
        _databaseReference.child('preparationRooms').child(this.roomId);
    DataSnapshot roomSnapshot = await roomRef.once();
    _hostUid = roomSnapshot.value['hostUid'];
    _gameRef = _databaseReference.child(_hostUid);
    _gameRef.keepSynced(true);
    _gameRef.onChildChanged.listen(_onChange);

    Map snapshotMembers = Map.from(roomSnapshot.value['members'] ?? {});
    snapshotMembers.forEach((uid, name) {
      Member member = Member(uid: uid, name: name);
      _members.add(member);
    });
    _members.shuffle();
    _members.asMap().forEach((index, member) {
      if (member.uid == _myUid) {
        this.myOrder = index;
      }
    });
    _members.asMap().forEach((index, member) {
      GamePlayer gamePlayer = GamePlayer(
        this,
        member.uid,
        member.name,
        (index - this.myOrder - 1) % this.playerCount,
        member.uid == _myUid,
      );
      _gamePlayers.add(gamePlayer);
    });
    _gameRef
        .child('players')
        .set(_gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList());

    this.currentOrder = 0;
    _gameRef.child('current').set(this.currentOrder);
  }

  Future<void> initializeSlave({hostUid: String}) async {
    _hostUid = hostUid;
    _gameRef = _databaseReference.child(_hostUid);
    _gameRef.keepSynced(true);
    _gameRef.onChildChanged.listen(_onChange);

    DataSnapshot gameSnapShot = await _gameRef.once();
    List snapshotPlayers = List.from(gameSnapShot.value['players'] ?? []);
    snapshotPlayers.asMap().forEach((index, snapshotPlayer) {
      String uid = snapshotPlayer['uid'];
      String name = snapshotPlayer['name'];
      if (uid == _myUid) {
        this.myOrder = index;
      }
      Member member = Member(uid: uid, name: name);
      _members.add(member);
      GamePlayer gamePlayer = GamePlayer(
        this,
        uid,
        name,
        (index - this.myOrder - 1) % this.playerCount,
        uid == _myUid,
      );
      _gamePlayers.add(gamePlayer);
    });

    this.currentOrder = gameSnapShot.value['current'];
    this.isReadyGame = false;
  }

  void _onChange(Event e) {
    if (e.snapshot.key == 'cards') {
      List<List<dynamic>> playersCards =
          List<List<dynamic>>.from(e.snapshot.value['players']);

      if (_othersHands.length == 0) {
        for (int i = 0; i < this.playerCount - 1; i++) {
          OtherHands otherHands = OtherHands(this, i);
          _othersHands.add(otherHands);
        }
      }
      playersCards.asMap().forEach((i, playerCards) {
        if (i == this.myOrder) {
          _hands.initialize(List<int>.from(playerCards ?? []));
          return;
        }
        _othersHands[(i - this.myOrder - 1) % this.playerCount]
            .initialize(List<int>.from(playerCards ?? []));
      });

      _stocks.initialize(List<int>.from(e.snapshot.value['stocks'] ?? []));
      // trashes が 0枚 になることはないが、念のため
      _trashes.initialize(List<int>.from(e.snapshot.value['trashes'] ?? []));
      return;
    }
    if (e.snapshot.key == 'current') {
      this.currentOrder = e.snapshot.value;
      return;
    }
    if (e.snapshot.key == 'players') {
      // players の子での initialize
      if (_gamePlayers.length == 0) {
        this.myOrder = e.snapshot.value
            .indexWhere((gamePlayer) => gamePlayer['uid'] == _myUid);

        e.snapshot.value.forEach((value) {
          GamePlayer gamePlayer = GamePlayer(
            this,
            value['uid'],
            value['name'],
            (_gamePlayers.length - this.myOrder - 1) % this.playerCount,
            value['uid'] == _myUid,
          );
          _gamePlayers.add(gamePlayer);
        });
      }
      e.snapshot.value.asMap().forEach((index, gamePlayer) {
        _gamePlayers[index].set(
          gamePlayer['points'],
          gamePlayer['isFinished'],
          gamePlayer['isPassed'],
        );
      });
      if (_isGameEnd) {
        if (_myUid == _hostUid) {
          _processRoundEnd();
          _deal();
        }
        _addPassButton(disabled: false);
      }
      return;
    }
  }

  void _deal() {
    List<int> stocks = List<int>.generate(7 * 8, (int index) => index ~/ 8 + 1);
    stocks.shuffle();
    List<List<int>> playersCards = [];
    for (int i = 0; i < this.playerCount; i++) {
      playersCards.add(stocks.sublist(0, 6));
      stocks.removeRange(0, 6);
    }
    List<int> trashes = stocks.sublist(0, 1);
    stocks.removeRange(0, 1);

    _othersHands = [];
    playersCards.asMap().forEach((i, playerCards) {
      if (i == this.playerCount - 1) {
        _hands.initialize(playerCards);
      } else {
        OtherHands otherHands = OtherHands(this, i);
        otherHands.initialize(playerCards);
        _othersHands.add(otherHands);
      }
    });
    _stocks.initialize(stocks);
    _trashes.initialize(trashes);

    _setCardsAtDatabase();
  }

  void _processRoundEnd() {
    _gamePlayers.asMap().forEach((index, gamePlayer) {
      int points;
      if (index == this.myOrder) {
        points = _hands.points;
      } else {
        points =
            _othersHands[(index - this.myOrder - 1) % this.playerCount].points;
      }
      if (points == 0) {
        gamePlayer.subtractPoints();
      } else {
        gamePlayer.addPoints(points);
      }

      gamePlayer.newRound();
    });
    _gameRef
        .child('players')
        .set(_gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList());
  }

  @override
  void resize(Size size) {
    super.resize(size);
    this.screenSize = size;
  }

  @override
  void onTapUp(details) {
    if (isReadyGame) {
      isReadyGame = false;
      if (_myUid == _hostUid) {
        _deal();
      }
    }

    if (this.currentOrder != this.myOrder || _isGameEnd) {
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
          if (c.state == CardState.Stock && _canDraw) {
            this.drawCard();
            break;
          }
        }
      }

      if (c is PassButton) {
        if (c.toRect().overlaps(touchArea)) {
          _pass();
          break;
        }
      }
    }
  }

  void drawCard() {
    int drawNumber = _stocks.drawCard();
    _hands.drawCard(drawNumber);
    _setCardsAtDatabase();
    _turnEnd();
  }

  bool _discard(FrontCard card) {
    int numberDiff = card.number - _trashes.numbers.last;
    if (numberDiff != 0 && numberDiff != 1 && numberDiff != -6) {
      return false;
    }
    _hands.discard(card);
    _trashes.add(card.number);
    _setCardsAtDatabase();
    _turnEnd();

    if (_hands.numbers.length == 0) {
      _finish();
    }
    return true;
  }

  void _pass() {
    _gamePlayers[this.myOrder].pass();
    _gameRef
        .child('players')
        .set(_gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList());
    _turnEnd();

    _addPassButton(disabled: true);
  }

  void _turnEnd() {
    int nextPlayerIndex = [
      ...(_gamePlayers.sublist(this.myOrder + 1)),
      ...(_gamePlayers.sublist(0, this.myOrder + 1))
    ].indexWhere((gamePlayer) => !gamePlayer.isPassed);
    _gameRef
        .child('current')
        .set((nextPlayerIndex + this.myOrder + 1) % this.playerCount);
  }

  void _finish() {
    _gamePlayers[this.myOrder].finish();
    _gameRef
        .child('players')
        .set(_gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList());
  }

  bool get _isGameEnd {
    // 誰か上がってる || 全員パスしてる
    return _gamePlayers.indexWhere((gamePlayer) => gamePlayer.isFinished) >=
            0 ||
        _gamePlayers.indexWhere((gamePlayer) => !gamePlayer.isPassed) == -1;
  }

  bool get _canDraw {
    // 自分はパスしてない && 山札がある && 自分以外にパスしてない人がいる
    return !_gamePlayers[this.myOrder].isPassed &&
        _stocks.numbers.length > 0 &&
        _gamePlayers.where((gamePlayer) => !gamePlayer.isPassed).length > 1;
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

  void _addPassButton({disabled: bool}) {
    if (_passButton != null) {
      this.markToRemove(_passButton);
    }
    _passButton = PassButton(disabled);
    this.add(_passButton
      ..x = this.screenSize.width - 100
      ..y = this.screenSize.height - 180);
  }
}
