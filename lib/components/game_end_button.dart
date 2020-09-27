import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flutter/material.dart';

class GameEndButton extends PositionComponent {
  static const Size _size = Size(80, 56);

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
      text: '終了',
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
    width = _size.width;
    height = _size.height;
    anchor = Anchor.topLeft;
  }
}
