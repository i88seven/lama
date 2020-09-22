import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:localstorage/localstorage.dart';

import 'package:lama/pages/preparation/main.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //向き指定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, //縦固定
  ]);
  await Firebase.initializeApp();
  UserCredential userCredential = await _auth.signInAnonymously();
  LocalStorage storage = LocalStorage('lama_game');
  await storage.ready;
  storage.setItem('myUid', userCredential.user.uid);
  runApp(LamaApp());
}

class LamaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Firebase Example App', // TODO
        theme: ThemeData.dark(),
        home: Scaffold(
          body: PreparationMainPage(),
        ));
  }
}
