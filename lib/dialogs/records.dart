import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spider_solitaire/const_value.dart';

getRecords(context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String records = '';
  for (int i = 0; i < countSuits.length; i++) {
    int timeSuit = (prefs.getInt('timesuit${countSuits[i]}') ?? -1);
    int scoreSuit = (prefs.getInt('scoresuit${countSuits[i]}') ?? 0);
    timeSuit != -1
        ? records +=
            '${difficulty[i]}\nTime: ${((timeSuit / 60).truncate()).toString().padLeft(2, '0')}:${(timeSuit % 60).toString().padLeft(2, '0')}\nScore: $scoreSuit\n'
        : records += '${difficulty[i]}\nThe record is not set\n';
  }
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text("Records 🏆")),
          content: Center(child: Text(records)),
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

void reRecords(int gametime, int gamescore, int typegame) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int timeSuit = (prefs.getInt('timesuit${countSuits[typegame]}') ?? -1);
  int scoreSuit = (prefs.getInt('scoresuit${countSuits[typegame]}') ?? 0);
  if (timeSuit == -1 || scoreSuit < gamescore) {
    await prefs.setInt('scoresuit${countSuits[typegame]}', gamescore);
  }
  if (timeSuit == -1 || timeSuit > gametime) {
    await prefs.setInt('timesuit${countSuits[typegame]}', gametime);
  }
}
