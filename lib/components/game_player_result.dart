import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';

import 'package:lama/components/game_player.dart';

class GamePlayerResult extends PositionComponent {
  final GamePlayer _gamePlayer;

  GamePlayerResult(this._gamePlayer);

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
    );
    final textSpan = TextSpan(
      text: "${_gamePlayer.name} : ${_gamePlayer.points}",
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: width,
    );
    final offset = Offset(24, 4);
    textPainter.paint(c, offset);
  }
}
