import 'dart:ui';

import 'package:flame/anchor.dart';
import 'package:flame/components/component.dart';
import 'package:flame/palette.dart';

import 'package:lama/constants/card_state.dart';

// 裏向きのカード描画
class BackCard extends PositionComponent {
  static const Size cardSize = Size(60, 85);
  final CardState state;

  BackCard(this.state);

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    renderCard(c);
  }

  renderCard(Canvas c) {
    c.drawRect(Rect.fromLTWH(0, 0, cardSize.width, cardSize.height),
        BasicPalette.white.paint);
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
