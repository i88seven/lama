import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';

class GameResultBackground extends PositionComponent {
  static const Color BG_COLOR = Color(0xFF8090C0);
  static const double PADDING = 30.0;

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    c.drawRect(Rect.fromLTWH(0, 0, width, height).deflate(PADDING),
        Paint()..color = BG_COLOR);
  }

  @override
  void update(double t) {
    super.update(t);
  }

  @override
  void onMount() {
    anchor = Anchor.topLeft;
  }
}
