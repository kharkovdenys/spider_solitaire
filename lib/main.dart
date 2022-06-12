import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'package:flutter/services.dart';
import 'screen_game.dart';

void main() {
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
    getRecords() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int timesuitone = (prefs.getInt('timesuitone') ?? -1);
      int scoresuitone = (prefs.getInt('scoresuitone') ?? 0);
      String records = '';
      timesuitone != -1
          ? records +=
              'One suit ♠\nTime: ${((timesuitone / 60).truncate()).toString().padLeft(2, '0')}:${(timesuitone % 60).toString().padLeft(2, '0')}\nScore: $scoresuitone'
          : records += 'One suit ♠\nThe record is not set';
      int timesuittwo = (prefs.getInt('timesuittwo') ?? -1);
      int scoresuittwo = (prefs.getInt('scoresuittwo') ?? 0);
      timesuittwo != -1
          ? records +=
              '\nTwo suits ♠ ♥\nTime: ${((timesuittwo / 60).truncate()).toString().padLeft(2, '0')}:${(timesuittwo % 60).toString().padLeft(2, '0')}\nScore: $scoresuittwo'
          : records += '\nTwo suits ♠ ♥\nThe record is not set';
      int timesuitfour = (prefs.getInt('timesuitfour') ?? -1);
      int scoresuitfour = (prefs.getInt('scoresuitfour') ?? 0);
      timesuitfour != -1
          ? records +=
              '\nFour suits ♠ ♥ ♣ ♦\nTime: ${((timesuitfour / 60).truncate()).toString().padLeft(2, '0')}:${(timesuitfour % 60).toString().padLeft(2, '0')}\nScore: $scoresuitfour'
          : records += '\nFour suits ♠ ♥ ♣ ♦\nThe record is not set';
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Center(child: Text("Records 🏆", style: txtstyle)),
              content: Center(child: Text(records, style: txtstyle)),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),
              ],
            );
          });
    }

    settingsSpiders() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String design = (prefs.getString('design') ?? 'Default');
      showDialog(
          context: context,
          builder: (context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                title: Center(child: Text("Settings ⚙", style: txtstyle)),
                content: Center(
                    child: Row(children: [
                  const Text('Design choice:'),
                  DropdownButton<String>(
                    value: design,
                    items: <String>['Default', 'Essberger']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        design = value!;
                      });
                    },
                  )
                ])),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await prefs.setString('design', design);
                      Navigator.pop(context);
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            });
          });
    }

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
              child: Center(child: Text('One suit ♠', style: txtstyle)),
            ),
            SimpleDialogOption(
              onPressed: () {
                typegame = 1;
                Navigator.pushReplacementNamed(context, '/game');
              },
              child: Center(child: Text('Two suits ♠ ♥', style: txtstyle)),
            ),
            SimpleDialogOption(
              onPressed: () {
                typegame = 2;
                Navigator.pushReplacementNamed(context, '/game');
              },
              child:
                  Center(child: Text('Four suits ♠ ♥ ♣ ♦', style: txtstyle)),
            ),
            SimpleDialogOption(
              onPressed: () {
                getRecords();
              },
              child: Center(child: Text('Records 🏆', style: txtstyle)),
            ),
            SimpleDialogOption(
              onPressed: () {
                settingsSpiders();
              },
              child: Center(child: Text('Settings ⚙', style: txtstyle)),
            ),
          ],
        ));
  }
}
