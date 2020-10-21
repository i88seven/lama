import 'dart:math';
import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';

import 'package:lama/constants/card_state.dart';

// 表向きのカード描画
class FrontCard extends PositionComponent {
  static const Size cardSize = Size(90, 127);
  final int number;
  final CardState state;
  final active;
  double time = 0;
  int lightIntensity = 0;
  Sprite _cardImage;
  static const int MAX_LIGHT_INTENSITY = 160;

  FrontCard(this.number, this.state, this.active) {
    _cardImage = Sprite("card-${this.number}.png");
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
}
