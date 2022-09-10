import 'package:flutter/material.dart';
import 'package:spider_solitaire/services/constants.dart';
import 'package:spider_solitaire/views/screens/game.dart';
import 'package:spider_solitaire/views/widgets/records.dart';
import 'package:spider_solitaire/views/widgets/setting.dart';

class Menu extends StatelessWidget {
  final Function()? desingCard, update;
  const Menu({Key? key, this.desingCard, this.update}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
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
            settingsSpiders(context, desingCard, update);
          },
          child: const Center(child: Text('Settings ⚙')),
        ),
      ],
    );
  }
}
