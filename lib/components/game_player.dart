import 'package:flame/components/text_component.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';

import 'package:lama/lama_game.dart';

class GamePlayer {
  final LamaGame game;
  String name;
  int points;
  bool isFinished;
  bool isPassed;
  int displayOrder; // 自分から見て次の人が "0"
  bool isMe;
  List<TextComponent> _textObjects = [];

  GamePlayer(this.game, this.name, this.displayOrder, this.isMe) {
    this.points = 0;
    this.isFinished = false;
    this.isPassed = false;
    _render();
  }

  void set(int points, bool isFinished, bool isPassed) {
    this.points = points;
    this.isFinished = isFinished;
    this.isPassed = isPassed;
    _render();
  }

  void newRound() {
    this.isFinished = false;
    this.isPassed = false;
  }

  void addPoints(int points) {
    this.points += points;
    _render();
  }

  void subtractPoints() {
    if (this.points > 9) {
      this.points -= 10;
    } else {
      this.points -= 1;
    }
    _render();
  }

  void pass() {
    this.isPassed = true;
  }

  void finish() {
    this.isFinished = true;
  }

  void _render() {
    if (this.isMe) {
      return;
    }

    _textObjects.forEach((textObject) {
      this.game.markToRemove(textObject);
    });
    Position pos = Position(
      this.game.screenSize.width /
          (this.game.playerCount - 1) *
          this.displayOrder,
      0,
    );
    TextComponent textComponent = TextComponent(
      "$name: $points",
      config: TextConfig(color: BasicPalette.white.color),
    );
    this.game.add(textComponent
      ..x = pos.x
      ..y = pos.y);
    _textObjects.add(textComponent);
  }

  toJson() {
    return {
      'name': name,
      'points': points,
      'isFinished': isFinished,
      'isPassed': isPassed,
    };
  }
}
