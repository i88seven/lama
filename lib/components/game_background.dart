import 'dart:ui';

import 'package:lama/lama_game.dart';
import 'package:flame/components/component.dart';

class GameBackground extends PositionComponent {
  final LamaGame _game;

  GameBackground(this._game);

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    c.drawRect(
        Rect.fromLTWH(0, 0, _game.screenSize.width, _game.screenSize.height),
        Paint()..color = Color(0xFF585D57));
  }
}
