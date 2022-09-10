import 'dart:math';
import 'package:spider_solitaire/views/screens/game.dart';

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
    for (var element in rowcard[i]) {
      if (element.face == false) {
        countdowncard++;
      }
    }
    int indexstartconsecutive = countdowncard;
    for (int j = countdowncard; j < rowcard[i].length - 1; j++) {
      if (!((rowcard[i][j + 1].value != 11 &&
                  rowcard[i][j].value - 1 == rowcard[i][j + 1].value) ||
              (rowcard[i][j + 1].value == 12 && rowcard[i][j].value == 0)) ||
          (rowcard[i][j].suit != rowcard[i][j + 1].suit)) {
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
                ((rowcard[i][indexstartconsecutive].value != 11 &&
                        rowcard[z].last.value - 1 ==
                            rowcard[i][indexstartconsecutive].value) ||
                    (rowcard[i][indexstartconsecutive].value == 12 &&
                        rowcard[z].last.value == 0))) {
              if (rowcard[z].last.suit == rowcard[i].last.suit) {
                noEmptyMoves.add('$i,$indexstartconsecutive,$z');
              } else {
                noEmptyNoSuitMoves.add('$i,$indexstartconsecutive,$z');
              }
            }
          } else {
            int odds = t - indexstartconsecutive;
            int countupcard = 0;
            for (var element in rowcard[z]) {
              if (element.face == true) {
                countupcard++;
              }
            }
            if (countupcard > odds) {
              int countdowncardT = 0;
              for (var element in rowcard[z]) {
                if (element.face == false) {
                  countdowncardT++;
                }
              }
              int indexstartconsecutiveT = countdowncardT;
              for (int j = countdowncardT; j < rowcard[z].length - 1; j++) {
                if (!((rowcard[z][j + 1].value != 11 &&
                            rowcard[z][j].value - 1 ==
                                rowcard[z][j + 1].value) ||
                        (rowcard[z][j + 1].value == 12 &&
                            rowcard[z][j].value == 0)) ||
                    (rowcard[z][j].suit != rowcard[z][j + 1].suit)) {
                  indexstartconsecutiveT = j + 1;
                }
              }
              int lenbest = rowcard[z].length - indexstartconsecutiveT;
              if (lenbest > odds) {
                if (rowcard[i].isNotEmpty &&
                    ((rowcard[i][t].value != 11 &&
                            rowcard[z].last.value - 1 == rowcard[i][t].value) ||
                        (rowcard[i][t].value == 12 &&
                            rowcard[z].last.value == 0))) {
                  if (rowcard[z].last.suit == rowcard[i].last.suit) {
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
      deckcard.removeAt(0);
      rowcard[i].last.setFace = true;
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
    if (rowcard[tempindexrow].isNotEmpty &&
        rowcard[tempindexrow].last.face == false) {
      rowcard[tempindexrow][rowcard[tempindexrow].length - 1].face = true;
    }
    if (rowcard[columnnum].isNotEmpty &&
        rowcard[columnnum].last.value == 12 &&
        rowcard[columnnum].length >= 13 &&
        rowcard[columnnum].last.face == true) {
      int flag = 1;
      int suit = rowcard[columnnum].last.suit;
      for (int i = 0; i < 12; i++) {
        if (!(rowcard[columnnum]
                        [rowcard[columnnum].length - 2 - i]
                    .value ==
                i &&
            rowcard[columnnum][rowcard[columnnum].length - 2 - i].face ==
                true &&
            rowcard[columnnum][rowcard[columnnum].length - 2 - i].suit ==
                suit)) {
          flag = 0;
          break;
        }
      }
      if (flag == 1) {
        rowcard[columnnum].removeRange(
            rowcard[columnnum].length - 13, rowcard[columnnum].length);
        if (rowcard[columnnum].isNotEmpty &&
            rowcard[columnnum].last.face == false) {
          rowcard[columnnum].last.setFace = true;
        }
        domsuit.add(suit);
      }
    }
  }
}
