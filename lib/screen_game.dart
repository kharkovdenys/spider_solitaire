import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auto_solver.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class UndoIntent extends Intent {
  const UndoIntent();
}

class RestartIntent extends Intent {
  const RestartIntent();
}

bool _isStart = false;

int typegame = 0, _gametime = 0, _gamescore = 500;

TextStyle txtstyle = const TextStyle(fontFamilyFallback: <String>['Segoe UI']);

PlayingCardViewStyle myCardStyles = const PlayingCardViewStyle();

PlayingCardViewStyle essberger = PlayingCardViewStyle(
    cardBackContentBuilder: (BuildContext context) => Image.asset(
        "asset/Essberger/back.png",
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high),
    suitStyles: {
      Suit.spades: SuitStyle(
          builder: (context) => Image.asset("asset/Essberger/spade.png",
              filterQuality: FilterQuality.high),
          cardContentBuilders: {
            CardValue.ace: (context) => Image.asset("asset/Essberger/as.png"),
            CardValue.jack: (context) => Image.asset("asset/Essberger/js.png"),
            CardValue.queen: (context) => Image.asset("asset/Essberger/qs.png"),
            CardValue.king: (context) => Image.asset("asset/Essberger/ks.png"),
          }),
      Suit.hearts: SuitStyle(
          builder: (context) => Image.asset("asset/Essberger/heart.png",
              filterQuality: FilterQuality.high),
          cardContentBuilders: {
            CardValue.jack: (context) => Image.asset("asset/Essberger/jh.png"),
            CardValue.queen: (context) => Image.asset("asset/Essberger/qh.png"),
            CardValue.king: (context) => Image.asset("asset/Essberger/kh.png"),
          }),
      Suit.diamonds: SuitStyle(
          builder: (context) => Image.asset("asset/Essberger/diamond.png",
              filterQuality: FilterQuality.high),
          cardContentBuilders: {
            CardValue.jack: (context) => Image.asset("asset/Essberger/jd.png"),
            CardValue.queen: (context) => Image.asset("asset/Essberger/qd.png"),
            CardValue.king: (context) => Image.asset("asset/Essberger/kd.png"),
          }),
      Suit.clubs: SuitStyle(
          builder: (context) => Image.asset("asset/Essberger/club.png",
              filterQuality: FilterQuality.high),
          cardContentBuilders: {
            CardValue.jack: (context) => Image.asset("asset/Essberger/jc.png"),
            CardValue.queen: (context) => Image.asset("asset/Essberger/qc.png"),
            CardValue.king: (context) => Image.asset("asset/Essberger/kc.png"),
          })
    });
List<List<int>> rowcard = [], rowsuit = [];
List<List<bool>> rowcardFace = [];
List<int> deckcard = [], deckcardsuit = [], domsuit = [];
List<Container> deck = [];

class _GameScreenState extends State<GameScreen> {
  Timer? timer;
  List<Widget> column1 = [],
      column2 = [],
      column3 = [],
      column4 = [],
      column5 = [],
      column6 = [],
      column7 = [],
      column8 = [],
      column9 = [],
      column10 = [];
  List<Container> dom = [];
  List<int> columncard1 = [],
      columncard2 = [],
      columncard3 = [],
      columncard4 = [],
      columncard5 = [],
      columncard6 = [],
      columncard7 = [],
      columncard8 = [],
      columncard9 = [],
      columncard10 = [],
      columncardsuit1 = [],
      columncardsuit2 = [],
      columncardsuit3 = [],
      columncardsuit4 = [],
      columncardsuit5 = [],
      columncardsuit6 = [],
      columncardsuit7 = [],
      columncardsuit8 = [],
      columncardsuit9 = [],
      columncardsuit10 = [];
  List<bool> columncardFace1 = [],
      columncardFace2 = [],
      columncardFace3 = [],
      columncardFace4 = [],
      columncardFace5 = [],
      columncardFace6 = [],
      columncardFace7 = [],
      columncardFace8 = [],
      columncardFace9 = [],
      columncardFace10 = [];
  List<List<Widget>> row = [];
  List<String> history = [], historyToWin = [];

  @override
  Widget build(BuildContext context) {
    void desingCard() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String design = (prefs.getString('design') ?? 'Default');
      if (design == 'Essberger') {
        myCardStyles = essberger;
      } else {
        myCardStyles = const PlayingCardViewStyle();
      }
    }

    startTimer() {
      timer = Timer.periodic(
          const Duration(seconds: 1), (_) => setState(() => _gametime++));
    }

    stopTimer() {
      setState(() => timer?.cancel());
    }

    Random random = Random();
    Size screenSize = MediaQuery.of(context).size;
    var faceBack = PlayingCardView(
        card: PlayingCard(Suit.spades, CardValue.ace),
        showBack: true,
        style: myCardStyles);

    win() {
      stopTimer();
      rerecords(_gametime, _gamescore);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Congratulations!"),
            content: Text(
                'You won!\nTime: ${((_gametime / 60).truncate()).toString().padLeft(2, '0')}:${(_gametime % 60).toString().padLeft(2, '0')}\nScore: $_gamescore'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  _isStart = false;
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text("Start again"),
              ),
            ],
          );
        },
      );
    }

    addUsedCards(int domssuit) {
      _gamescore += 100;
      domsuit.add(domssuit);
      dom.add(Container(
          margin:
              EdgeInsets.only(left: screenSize.width / 56 * (dom.length - 1)),
          width: screenSize.width / 12,
          child: PlayingCardView(
              card: PlayingCard(Suit.values[domssuit], CardValue.king),
              style: myCardStyles)));
      if (dom.length == 9) {
        win();
      }
      setState(() {});
    }

    rebuilddeck() {
      int tempcountdeck = deck.length;
      deck = [Container(width: screenSize.width / 12)];
      for (int i = 1; i < tempcountdeck; i++) {
        deck.add(Container(
            margin: EdgeInsets.only(left: screenSize.width / 48 * (i - 1)),
            width: screenSize.width / 12,
            child: PlayingCardView(
                card: PlayingCard(Suit.spades, CardValue.ace),
                showBack: true,
                style: myCardStyles)));
      }
    }

    rebuilddom() {
      int tempcountdom = domsuit.length;
      dom = [Container()];
      for (int i = 0; i < tempcountdom; i++) {
        dom.add(Container(
            margin:
                EdgeInsets.only(left: screenSize.width / 56 * (dom.length - 1)),
            width: screenSize.width / 12,
            child: PlayingCardView(
                card: PlayingCard(Suit.values[domsuit[i]], CardValue.king),
                style: myCardStyles)));
      }
    }

    rebuildcolumn(int columnnum) {
      row[columnnum].clear();
      if (rowcard[columnnum].isNotEmpty &&
          rowcard[columnnum].last == 12 &&
          rowcard[columnnum].length >= 13 &&
          rowcardFace[columnnum].last == true) {
        int flag = 1;
        int suit = rowsuit[columnnum].last;
        for (int i = 0; i < 12; i++) {
          if (!(rowcard[columnnum][rowcard[columnnum].length - 2 - i] == i &&
              rowcardFace[columnnum][rowcard[columnnum].length - 2 - i] ==
                  true &&
              rowsuit[columnnum][rowcard[columnnum].length - 2 - i] == suit)) {
            flag = 0;
            break;
          }
        }
        if (flag == 1) {
          String tempdomhistory = history.last;
          history.removeLast();
          tempdomhistory = '3${tempdomhistory.substring(1)}';
          tempdomhistory += ",$suit";
          rowcard[columnnum].removeRange(
              rowcard[columnnum].length - 13, rowcard[columnnum].length);
          rowcardFace[columnnum].removeRange(rowcardFace[columnnum].length - 13,
              rowcardFace[columnnum].length);
          rowsuit[columnnum].removeRange(
              rowsuit[columnnum].length - 13, rowsuit[columnnum].length);
          if (rowcardFace[columnnum].isNotEmpty) {
            if (rowcardFace[columnnum].last == false) {
              rowcardFace[columnnum].removeLast();
              rowcardFace[columnnum].add(true);
              tempdomhistory += ",1";
            } else {
              tempdomhistory += ",0";
            }
          } else {
            tempdomhistory += ",0";
          }
          history.add(tempdomhistory);
          addUsedCards(suit);
        }
      }
      int countdowncard = 0;
      for (var element in rowcardFace[columnnum]) {
        if (element == false) {
          countdowncard++;
        }
      }

      int indexstartconsecutive = countdowncard;
      PlayingCardView facedowncard = PlayingCardView(
          card: PlayingCard(Suit.spades, CardValue.jack),
          showBack: true,
          style: myCardStyles);
      for (int i = 0; i < countdowncard; i++) {
        EdgeInsetsGeometry temppadding =
            EdgeInsets.only(top: screenSize.height / 28 * i);
        Draggable facedown = Draggable(
            feedback: Container(
                width: screenSize.width / 12,
                padding: temppadding,
                child: facedowncard),
            childWhenDragging: Container(width: screenSize.width / 12),
            maxSimultaneousDrags: 0,
            child: Container(
                width: screenSize.width / 12,
                padding: temppadding,
                child: facedowncard));
        row[columnnum].add(facedown);
      }
      for (int i = countdowncard; i < rowcard[columnnum].length - 1; i++) {
        if (!((rowcard[columnnum][i + 1] != 11 &&
                    rowcard[columnnum][i] - 1 == rowcard[columnnum][i + 1]) ||
                (rowcard[columnnum][i + 1] == 12 &&
                    rowcard[columnnum][i] == 0)) ||
            (rowsuit[columnnum][i] != rowsuit[columnnum][i + 1])) {
          indexstartconsecutive = i + 1;
        }
      }
      EdgeInsetsGeometry temppadding;
      for (int i = countdowncard; i < indexstartconsecutive; i++) {
        temppadding = EdgeInsets.only(top: screenSize.height / 28 * i);
        CardValue tempCardValue = CardValue.values[rowcard[columnnum][i]];
        PlayingCardView faceupcard = PlayingCardView(
            card:
                PlayingCard(Suit.values[rowsuit[columnnum][i]], tempCardValue),
            style: myCardStyles);
        row[columnnum].add(Draggable(
            feedback: Container(
                width: screenSize.width / 12,
                padding: temppadding,
                child: faceupcard),
            childWhenDragging: Container(width: screenSize.width / 12),
            maxSimultaneousDrags: 0,
            child: Container(
                width: screenSize.width / 12,
                padding: temppadding,
                child: faceupcard)));
      }
      if (rowcard[columnnum].isNotEmpty) {
        temppadding = EdgeInsets.only(
            top: screenSize.height / 28 * (rowcard[columnnum].length - 1));
        CardValue tempCardValue =
            CardValue.values[rowcard[columnnum][rowcard[columnnum].length - 1]];
        PlayingCardView faceupcard = PlayingCardView(
            card: PlayingCard(
                Suit.values[rowsuit[columnnum][rowsuit[columnnum].length - 1]],
                tempCardValue),
            style: myCardStyles);
        Draggable tempdrag = Draggable(
            feedback: Container(
                width: screenSize.width / 12,
                padding: temppadding,
                child: faceupcard),
            childWhenDragging: Container(width: screenSize.width / 12),
            maxSimultaneousDrags: 1,
            data:
                "$columnnum,${rowcard[columnnum][rowcard[columnnum].length - 1]},${rowcard[columnnum].length - 1}",
            child: Container(
                width: screenSize.width / 12,
                padding: temppadding,
                child: faceupcard));

        for (int i = rowcard[columnnum].length - 2;
            i >= indexstartconsecutive;
            i--) {
          temppadding = EdgeInsets.only(top: screenSize.height / 28 * i);
          CardValue tempCardValue = CardValue.values[rowcard[columnnum][i]];
          PlayingCardView faceupcard = PlayingCardView(
              card: PlayingCard(
                  Suit.values[rowsuit[columnnum][i]], tempCardValue),
              style: myCardStyles);
          tempdrag = Draggable(
              feedback: Stack(children: [
                Container(
                    width: screenSize.width / 12,
                    padding: temppadding,
                    child: faceupcard),
                tempdrag
              ]),
              childWhenDragging: Container(width: screenSize.width / 12),
              maxSimultaneousDrags: 1,
              data: "$columnnum,${rowcard[columnnum][i]},$i",
              child: Stack(children: [
                Container(
                    width: screenSize.width / 12,
                    padding: temppadding,
                    child: faceupcard),
                tempdrag
              ]));
        }
        row[columnnum].add(tempdrag);
      }
      Container tempContainer;
      if (rowcard[columnnum].isEmpty) {
        tempContainer = Container(
            width: screenSize.width / 12,
            height: screenSize.width / 7560 * 880,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.black,
                  width: screenSize.width / 1000,
                )));
      } else {
        temppadding = EdgeInsets.only(
            top: screenSize.height / 30 * (rowcard[columnnum].length - 1));
        tempContainer = Container(
            width: screenSize.width / 12,
            height: screenSize.width / 7560 * 880,
            margin: temppadding);
      }
      DragTarget temptag = DragTarget(builder: (BuildContext context,
          List<Object?> candidateData, List<dynamic> rejectedData) {
        return tempContainer;
      }, onWillAccept: (data) {
        List<String> tempdata = data.toString().split(",");
        int tempvarcard = int.parse(tempdata[1]);
        if (rowcard[columnnum].isEmpty ||
            (tempdata[0] != columnnum.toString() &&
                (tempvarcard != 11 &&
                    rowcard[columnnum].last - 1 == tempvarcard)) ||
            (tempvarcard == 12 && rowcard[columnnum].last == 0)) {
          return true;
        } else {
          return false;
        }
      }, onAccept: (data) {
        List<String> tempdata = data.toString().split(",");
        int tempindexstart = int.parse(tempdata[2]),
            tempindexrow = int.parse(tempdata[0]);
        String templength = rowcard[columnnum].length.toString();
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
          rowcardFace[tempindexrow][rowcardFace[tempindexrow].length - 1] =
              true;
          history.add("2,$tempindexrow,$columnnum,$templength,1");
        } else {
          history.add("2,$tempindexrow,$columnnum,$templength,0");
        }
        _gamescore--;
        rebuildcolumn(columnnum);
        rebuildcolumn(int.parse(tempdata[0]));
      });
      row[columnnum].add(temptag);
      setState(() {});
    }

    if (_isStart == false) {
      iter = true;
      desingCard();
      _gamescore = 500;
      _gametime = 0;
      startTimer();
      history.clear();
      domsuit.clear();
      dom = [Container()];
      deck = [
        Container(width: screenSize.width / 12), //empty container
        Container(
            margin: EdgeInsets.zero,
            width: screenSize.width / 12,
            child: faceBack),
        Container(
            margin: EdgeInsets.only(left: screenSize.width / 48),
            width: screenSize.width / 12,
            child: faceBack),
        Container(
            margin: EdgeInsets.only(left: screenSize.width / 48 * 2),
            width: screenSize.width / 12,
            child: faceBack),
        Container(
            margin: EdgeInsets.only(left: screenSize.width / 48 * 3),
            width: screenSize.width / 12,
            child: faceBack),
        Container(
            margin: EdgeInsets.only(left: screenSize.width / 48 * 4),
            width: screenSize.width / 12,
            child: faceBack),
      ];
      row = [
        column1,
        column2,
        column3,
        column4,
        column5,
        column6,
        column7,
        column8,
        column9,
        column10
      ];
      List<int> allCard = [];
      List<int> allCardSuit = [];
      deckcard.clear();
      deckcardsuit.clear();
      int tempsuit = 0;
      for (int i = 0; i < 8; i++) {
        if (typegame == 1) {
          tempsuit = i % 2;
        } else if (typegame == 2) {
          tempsuit = i % 4;
        }
        for (int j = 0; j < 13; j++) {
          allCard.add(j);
          allCardSuit.add(tempsuit);
        }
      }
      rowcard = [
        columncard1,
        columncard2,
        columncard3,
        columncard4,
        columncard5,
        columncard6,
        columncard7,
        columncard8,
        columncard9,
        columncard10
      ];
      rowcardFace = [
        columncardFace1,
        columncardFace2,
        columncardFace3,
        columncardFace4,
        columncardFace5,
        columncardFace6,
        columncardFace7,
        columncardFace8,
        columncardFace9,
        columncardFace10
      ];
      rowsuit = [
        columncardsuit1,
        columncardsuit2,
        columncardsuit3,
        columncardsuit4,
        columncardsuit5,
        columncardsuit6,
        columncardsuit7,
        columncardsuit8,
        columncardsuit9,
        columncardsuit10
      ];
      for (int i = 0; i < 10; i++) {
        row[i].clear();
        rowcard[i].clear();
        rowcardFace[i].clear();
        rowsuit[i].clear();
      }
      int randIndex = 0;
      for (int i = 0; i < 10; i++) {
        if (i < 4) {
          for (int j = 0; j < 6; j++) {
            randIndex = random.nextInt(allCard.length);
            rowcard[i].add(allCard[randIndex]);
            rowsuit[i].add(allCardSuit[randIndex]);
            allCard.removeAt(randIndex);
            allCardSuit.removeAt(randIndex);
            if (j == 5) {
              rowcardFace[i].add(true);
            } else {
              rowcardFace[i].add(false);
            }
          }
        } else {
          for (int j = 0; j < 5; j++) {
            randIndex = random.nextInt(allCard.length);
            rowcard[i].add(allCard[randIndex]);
            rowsuit[i].add(allCardSuit[randIndex]);
            allCard.removeAt(randIndex);
            allCardSuit.removeAt(randIndex);
            if (j == 4) {
              rowcardFace[i].add(true);
            } else {
              rowcardFace[i].add(false);
            }
          }
        }
      }
      while (allCard.isNotEmpty) {
        randIndex = random.nextInt(allCard.length);
        deckcard.add(allCard[randIndex]);
        deckcardsuit.add(allCardSuit[randIndex]);
        allCard.removeAt(randIndex);
        allCardSuit.removeAt(randIndex);
      }
      for (int i = 0; i < 10; i++) {
        rebuildcolumn(i);
      }
      _isStart = true;
      Future.delayed(const Duration(milliseconds: 50), () {
        rebuilddeck();
        rebuilddom();
        for (int i = 0; i < 10; i++) {
          rebuildcolumn(i);
        }
      });
    }
    addCard() {
      if (columncard1.isNotEmpty &
          columncard2.isNotEmpty &
          columncard3.isNotEmpty &
          columncard4.isNotEmpty &
          columncard5.isNotEmpty &
          columncard6.isNotEmpty &
          columncard7.isNotEmpty &
          columncard8.isNotEmpty &
          columncard9.isNotEmpty &
          columncard10.isNotEmpty) {
        for (int i = 0; i < 10; i++) {
          rowcard[i].add(deckcard.first);
          rowsuit[i].add(deckcardsuit.first);
          deckcard.removeAt(0);
          deckcardsuit.removeAt(0);
          rowcardFace[i].add(true);
          rebuildcolumn(i);
        }
        deck.removeLast();
        history.add("1");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Columns should not be empty"),
        ));
      }
      setState(() {});
    }

    backactions() {
      if (history.isNotEmpty) {
        String historyStr = history.last;
        if (historyStr == "1") {
          _gamescore--;
          for (int i = 9; i >= 0; i--) {
            deckcard.insert(0, rowcard[i].last);
            deckcardsuit.insert(0, rowsuit[i].last);
            rowcard[i].removeLast();
            rowsuit[i].removeLast();
            rowcardFace[i].removeLast();
            rebuildcolumn(i);
          }
          deck.add(Container(
              margin: EdgeInsets.only(
                  left: screenSize.width / 48 * (deck.length - 1)),
              width: screenSize.width / 12,
              child: faceBack));
          history.removeLast();
        } else {
          _gamescore--;
          List<String> tempdata = historyStr.toString().split(",");
          int index1 = int.parse(tempdata[1]),
              index2 = int.parse(tempdata[2]),
              indexstart = int.parse(tempdata[3]);
          if (historyStr[0] == "3") {
            _gamescore -= 100;
            int tempsuitdom = int.parse(tempdata[5]);
            dom.removeLast();
            domsuit.removeLast();
            if (rowcardFace[index2].isNotEmpty && tempdata[6] == "1") {
              rowcardFace[index2].removeLast();
              rowcardFace[index2].add(false);
            }
            for (int i = 11; i >= 0; i--) {
              rowcard[index2].add(i);
              rowcardFace[index2].add(true);
              rowsuit[index2].add(tempsuitdom);
            }
            rowcard[index2].add(12);
            rowcardFace[index2].add(true);
            rowsuit[index2].add(tempsuitdom);
          }
          rowcard[index1].addAll(
              rowcard[index2].getRange(indexstart, rowcard[index2].length));
          rowcard[index2].removeRange(indexstart, rowcard[index2].length);
          rowsuit[index1].addAll(
              rowsuit[index2].getRange(indexstart, rowsuit[index2].length));
          rowsuit[index2].removeRange(indexstart, rowsuit[index2].length);
          if (tempdata[4] == "1") {
            rowcardFace[index1][rowcardFace[index1].length - 1] = false;
          }
          rowcardFace[index1].addAll(rowcardFace[index2]
              .getRange(indexstart, rowcardFace[index2].length));
          rowcardFace[index2]
              .removeRange(indexstart, rowcardFace[index2].length);
          rebuildcolumn(index1);
          rebuildcolumn(index2);
          history.removeLast();
        }
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("The history is empty"),
        ));
      }
    }

    solver() async {
      if (typegame == 0) {
        iter = false;
        stateGame();
        while (!iter) {
          await Future.delayed(const Duration(milliseconds: 10), () {
            rebuilddeck();
            rebuilddom();
            for (int i = 0; i < 10; i++) {
              rebuildcolumn(i);
            }
          });
          await Future.delayed(const Duration(milliseconds: 100), () {
            rebuilddeck();
            rebuilddom();
            for (int i = 0; i < 10; i++) {
              rebuildcolumn(i);
            }
          });
        }
      }
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
                      desingCard();
                      Navigator.pop(context);
                      Future.delayed(const Duration(milliseconds: 100), () {
                        rebuilddeck();
                        rebuilddom();
                        for (int i = 0; i < 10; i++) {
                          rebuildcolumn(i);
                        }
                      });
                    },
                    child: const Text("Save"),
                  ),
                ],
              );
            });
          });
    }

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

    restart() {
      showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Center(child: Text("Choice of difficulty level")),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  typegame = 0;
                  _isStart = false;
                  stopTimer();
                  Navigator.pushReplacementNamed(context, '/game');
                },
                child: Center(child: Text('One suit ♠', style: txtstyle)),
              ),
              SimpleDialogOption(
                onPressed: () {
                  typegame = 1;
                  _isStart = false;
                  stopTimer();
                  Navigator.pushReplacementNamed(context, '/game');
                },
                child: Center(child: Text('Two suits ♠ ♥', style: txtstyle)),
              ),
              SimpleDialogOption(
                onPressed: () {
                  typegame = 2;
                  _isStart = false;
                  stopTimer();
                  Navigator.pushReplacementNamed(context, '/game');
                },
                child: Center(
                    child: Text('Four suits ♠ ♥ ♣ ♦', style: txtstyle)),
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
          );
        },
      );
    }

    return NotificationListener(
        onNotification: (SizeChangedLayoutNotification notification) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            rebuilddeck();
            rebuilddom();
            for (int i = 0; i < 10; i++) {
              rebuildcolumn(i);
            }
          });
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
                child: Actions(
                    actions: <Type, Action<Intent>>{
                      UndoIntent: CallbackAction<UndoIntent>(
                        onInvoke: (UndoIntent intent) => backactions(),
                      ),
                      RestartIntent: CallbackAction<RestartIntent>(
                          onInvoke: (RestartIntent intent) => restart())
                    },
                    child: Focus(
                        autofocus: true,
                        child: Scaffold(
                            backgroundColor: const Color(0xFF4CAF50),
                            body: Column(children: [
                              SizedBox(
                                  height: screenSize.height / 4 * 3,
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(children: column1),
                                        SizedBox(width: screenSize.width / 54),
                                        Stack(children: column2),
                                        SizedBox(width: screenSize.width / 54),
                                        Stack(children: column3),
                                        SizedBox(width: screenSize.width / 54),
                                        Stack(children: column4),
                                        SizedBox(width: screenSize.width / 54),
                                        Stack(children: column5),
                                        SizedBox(width: screenSize.width / 54),
                                        Stack(children: column6),
                                        SizedBox(width: screenSize.width / 54),
                                        Stack(children: column7),
                                        SizedBox(width: screenSize.width / 54),
                                        Stack(children: column8),
                                        SizedBox(width: screenSize.width / 54),
                                        Stack(children: column9),
                                        SizedBox(width: screenSize.width / 54),
                                        Stack(children: column10)
                                      ])),
                              Row(children: [
                                SizedBox(
                                    width: screenSize.width / 12 * 1,
                                    height: screenSize.height / 4,
                                    child: Column(children: [
                                      SizedBox(height: screenSize.height / 28),
                                      SizedBox(
                                          height: screenSize.height / 14,
                                          child: ElevatedButton(
                                            child: Icon(Icons.arrow_back,
                                                size: screenSize.height / 14),
                                            onPressed: () {
                                              backactions();
                                            },
                                          )),
                                      SizedBox(height: screenSize.height / 28),
                                      SizedBox(
                                          height: screenSize.height / 14,
                                          child: ElevatedButton(
                                            child: Icon(Icons.refresh_sharp,
                                                size: screenSize.height / 14),
                                            onPressed: () {
                                              restart();
                                            },
                                          )),
                                      SizedBox(height: screenSize.height / 28)
                                    ])),
                                SizedBox(width: screenSize.width / 12 * 1),
                                SizedBox(
                                    width: screenSize.width / 12 * 3,
                                    child: Stack(children: dom)),
                                GestureDetector(
                                    onTap: solver,
                                    child: Container(
                                        width: screenSize.width / 12 * 2,
                                        height: screenSize.height / 4,
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF095912),
                                            border: Border.all(
                                              color: Colors.black,
                                              width: screenSize.width / 1000,
                                            )),
                                        child: Center(
                                            child: Text(
                                                'Time: ${((_gametime / 60).truncate()).toString().padLeft(2, '0')}:${(_gametime % 60).toString().padLeft(2, '0')}\nScore: $_gamescore',
                                                style: const TextStyle(
                                                    color: Color(0xFFFFFFFF)))))),
                                SizedBox(width: screenSize.width / 12 * 2),
                                SizedBox(
                                    width: screenSize.width / 12 * 3,
                                    child: GestureDetector(
                                        onTap: addCard,
                                        child: Stack(children: deck)))
                              ])
                            ])))))));
  }

  void rerecords(int gametime, int gamescore) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (typegame == 0) {
      int timesuitone = (prefs.getInt('timesuitone') ?? -1);
      int scoresuitone = (prefs.getInt('scoresuitone') ?? 0);
      if (timesuitone == -1) {
        await prefs.setInt('timesuitone', gametime);
        await prefs.setInt('scoresuitone', gamescore);
      } else {
        if (timesuitone > gametime) {
          await prefs.setInt('timesuitone', gametime);
        }
        if (scoresuitone < gamescore) {
          await prefs.setInt('scoresuitone', gamescore);
        }
      }
    } else if (typegame == 1) {
      int timesuittwo = (prefs.getInt('timesuittwo') ?? -1);
      int scoresuittwo = (prefs.getInt('scoresuittwo') ?? 0);
      if (timesuittwo == -1) {
        await prefs.setInt('timesuittwo', gametime);
        await prefs.setInt('scoresuittwo', gamescore);
      } else {
        if (timesuittwo > gametime) {
          await prefs.setInt('timesuittwo', gametime);
        }
        if (scoresuittwo < gamescore) {
          await prefs.setInt('scoresuittwo', gamescore);
        }
      }
    } else {
      int timesuitfour = (prefs.getInt('timesuitfour') ?? -1);
      int scoresuitfour = (prefs.getInt('scoresuitfour') ?? 0);
      if (timesuitfour == -1) {
        await prefs.setInt('timesuitfour', gametime);
        await prefs.setInt('scoresuitfour', gamescore);
      } else {
        if (timesuitfour > gametime) {
          await prefs.setInt('timesuitfour', gametime);
        }
        if (scoresuitfour < gamescore) {
          await prefs.setInt('scoresuitfour', gamescore);
        }
      }
    }
  }
}
