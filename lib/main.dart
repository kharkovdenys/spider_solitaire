import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spider_solitaire/views/widgets/menu.dart';
import 'package:spider_solitaire/views/screens/splash.dart';
import 'package:spider_solitaire/views/screens/game.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  if (!kIsWeb && Platform.isWindows) {
    await windowManager.ensureInitialized();
    windowManager.waitUntilReadyToShow().then((_) async {
      await windowManager.setFullScreen(true);
    });
  }
  runApp(MaterialApp(
    title: 'Spider Solitaire',
    home: const SplashScreen(
        navigateRoute:
            Scaffold(body: Menu(), backgroundColor: Color(0xFF4CAF50))),
    routes: {'/game': (context) => const GameScreen()},
    theme: ThemeData(fontFamily: 'Roboto'),
    debugShowCheckedModeBanner: false,
  ));
}
