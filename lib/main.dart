import 'package:flutter/material.dart';

import 'package:lama/lama_game.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final game = LamaGame();

  runApp(game.widget);
}
