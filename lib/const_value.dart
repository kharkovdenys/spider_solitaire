import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

const List<String> difficulty = [
  "One suit ♠",
  "Two suits ♠ ♥",
  "Four suits ♠ ♥ ♣ ♦"
];
const List<String> countSuits = ["one", "two", "four"];
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
