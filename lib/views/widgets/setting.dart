import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

settingsSpiders(context, Function()? desingCard, Function()? update) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String design = (prefs.getString('design') ?? 'Default');
  showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Center(child: Text("Settings ⚙")),
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
                  desingCard?.call();
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => Navigator.pop(context));
                  update?.call();
                },
                child: const Text("Save"),
              ),
            ],
          );
        });
      });
}
