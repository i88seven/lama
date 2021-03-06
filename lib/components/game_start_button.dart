import 'dart:ui';

import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';

class GameStartButton extends PositionComponent {
  static const Size size = Size(112, 50);

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    c.drawRect(
        Rect.fromLTWH(0, 0, width, height), Paint()..color = Color(0xFF39C23F));
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
    );
    final textSpan = TextSpan(
      text: 'Start!!',
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
    final offset = Offset(10, 4);
    textPainter.paint(c, offset);
  }

  @override
  void onMount() {
    width = size.width;
    height = size.height;
  }
}
