import 'package:flutter/material.dart';

import 'package:flame/components/text_component.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';

import 'package:lama/lama_game.dart';

class GamePlayer {
  final LamaGame game;
  String uid;
  String name;
  int _points;
  bool isFinished;
  bool isPassed;
  int displayOrder; // 自分から見て次の人が "0"
  bool isMe;
  bool _isOnesTurn = false;
  TextComponent _textObject;

  GamePlayer(this.game, this.uid, this.name, this.displayOrder, this.isMe) {
    _points = 0;
    this.isFinished = false;
    this.isPassed = false;
    _render();
  }

  void set(int points, bool isFinished, bool isPassed) {
    _points = points;
    this.isFinished = isFinished;
    this.isPassed = isPassed;
    _render();
  }

  void updateTurn(bool isOnesTurn) {
    this._isOnesTurn = isOnesTurn;
    _render();
  }

  void newRound() {
    this.isFinished = false;
    this.isPassed = false;
  }

  void addPoints(int points) {
    _points += points;
    _render();
  }

  void subtractPoints() {
    if (_points > 9) {
      _points -= 10;
    } else if (_points > 0) {
      _points -= 1;
    }
    _render();
  }

  void pass() => this.isPassed = true;

  void finish() => this.isFinished = true;

  void _render() {
    if (_textObject != null) {
      this.game.markToRemove(_textObject);
    }
    Position pos;
    if (this.isMe) {
      pos = Position(
        0,
        this.game.screenSize.height - 30,
      );
    } else {
      pos = Position(
        this.game.screenSize.width /
            (this.game.playerCount - 1) *
            this.displayOrder,
        30.0 + (15 * (this.displayOrder % 2)),
      );
    }
    _textObject = TextComponent(
      "$name: $_points",
      config: TextConfig(color: _textColor, fontSize: this.isMe ? 24.0 : 12.0),
    );
    this.game.add(_textObject
      ..x = pos.x
      ..y = pos.y);
  }

  Color get _textColor {
    if (this.isPassed) {
      return BasicPalette.black.color;
    }
    if (_isOnesTurn) {
      return Colors.yellow;
    }
    return BasicPalette.white.color;
  }

  bool get isGameOver => _points >= 40;

  int get points => _points;

  toJson() {
    return {
      'uid': uid,
      'name': name,
      'points': _points,
      'isFinished': isFinished,
      'isPassed': isPassed,
    };
  }
}
