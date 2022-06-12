import 'dart:math';
import 'screen_game.dart';

bool iter = false;
int countEmpty = 0;

void stateGame() async {
  Random random = Random();
  int randIndex = 0;
  for (int r = 1; r <= 6; r++) {
    for (int k = 1; k <= 1000; k++) {
      List<String> moves = await bestMove();
      if (moves.isEmpty) {
        break;
      } else {
        randIndex = random.nextInt(moves.length);
        getmove(moves[randIndex]);
        await Future.delayed(const Duration(milliseconds: 50));
        if (countEmpty == 10 && r < 6) {
          for (int z = 0; z < 10; z++) {
            if (rowcard[z].isEmpty) {
              continue;
            }
            while (rowcard[z].length > 1) {
              int empty = 0;
              for (int u = 0; u < 10; u++) {
                if (rowcard[u].isEmpty && rowcard[z].length > 1) {
                  empty++;
                  getmove('$z,${rowcard[z].length - 1},$u');
                  await Future.delayed(const Duration(milliseconds: 50));
                }
              }
              if (empty == 0) {
                break;
              }
            }
          }
          break;
        }
      }
    }
    if (r < 6) {
      getmove('deck');
    } else {
      iter = true;
    }
    countEmpty = 0;
  }
}

Future<List<String>> bestMove() async {
  List<String> noEmptyMoves = [], noEmptyNoSuitMoves = [], emptyMoves = [];
  for (int i = 0; i < 10; i++) {
    int countdowncard = 0;
    for (var element in rowcardFace[i]) {
      if (element == false) {
        countdowncard++;
      }
    }
    int indexstartconsecutive = countdowncard;
    for (int j = countdowncard; j < rowcard[i].length - 1; j++) {
      if (!((rowcard[i][j + 1] != 11 &&
                  rowcard[i][j] - 1 == rowcard[i][j + 1]) ||
              (rowcard[i][j + 1] == 12 && rowcard[i][j] == 0)) ||
          (rowsuit[i][j] != rowsuit[i][j + 1])) {
        indexstartconsecutive = j + 1;
      }
    }
    for (int t = indexstartconsecutive; t < rowcard[i].length; t++) {
      for (int z = 0; z < 10; z++) {
        if (z == i) {
          continue;
        }
        if (rowcard[z].isEmpty) {
          if (t == indexstartconsecutive) {
            emptyMoves.add('$i,$indexstartconsecutive,$z');
          }
        } else {
          if (t == indexstartconsecutive) {
            if (rowcard[i].isNotEmpty &&
                ((rowcard[i][indexstartconsecutive] != 11 &&
                        rowcard[z].last - 1 ==
                            rowcard[i][indexstartconsecutive]) ||
                    (rowcard[i][indexstartconsecutive] == 12 &&
                        rowcard[z].last == 0))) {
              if (rowsuit[z].last == rowsuit[i].last) {
                noEmptyMoves.add('$i,$indexstartconsecutive,$z');
              } else {
                noEmptyNoSuitMoves.add('$i,$indexstartconsecutive,$z');
              }
            }
          } else {
            int odds = t - indexstartconsecutive;
            int countupcard = 0;
            for (var element in rowcardFace[z]) {
              if (element == true) {
                countupcard++;
              }
            }
            if (countupcard > odds) {
              int countdowncardT = 0;
              for (var element in rowcardFace[z]) {
                if (element == false) {
                  countdowncardT++;
                }
              }
              int indexstartconsecutiveT = countdowncardT;
              for (int j = countdowncardT; j < rowcard[z].length - 1; j++) {
                if (!((rowcard[z][j + 1] != 11 &&
                            rowcard[z][j] - 1 == rowcard[z][j + 1]) ||
                        (rowcard[z][j + 1] == 12 && rowcard[z][j] == 0)) ||
                    (rowsuit[z][j] != rowsuit[z][j + 1])) {
                  indexstartconsecutiveT = j + 1;
                }
              }
              int lenbest = rowcard[z].length - indexstartconsecutiveT;
              if (lenbest > odds) {
                if (rowcard[i].isNotEmpty &&
                    ((rowcard[i][t] != 11 &&
                            rowcard[z].last - 1 == rowcard[i][t]) ||
                        (rowcard[i][t] == 12 && rowcard[z].last == 0))) {
                  if (rowsuit[z].last == rowsuit[i].last) {
                    noEmptyMoves.add('$i,$t,$z');
                  } else {
                    noEmptyNoSuitMoves.add('$i,$t,$z');
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  if (noEmptyMoves.isNotEmpty) {
    countEmpty = 0;
    return noEmptyMoves;
  } else if (noEmptyNoSuitMoves.isNotEmpty) {
    countEmpty = 0;
    return noEmptyNoSuitMoves;
  } else {
    countEmpty++;
    return emptyMoves;
  }
}

void getmove(String move) {
  if (move == 'deck') {
    for (int i = 0; i < 10; i++) {
      rowcard[i].add(deckcard.first);
      rowsuit[i].add(deckcardsuit.first);
      deckcard.removeAt(0);
      deckcardsuit.removeAt(0);
      rowcardFace[i].add(true);
    }
    deck.removeLast();
  } else {
    List<String> tempdata = move.toString().split(",");
    int tempindexstart = int.parse(tempdata[1]),
        columnnum = int.parse(tempdata[2]),
        tempindexrow = int.parse(tempdata[0]);
    rowcard[columnnum].addAll(rowcard[tempindexrow]
        .getRange(tempindexstart, rowcard[tempindexrow].length));
    rowcard[tempindexrow]
        .removeRange(tempindexstart, rowcard[tempindexrow].length);
    rowsuit[columnnum].addAll(rowsuit[tempindexrow]
        .getRange(tempindexstart, rowsuit[tempindexrow].length));
    rowsuit[tempindexrow]
        .removeRange(tempindexstart, rowsuit[tempindexrow].length);
    rowcardFace[columnnum].addAll(rowcardFace[tempindexrow]
        .getRange(tempindexstart, rowcardFace[tempindexrow].length));
    rowcardFace[tempindexrow]
        .removeRange(tempindexstart, rowcardFace[tempindexrow].length);
    if (rowcardFace[tempindexrow].isNotEmpty &&
        rowcardFace[tempindexrow].last == false) {
      rowcardFace[tempindexrow][rowcardFace[tempindexrow].length - 1] = true;
    }
    if (rowcard[columnnum].isNotEmpty &&
        rowcard[columnnum].last == 12 &&
        rowcard[columnnum].length >= 13 &&
        rowcardFace[columnnum].last == true) {
      int flag = 1;
      int suit = rowsuit[columnnum].last;
      for (int i = 0; i < 12; i++) {
        if (!(rowcard[columnnum][rowcard[columnnum].length - 2 - i] == i &&
            rowcardFace[columnnum][rowcard[columnnum].length - 2 - i] == true &&
            rowsuit[columnnum][rowcard[columnnum].length - 2 - i] == suit)) {
          flag = 0;
          break;
        }
      }
      if (flag == 1) {
        rowcard[columnnum].removeRange(
            rowcard[columnnum].length - 13, rowcard[columnnum].length);
        rowcardFace[columnnum].removeRange(
            rowcardFace[columnnum].length - 13, rowcardFace[columnnum].length);
        rowsuit[columnnum].removeRange(
            rowsuit[columnnum].length - 13, rowsuit[columnnum].length);
        if (rowcardFace[columnnum].isNotEmpty &&
            rowcardFace[columnnum].last == false) {
          rowcardFace[columnnum].removeLast();
          rowcardFace[columnnum].add(true);
        }
        domsuit.add(suit);
      }
    }
  }
}
