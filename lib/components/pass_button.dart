import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';

class PassButton extends PositionComponent {
  static const Size _size = Size(80, 56);

  PassButton();

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    c.drawRect(Rect.fromLTWH(0, 0, _size.width, _size.height),
        PaletteEntry(Color(0xFF39C23F)).paint);
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
    );
    final textSpan = TextSpan(
      text: 'パス',
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
