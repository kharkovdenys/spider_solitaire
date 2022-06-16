import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spider_solitaire/const_value.dart';
import 'package:spider_solitaire/dialogs/records.dart';
import 'package:spider_solitaire/dialogs/setting.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';
import 'screen_game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setFullScreen(true);
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Widget splash = SplashScreenView(
      navigateRoute: const HomeScreen(),
      duration: 5000,
      imageSize: 130,
      imageSrc: "spider.png",
      text: "Spider Solitaire",
      textType: TextType.TyperAnimatedText,
      textStyle: const TextStyle(
        fontSize: 40.0,
      ),
      backgroundColor: const Color(0xFF4CAF50),
    );
    return MaterialApp(
      title: 'Spider Solitaire ',
      home: splash,
      routes: {'/game': (context) => const GameScreen()},
      theme: ThemeData(fontFamily: 'Roboto'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: const Color(0xFF4CAF50),
        child: SimpleDialog(
          title: const Center(child: Text("Choice of difficulty level")),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                typegame = 0;
                Navigator.pushReplacementNamed(context, '/game');
              },
              child: Center(child: Text(difficulty[0])),
            ),
            SimpleDialogOption(
              onPressed: () {
                typegame = 1;
                Navigator.pushReplacementNamed(context, '/game');
              },
              child: Center(child: Text(difficulty[1])),
            ),
            SimpleDialogOption(
              onPressed: () {
                typegame = 2;
                Navigator.pushReplacementNamed(context, '/game');
              },
              child: Center(child: Text(difficulty[2])),
            ),
            SimpleDialogOption(
              onPressed: () {
                getRecords(context);
              },
              child: const Center(child: Text('Records 🏆')),
            ),
            SimpleDialogOption(
              onPressed: () {
                settingsSpiders(context);
              },
              child: const Center(child: Text('Settings ⚙')),
            ),
          ],
        ));
  }
}
