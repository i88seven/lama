import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flame/components/component.dart';

import 'package:lama/constants/card_state.dart';

// 裏向きのカード描画
class BackCard extends PositionComponent {
  static const Size cardSize = Size(90, 127);
  final CardState state;
  Sprite _cardImage;

  BackCard(this.state) {
    _cardImage = Sprite("card-back.png");
  }

  @override
  void render(Canvas c) {
    prepareCanvas(c);

    renderCard(c);
  }

  renderCard(Canvas c) {
    Rect rect = Rect.fromLTWH(0, 0, cardSize.width, cardSize.height);
    _cardImage.renderRect(c, rect);
  }

  @override
  void update(double t) {
    super.update(t);
  }

  @override
  void onMount() {
    width = cardSize.width;
    height = cardSize.height;
  }
}
