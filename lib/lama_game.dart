import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flame/gestures.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:lama/components/game_end_button.dart';
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
import 'package:lama/components/game_result.dart';
import 'package:lama/constants/card_state.dart';

class LamaGame extends BaseGame with TapDetector {
  String _myUid;
  String _roomId;
  bool _isReadyGame = false;
  bool _isTapping = false;
  List<Member> _members;
  List<GamePlayer> _gamePlayers;
  Hands _hands;
  List<OtherHands> _othersHands;
  Stocks _stocks;
  Trashes _trashes;
  GameResult _gameResult;
  Size screenSize;
  DatabaseReference _databaseReference;
  DatabaseReference _gameRef;
  String _hostUid;
  int _myOrder;
  int _currentOrder;
  PassButton _passButton;
  Function onGameEnd;

  int get playerCount {
    return _members.length;
  }

  LamaGame(this._roomId, this.screenSize, this.onGameEnd) {
    LocalStorage storage = LocalStorage('lama_game');
    _myUid = storage.getItem('myUid');
    _databaseReference = FirebaseDatabase.instance.reference();
    _hostUid = '';
    _members = [];
    _gamePlayers = [];
    _hands = Hands(this);
    _othersHands = [];
    _trashes = Trashes(this);
    _stocks = Stocks(this);
    _gameResult = GameResult(this, _gamePlayers);
  }

  Future<void> initializeHost() async {
    DatabaseReference roomRef =
        _databaseReference.child('preparationRooms').child(_roomId);
    DataSnapshot roomSnapshot = await roomRef.once();
    _hostUid = roomSnapshot.value['hostUid'];
    _gameRef = _databaseReference.child(_hostUid);
    await _gameRef.remove();
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
        _myOrder = index;
      }
    });
    _members.asMap().forEach((index, member) {
      GamePlayer gamePlayer = GamePlayer(
        this,
        member.uid,
        member.name,
        (index - _myOrder - 1) % this.playerCount,
        member.uid == _myUid,
      );
      _gamePlayers.add(gamePlayer);
    });
    await _gameRef
        .child('players')
        .set(_gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList());

    for (int i = 0; i < this.playerCount - 1; i++) {
      OtherHands otherHands = OtherHands(this, i);
      _othersHands.add(otherHands);
    }
  }

  Future<void> initializeSlave({hostUid: String}) async {
    _hostUid = hostUid;
    _gameRef = _databaseReference.child(_hostUid);
    _gameRef.keepSynced(true);
    _gameRef.onChildChanged.listen(_onChange);
    _gameRef.onChildAdded.listen(_onChange);

    DataSnapshot gameSnapShot = await _gameRef.once();
    List snapshotPlayers = List.from(gameSnapShot.value['players'] ?? []);
    snapshotPlayers.asMap().forEach((index, snapshotPlayer) {
      String uid = snapshotPlayer['uid'];
      if (uid == _myUid) {
        _myOrder = index;
      }
    });
    snapshotPlayers.asMap().forEach((index, snapshotPlayer) {
      String uid = snapshotPlayer['uid'];
      String name = snapshotPlayer['name'];
      Member member = Member(uid: uid, name: name);
      _members.add(member);
      GamePlayer gamePlayer = GamePlayer(
        this,
        uid,
        name,
        (index - _myOrder - 1) % this.playerCount,
        uid == _myUid,
      );
      _gamePlayers.add(gamePlayer);
    });

    for (int i = 0; i < this.playerCount - 1; i++) {
      OtherHands otherHands = OtherHands(this, i);
      _othersHands.add(otherHands);
    }

    _isReadyGame = true;
  }

  Future<void> _onChange(Event e) async {
    if (e.snapshot.key == 'cards') {
      List<List<dynamic>> playersCards =
          List<List<dynamic>>.from(e.snapshot.value['players']);

      // hands の initialize の前に trash を initialize する
      _trashes.initialize(List<int>.from(e.snapshot.value['trashes'] ?? []));

      playersCards.asMap().forEach((i, playerCards) {
        if (i == _myOrder) {
          _hands.initialize(List<int>.from(playerCards ?? []));
          return;
        }
        _othersHands[(i - _myOrder - 1) % this.playerCount]
            .initialize(List<int>.from(playerCards ?? []));
      });

      _stocks.initialize(List<int>.from(e.snapshot.value['stocks'] ?? []));
      if (_isRoundEnd) {
        await _processRoundEnd();
        return;
      }
      return;
    }
    if (e.snapshot.key == 'current') {
      if (_passButton == null) {
        _passButton = PassButton();
        this.add(_passButton
          ..x = this.screenSize.width - 100
          ..y = this.screenSize.height - 180);
      }
      _currentOrder = e.snapshot.value;
      _hands.setActive(_currentOrder == _myOrder);
      _passButton.setDisabled(_currentOrder != _myOrder);
      return;
    }
    if (e.snapshot.key == 'players') {
      e.snapshot.value.asMap().forEach((index, gamePlayer) {
        if (_gamePlayers.length > 0) {
          _gamePlayers[index].set(
            gamePlayer['points'],
            gamePlayer['isFinished'],
            gamePlayer['isPassed'],
          );
          if (_passButton != null && index == _myOrder && _isReadyGame) {
            _passButton.setDisabled(gamePlayer['isPassed']);
          }
          if (index == _myOrder && _isReadyGame) {
            _hands.setActive(_currentOrder == _myOrder);
          }
        }
      });
      if (_isGameEnd) {
        _processGameEnd();
        return;
      }
      if (_isRoundEnd) {
        await _processRoundEnd();
      }
      return;
    }
  }

  Future<void> _deal() async {
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
        _othersHands[i].initialize(playerCards);
      }
    });
    _stocks.initialize(stocks);
    _trashes.initialize(trashes);
    await _setCardsAtDatabase();

    _currentOrder = 0;
    _hands.setActive(_currentOrder == _myOrder);
    await _gameRef.child('current').set(_currentOrder);

    if (_passButton == null) {
      _passButton = PassButton();
      _passButton.setDisabled(_currentOrder != _myOrder);
      this.add(_passButton
        ..x = this.screenSize.width - 100
        ..y = this.screenSize.height - 180);
    }
    _passButton.setDisabled(_currentOrder != _myOrder);
  }

  Future<void> _processRoundEnd() async {
    if (_myUid == _hostUid) {
      await _processRoundEndHost();
    }
    _passButton?.setDisabled(true);
  }

  Future<void> _processRoundEndHost() async {
    _gamePlayers.asMap().forEach((index, gamePlayer) {
      int points;
      if (gamePlayer.isFinished) {
        gamePlayer.subtractPoints();
      } else {
        if (index == _myOrder) {
          points = _hands.points;
        } else {
          points =
              _othersHands[(index - _myOrder - 1) % this.playerCount].points;
        }
        gamePlayer.addPoints(points);
      }

      gamePlayer.newRound();
    });
    // _isGameEnd の状態を一旦 False にしないと何度も得点が加算される
    _stocks.initialize([0]);
    await _gameRef
        .child('players')
        .set(_gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList());

    if (_isGameEnd) {
      _processGameEnd();
      return;
    }
    await _deal();
  }

  void _processGameEnd() {
    _gameResult.render();
  }

  @override
  void resize(Size size) {
    super.resize(size);
    this.screenSize = size;
  }

  @override
  Future<void> onTapUp(details) async {
    if (!_isReadyGame) {
      _isReadyGame = true;
      if (_myUid == _hostUid) {
        await _deal();
      }
      return;
    }

    if (_isGameEnd) {
      for (final c in components) {
        if (c is GameEndButton && c.toRect().contains(details.localPosition)) {
          _gameResult.remove();
          this.onGameEnd();
        }
      }
    }

    if (_isTapping || _currentOrder != _myOrder || _isRoundEnd) {
      return;
    }
    _isTapping = true;

    final touchArea = Rect.fromCenter(
      center: details.localPosition,
      width: 2,
      height: 2,
    );

    for (final c in components) {
      if (c is FrontCard) {
        if (c.toRect().overlaps(touchArea)) {
          if (c.state == CardState.Hand) {
            bool success = await _discard(c);
            if (success) {
              break;
            }
          }
        }
      }

      if (c is BackCard) {
        if (c.toRect().overlaps(touchArea)) {
          if (c.state == CardState.Stock && _canDraw) {
            await _drawCard();
            break;
          }
        }
      }

      if (c is PassButton) {
        if (c.toRect().overlaps(touchArea)) {
          await _pass();
          break;
        }
      }
    }
    _isTapping = false;
  }

  Future<void> _drawCard() async {
    int drawNumber = _stocks.drawCard();
    _hands.drawCard(drawNumber);
    await _setCardsAtDatabase();
    if (_isRoundEnd) {
      await _processRoundEnd();
      return;
    }
    await _turnEnd();
  }

  Future<bool> _discard(FrontCard card) async {
    int numberDiff = card.number - _trashes.numbers.last;
    if (numberDiff != 0 && numberDiff != 1 && numberDiff != -6) {
      return false;
    }
    _hands.discard(card);
    _trashes.add(card.number);
    await _setCardsAtDatabase();
    await _turnEnd();

    if (_hands.numbers.length == 0) {
      await _finish();
    }
    return true;
  }

  Future<void> _pass() async {
    _passButton.setDisabled(true);
    _gamePlayers[_myOrder].pass();
    await _gameRef
        .child('players')
        .set(_gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList());
    await _turnEnd();
  }

  Future<void> _turnEnd() async {
    int nextPlayerIndex = [
      ...(_gamePlayers.sublist(_myOrder + 1)),
      ...(_gamePlayers.sublist(0, _myOrder + 1))
    ].indexWhere((gamePlayer) => !gamePlayer.isPassed);
    await _gameRef
        .child('current')
        .set((nextPlayerIndex + _myOrder + 1) % this.playerCount);
  }

  Future<void> _finish() async {
    _gamePlayers[_myOrder].finish();
    await _gameRef
        .child('players')
        .set(_gamePlayers.map((gamePlayer) => gamePlayer.toJson()).toList());
  }

  bool get _isRoundEnd {
    // TODO 山札がなくなってもゲームはできる
    // 誰か上がってる || 全員パスしてる || 山札がなくなった
    return _gamePlayers.indexWhere((gamePlayer) => gamePlayer.isFinished) >=
            0 ||
        _gamePlayers.indexWhere((gamePlayer) => !gamePlayer.isPassed) == -1 ||
        _stocks.numbers.length == 0;
  }

  bool get _isGameEnd {
    return _gamePlayers.indexWhere((gamePlayer) => gamePlayer.isGameOver) >= 0;
  }

  bool get _canDraw {
    // 自分はパスしてない && 山札がある && 自分以外にパスしてない人がいる
    return !_gamePlayers[_myOrder].isPassed &&
        _stocks.numbers.length > 0 &&
        _gamePlayers.where((gamePlayer) => !gamePlayer.isPassed).length > 1;
  }

  int get trashNumber {
    return _trashes.numbers.length > 0 ? _trashes.numbers.last : 0;
  }

  Future<void> _setCardsAtDatabase() async {
    List<List<int>> playersCards = [
      _hands.numbers,
      ...(_othersHands.map((otherHands) => otherHands.numbers))
    ];
    await _gameRef.child('cards').set({
      'players': [
        ...(playersCards.sublist(this.playerCount - _myOrder)),
        ...(playersCards.sublist(0, (this.playerCount - _myOrder)))
      ],
      'stocks': _stocks.numbers,
      'trashes': _trashes.numbers,
    });
  }
}
