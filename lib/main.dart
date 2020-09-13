import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:lama/lama_game.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //向き指定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, //縦固定
  ]);
  await Firebase.initializeApp();
  final game = LamaGame();

  runApp(game.widget);
}
