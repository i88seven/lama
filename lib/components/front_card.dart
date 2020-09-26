import 'dart:math';
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

import 'package:lama/constants/card_state.dart';

// 表向きのカード描画
class FrontCard extends PositionComponent {
  static const Size cardSize = Size(60, 100);
  final int number;
  final CardState state;
  double time = 0;
  int lightIntensity = 0;

  FrontCard(this.number, this.state);

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    renderCard(c, number);
  }

  renderCard(Canvas c, int number) {
    int blue = 255 - lightIntensity;
    Color color = Color.fromARGB(255, 255, 255, blue);
    c.drawRect(Rect.fromLTWH(0, 0, cardSize.width, cardSize.height),
        Paint()..color = color);
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
    time += t * 2;
    this.lightIntensity = ((sin(time) + 1) * 64).floor();
    super.update(t);
  }

  @override
  void onMount() {
    width = cardSize.width;
    height = cardSize.height;
    anchor = Anchor.topLeft;
  }
}
