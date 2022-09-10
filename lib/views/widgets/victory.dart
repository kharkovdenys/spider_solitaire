import 'package:flutter/material.dart';

victoryDialog(context, gametime, gamescore, restart) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Congratulations!"),
        content: Text(
            'You won!\nTime: ${((gametime / 60).truncate()).toString().padLeft(2, '0')}:${(gametime % 60).toString().padLeft(2, '0')}\nScore: $gamescore'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              restart();
            },
            child: const Text("Start again"),
          ),
        ],
      );
    },
  );
}
