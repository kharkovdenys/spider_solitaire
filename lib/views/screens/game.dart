import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spider_solitaire/views/widgets/menu.dart';
import 'package:spider_solitaire/views/widgets/records.dart';
import 'package:spider_solitaire/services/auto_solver.dart';
import 'package:spider_solitaire/services/constants.dart';
import 'package:spider_solitaire/views/widgets/shortcuts.dart';
import 'package:spider_solitaire/views/widgets/victory.dart';
import 'package:spider_solitaire/classes/gamecard.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

bool _isStart = false;

int typegame = 0, _gametime = 0, _gamescore = 500;

PlayingCardViewStyle myCardStyles = const PlayingCardViewStyle();

List<List<GameCard>> rowcard = [];
List<GameCard> deckcard = [];
List<int> domsuit = [];
List<Container> deck = [];

Timer? _timer;

class _GameScreenState extends State<GameScreen> {
  List<Container> dom = [];
  List<List<Widget>> row = [];
  List<String> history = [];

  @override
  void initState() {
    super.initState();
    _isStart = false;
  }

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
      _timer = Timer.periodic(
          const Duration(seconds: 1), (_) => setState(() => _gametime++));
    }

    stopTimer() {
      _timer?.cancel();
    }

    Random random = Random();
    Size screenSize = MediaQuery.of(context).size;
    PlayingCardView faceBack = PlayingCardView(
        card: PlayingCard(Suit.spades, CardValue.ace),
        showBack: true,
        style: myCardStyles);
    double cardWidth = screenSize.width / 12;

    victory() {
      stopTimer();
      reRecords(_gametime, _gamescore, typegame);
      victoryDialog(context, _gametime, _gamescore, {
        setState(() {
          _isStart = false;
        })
      });
    }

    addUsedCards(int domssuit) {
      _gamescore += 100;
      domsuit.add(domssuit);
      dom.add(Container(
          margin:
              EdgeInsets.only(left: screenSize.width / 56 * (dom.length - 1)),
          width: cardWidth,
          child: PlayingCardView(
              card: PlayingCard(Suit.values[domssuit], CardValue.king),
              style: myCardStyles)));
      if (dom.length == 9) {
        victory();
      }
      setState(() {});
    }

    rebuilddeck() {
      int tempcountdeck = deck.length;
      deck = [Container(width: cardWidth)];
      for (int i = 1; i < tempcountdeck; i++) {
        deck.add(Container(
            margin: EdgeInsets.only(left: screenSize.width / 48 * (i - 1)),
            width: cardWidth,
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
            width: cardWidth,
            child: PlayingCardView(
                card: PlayingCard(Suit.values[domsuit[i]], CardValue.king),
                style: myCardStyles)));
      }
    }

    rebuildcolumn(int columnnum) {
      row[columnnum].clear();
      if (rowcard[columnnum].isNotEmpty &&
          rowcard[columnnum].last.value == 12 &&
          rowcard[columnnum].length >= 13 &&
          rowcard[columnnum].last.face == true) {
        int flag = 1;
        int suit = rowcard[columnnum].last.suit;
        for (int i = 0; i < 12; i++) {
          if (rowcard[columnnum][rowcard[columnnum].length - 2 - i] !=
              GameCard(i, suit, true)) {
            flag = 0;
            break;
          }
        }
        if (flag == 1) {
          String tempdomhistory = history.last;
          history.removeLast();
          tempdomhistory = '3${tempdomhistory.substring(1)},$suit';
          rowcard[columnnum].removeRange(
              rowcard[columnnum].length - 13, rowcard[columnnum].length);
          if (rowcard[columnnum].isNotEmpty) {
            if (rowcard[columnnum].last.face == false) {
              rowcard[columnnum].last.setFace = true;
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
      for (var element in rowcard[columnnum]) {
        if (element.face == false) {
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
                width: cardWidth, padding: temppadding, child: facedowncard),
            childWhenDragging: Container(width: cardWidth),
            maxSimultaneousDrags: 0,
            child: Container(
                width: cardWidth, padding: temppadding, child: facedowncard));
        row[columnnum].add(facedown);
      }
      for (int i = countdowncard; i < rowcard[columnnum].length - 1; i++) {
        if (!((rowcard[columnnum][i + 1].value != 11 &&
                    rowcard[columnnum][i].value - 1 ==
                        rowcard[columnnum][i + 1].value) ||
                (rowcard[columnnum][i + 1].value == 12 &&
                    rowcard[columnnum][i].value == 0)) ||
            (rowcard[columnnum][i].suit != rowcard[columnnum][i + 1].suit)) {
          indexstartconsecutive = i + 1;
        }
      }
      EdgeInsetsGeometry temppadding;
      for (int i = countdowncard; i < indexstartconsecutive; i++) {
        temppadding = EdgeInsets.only(top: screenSize.height / 28 * i);
        CardValue tempCardValue = CardValue.values[rowcard[columnnum][i].value];
        PlayingCardView faceupcard = PlayingCardView(
            card: PlayingCard(
                Suit.values[rowcard[columnnum][i].suit], tempCardValue),
            style: myCardStyles);
        row[columnnum].add(Draggable(
            feedback: Container(
                width: cardWidth, padding: temppadding, child: faceupcard),
            childWhenDragging: Container(width: cardWidth),
            maxSimultaneousDrags: 0,
            child: Container(
                width: cardWidth, padding: temppadding, child: faceupcard)));
      }
      if (rowcard[columnnum].isNotEmpty) {
        temppadding = EdgeInsets.only(
            top: screenSize.height / 28 * (rowcard[columnnum].length - 1));
        CardValue tempCardValue = CardValue
            .values[rowcard[columnnum][rowcard[columnnum].length - 1].value];
        PlayingCardView faceupcard = PlayingCardView(
            card: PlayingCard(
                Suit.values[
                    rowcard[columnnum][rowcard[columnnum].length - 1].suit],
                tempCardValue),
            style: myCardStyles);
        Draggable tempdrag = Draggable(
            feedback: Container(
                width: cardWidth, padding: temppadding, child: faceupcard),
            childWhenDragging: Container(width: cardWidth),
            maxSimultaneousDrags: 1,
            data:
                "$columnnum,${rowcard[columnnum][rowcard[columnnum].length - 1].value},${rowcard[columnnum].length - 1}",
            child: Container(
                width: cardWidth, padding: temppadding, child: faceupcard));

        for (int i = rowcard[columnnum].length - 2;
            i >= indexstartconsecutive;
            i--) {
          temppadding = EdgeInsets.only(top: screenSize.height / 28 * i);
          CardValue tempCardValue =
              CardValue.values[rowcard[columnnum][i].value];
          PlayingCardView faceupcard = PlayingCardView(
              card: PlayingCard(
                  Suit.values[rowcard[columnnum][i].suit], tempCardValue),
              style: myCardStyles);
          tempdrag = Draggable(
              feedback: Stack(children: [
                Container(
                    width: cardWidth, padding: temppadding, child: faceupcard),
                tempdrag
              ]),
              childWhenDragging: Container(width: cardWidth),
              maxSimultaneousDrags: 1,
              data: "$columnnum,${rowcard[columnnum][i].value},$i",
              child: Stack(children: [
                Container(
                    width: cardWidth, padding: temppadding, child: faceupcard),
                tempdrag
              ]));
        }
        row[columnnum].add(tempdrag);
      }
      Container tempContainer;
      if (rowcard[columnnum].isEmpty) {
        tempContainer = Container(
            width: cardWidth,
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
            width: cardWidth,
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
                    rowcard[columnnum].last.value - 1 == tempvarcard)) ||
            (tempvarcard == 12 && rowcard[columnnum].last.value == 0)) {
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
        if (rowcard[tempindexrow].isNotEmpty &&
            rowcard[tempindexrow].last.face == false) {
          rowcard[tempindexrow][rowcard[tempindexrow].length - 1].face = true;
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
      stopTimer();
      startTimer();
      history.clear();
      domsuit.clear();
      dom = [Container()];
      deck = [
        Container(width: cardWidth), //empty container
        Container(margin: EdgeInsets.zero, width: cardWidth, child: faceBack),
        Container(
            margin: EdgeInsets.only(left: screenSize.width / 48),
            width: cardWidth,
            child: faceBack),
        Container(
            margin: EdgeInsets.only(left: screenSize.width / 48 * 2),
            width: cardWidth,
            child: faceBack),
        Container(
            margin: EdgeInsets.only(left: screenSize.width / 48 * 3),
            width: cardWidth,
            child: faceBack),
        Container(
            margin: EdgeInsets.only(left: screenSize.width / 48 * 4),
            width: cardWidth,
            child: faceBack),
      ];
      for (int i = 0; i < 10; i++) {
        row.add([]);
      }
      List<GameCard> allCard = [];
      deckcard.clear();
      int tempsuit = 0;
      for (int i = 0; i < 8; i++) {
        if (typegame == 1) {
          tempsuit = i % 2;
        } else if (typegame == 2) {
          tempsuit = i % 4;
        }
        for (int j = 0; j < 13; j++) {
          allCard.add(GameCard(j, tempsuit, false));
        }
      }
      for (int i = 0; i < 10; i++) {
        rowcard.add([]);
      }
      for (int i = 0; i < 10; i++) {
        row[i].clear();
        rowcard[i].clear();
      }
      int randIndex = 0;
      for (int i = 0; i < 10; i++) {
        if (i < 4) {
          for (int j = 0; j < 6; j++) {
            randIndex = random.nextInt(allCard.length);
            rowcard[i].add(allCard[randIndex]);
            allCard.removeAt(randIndex);
            if (j == 5) {
              rowcard[i].last.setFace = true;
            }
          }
        } else {
          for (int j = 0; j < 5; j++) {
            randIndex = random.nextInt(allCard.length);
            rowcard[i].add(allCard[randIndex]);
            allCard.removeAt(randIndex);
            if (j == 4) {
              rowcard[i].last.setFace = true;
            }
          }
        }
      }
      while (allCard.isNotEmpty) {
        randIndex = random.nextInt(allCard.length);
        deckcard.add(allCard[randIndex]);
        allCard.removeAt(randIndex);
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
      if (rowcard[0].isNotEmpty &&
          rowcard[1].isNotEmpty &&
          rowcard[2].isNotEmpty &&
          rowcard[3].isNotEmpty &&
          rowcard[4].isNotEmpty &&
          rowcard[5].isNotEmpty &&
          rowcard[6].isNotEmpty &&
          rowcard[7].isNotEmpty &&
          rowcard[8].isNotEmpty &&
          rowcard[9].isNotEmpty) {
        for (int i = 0; i < 10; i++) {
          rowcard[i].add(deckcard.first);
          deckcard.removeAt(0);
          rowcard[i].last.setFace = true;
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
            rowcard[i].removeLast();
            rebuildcolumn(i);
          }
          deck.add(Container(
              margin: EdgeInsets.only(
                  left: screenSize.width / 48 * (deck.length - 1)),
              width: cardWidth,
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
            if (rowcard[index2].isNotEmpty && tempdata[6] == "1") {
              rowcard[index2].last.setFace = false;
            }
            for (int i = 11; i >= 0; i--) {
              rowcard[index2].add(GameCard(i, tempsuitdom, true));
            }
            rowcard[index2].add(GameCard(12, tempsuitdom, true));
          }
          if (tempdata[4] == "1") {
            rowcard[index1][rowcard[index1].length - 1].setFace = false;
          }
          rowcard[index1].addAll(
              rowcard[index2].getRange(indexstart, rowcard[index2].length));
          rowcard[index2].removeRange(indexstart, rowcard[index2].length);
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
          await Future.delayed(const Duration(milliseconds: 50), () {
            rebuilddeck();
            rebuilddom();
            for (int i = 0; i < 10; i++) {
              rebuildcolumn(i);
            }
          });
        }
      }
    }

    restart() {
      showDialog(
        context: context,
        builder: (context) {
          return Menu(
              desingCard: desingCard,
              update: () {
                Future.delayed(const Duration(milliseconds: 100), () {
                  rebuilddeck();
                  rebuilddom();
                  for (int i = 0; i < 10; i++) {
                    rebuildcolumn(i);
                  }
                });
              });
        },
      );
    }

    return ShortcutsScaffold(
        backactions: backactions,
        restart: restart,
        update: () {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            rebuilddeck();
            rebuilddom();
            for (int i = 0; i < 10; i++) {
              rebuildcolumn(i);
            }
          });
        },
        child: Scaffold(
            backgroundColor: const Color(0xFF4CAF50),
            body: DefaultTextStyle(
                style:
                    const TextStyle(fontFamilyFallback: <String>['Segoe UI']),
                child: Column(children: [
                  SizedBox(
                      height: screenSize.height / 4 * 3,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(children: row[0]),
                            SizedBox(width: screenSize.width / 54),
                            Stack(children: row[1]),
                            SizedBox(width: screenSize.width / 54),
                            Stack(children: row[2]),
                            SizedBox(width: screenSize.width / 54),
                            Stack(children: row[3]),
                            SizedBox(width: screenSize.width / 54),
                            Stack(children: row[4]),
                            SizedBox(width: screenSize.width / 54),
                            Stack(children: row[5]),
                            SizedBox(width: screenSize.width / 54),
                            Stack(children: row[6]),
                            SizedBox(width: screenSize.width / 54),
                            Stack(children: row[7]),
                            SizedBox(width: screenSize.width / 54),
                            Stack(children: row[8]),
                            SizedBox(width: screenSize.width / 54),
                            Stack(children: row[9])
                          ])),
                  Row(children: [
                    SizedBox(
                        width: cardWidth * 1,
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
                    SizedBox(width: cardWidth * 1),
                    SizedBox(width: cardWidth * 3, child: Stack(children: dom)),
                    GestureDetector(
                        onTap: solver,
                        child: Container(
                            width: cardWidth * 2,
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
                    SizedBox(width: cardWidth * 2),
                    SizedBox(
                        width: cardWidth * 3,
                        child: GestureDetector(
                            onTap: addCard, child: Stack(children: deck)))
                  ])
                ]))));
  }
}
