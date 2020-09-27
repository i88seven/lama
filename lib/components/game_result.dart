import 'package:lama/lama_game.dart';

import 'package:lama/components/game_result_background.dart';
import 'package:lama/components/game_end_button.dart';

class GameResult {
  final LamaGame _game;
  GameResultBackground _background;
  GameEndButton _endButton;

  GameResult(this._game);

  void render() {
    _background = GameResultBackground()
      ..width = _game.screenSize.width
      ..height = _game.screenSize.height;
    _game.add(_background);

    _endButton = GameEndButton()
      ..x = _game.screenSize.width / 2 - 40
      ..y = _game.screenSize.height - 110;
    _game.add(_endButton);
  }

  void remove() {
    _game.markToRemove(_background);
  }
}
