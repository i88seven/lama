import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class Hand extends PositionComponent {
  static const Size cardSize = Size(60, 100);
  final int number;

  Hand(this.number);

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    renderCard(c, number);
  }

  renderCard(Canvas c, int number) {
    c.drawRect(Rect.fromLTWH(0, 0, cardSize.width, cardSize.height),
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
    final offset = Offset(0, 0);
    textPainter.paint(c, offset);
  }

  @override
  void update(double t) {
    super.update(t);
  }

  @override
  void onMount() {
    width = cardSize.width;
    height = cardSize.height;
    anchor = Anchor.topLeft;
  }
}
