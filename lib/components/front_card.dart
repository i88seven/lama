import 'dart:math';
import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';

import 'package:lama/constants/card_state.dart';

// 表向きのカード描画
class FrontCard extends PositionComponent {
  static const Size cardSize = Size(60, 85);
  final int number;
  final CardState state;
  final active;
  double time = 0;
  int lightIntensity = 0;
  Sprite _cardImage;
  static const int MAX_LIGHT_INTENSITY = 160;

  FrontCard(this.number, this.state, this.active) {
    _cardImage = Sprite('card-7.png');
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    renderCard(c, number);
  }

  renderCard(Canvas c, int number) {
    Rect rect = Rect.fromLTWH(0, 0, cardSize.width, cardSize.height);
    _cardImage.renderRect(c, rect);
    if (this.active) {
      int alpha = MAX_LIGHT_INTENSITY - lightIntensity;
      Color color = Color.fromARGB(alpha, 255, 255, 128);
      c.drawRect(rect, Paint()..color = color);
    }
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
    if (!this.active) {
      return;
    }
    time += t * 2;
    this.lightIntensity = ((sin(time) + 1) * MAX_LIGHT_INTENSITY / 2).floor();
    super.update(t);
  }

  @override
  void onMount() {
    width = cardSize.width;
    height = cardSize.height;
    anchor = Anchor.topLeft;
  }
}
