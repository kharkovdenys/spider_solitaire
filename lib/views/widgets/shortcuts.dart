import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UndoIntent extends Intent {
  const UndoIntent();
}

class RestartIntent extends Intent {
  const RestartIntent();
}

class ShortcutsScaffold extends StatelessWidget {
  final Function() backactions, restart, update;
  final Scaffold child;
  const ShortcutsScaffold({
    Key? key,
    required this.child,
    required this.backactions,
    required this.restart,
    required this.update,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return NotificationListener(
        onNotification: (SizeChangedLayoutNotification notification) {
          update();
          return false;
        },
        child: SizeChangedLayoutNotifier(
            child: Shortcuts(
                shortcuts: <ShortcutActivator, Intent>{
              LogicalKeySet(
                      LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyZ):
                  const UndoIntent(),
              LogicalKeySet(
                      LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyR):
                  const RestartIntent()
            },
                child: Actions(actions: <Type, Action<Intent>>{
                  UndoIntent: CallbackAction<UndoIntent>(
                    onInvoke: (UndoIntent intent) => backactions(),
                  ),
                  RestartIntent: CallbackAction<RestartIntent>(
                      onInvoke: (RestartIntent intent) => restart())
                }, child: Focus(autofocus: true, child: child)))));
  }
}
