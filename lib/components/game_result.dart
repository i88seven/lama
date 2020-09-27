import 'package:lama/lama_game.dart';

import 'package:lama/components/game_result_background.dart';

class GameResult {
  final LamaGame _game;
  GameResultBackground _background;

  GameResult(this._game);

  void render() {
    _background = GameResultBackground()
      ..width = _game.screenSize.width
      ..height = _game.screenSize.height;
    _game.add(_background);
  }

  void remove() {
    _game.markToRemove(_background);
  }
}
