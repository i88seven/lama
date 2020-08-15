import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';
import 'package:flutter/material.dart';

import 'package:lama/lama_game.dart';

class Hand extends PositionComponent with HasGameRef<LamaGame> {
  static const Size cardSize = Size(60, 100);
  final int number;
  Position pos;

  Hand(this.number, this.pos);

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    renderCard(c, number, pos);
  }

  renderCard(Canvas c, int number, Position pos) {
    c.drawRect(Rect.fromLTWH(pos.x, pos.y, cardSize.width, cardSize.height),
        BasicPalette.white.paint);
    final textStyle = TextStyle(
      color: Colors.green,
      fontSize: 30,
    );
    final textSpan = TextSpan(
      text: number.toString(),
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: 100,
    );
    final offset = Offset(pos.x, pos.y);
    textPainter.paint(c, offset);
  }

  @override
  void update(double t) {
    super.update(t);
  }
}
