import 'package:lama/lama_game.dart';

import 'package:lama/components/game_player.dart';
import 'package:lama/components/game_result_background.dart';
import 'package:lama/components/game_end_button.dart';
import 'package:lama/components/game_player_result.dart';

class GameResult {
  final LamaGame _game;
  final List<GamePlayer> _gamePlayers;
  GameResultBackground _background;
  GameEndButton _endButton;
  List<GamePlayerResult> _gamePlayerResults = [];

  GameResult(this._game, this._gamePlayers);

  void render() {
    _background = GameResultBackground()
      ..width = _game.screenSize.width
      ..height = _game.screenSize.height;
    _game.add(_background);

    _endButton = GameEndButton()
      ..x = _game.screenSize.width / 2 - 40
      ..y = _game.screenSize.height - 110;
    _game.add(_endButton);

    _gamePlayers.sort((a, b) => b.points - a.points);
    _gamePlayers.asMap().forEach((index, gamePlayer) {
      GamePlayerResult gamePlayerResult = GamePlayerResult(gamePlayer)
        ..x = 30
        ..y = (index * 50 + 50).toDouble()
        ..width = _game.screenSize.width - 60;
      _game.add(gamePlayerResult);
      _gamePlayerResults.add(gamePlayerResult);
    });
  }

  void remove() {
    _game.markToRemove(_background);
    _game.markToRemove(_endButton);
    _gamePlayerResults.forEach((gamePlayerResult) {
      _game.markToRemove(gamePlayerResult);
    });
  }
}
