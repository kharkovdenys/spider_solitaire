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
        "assets/images/Essberger/back.png",
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high),
    suitStyles: {
      Suit.spades: SuitStyle(
          builder: (context) => Image.asset("assets/images/Essberger/spade.png",
              filterQuality: FilterQuality.high),
          cardContentBuilders: {
            CardValue.ace: (context) =>
                Image.asset("assets/images/Essberger/as.png"),
            CardValue.jack: (context) =>
                Image.asset("assets/images/Essberger/js.png"),
            CardValue.queen: (context) =>
                Image.asset("assets/images/Essberger/qs.png"),
            CardValue.king: (context) =>
                Image.asset("assets/images/Essberger/ks.png"),
          }),
      Suit.hearts: SuitStyle(
          builder: (context) => Image.asset("assets/images/Essberger/heart.png",
              filterQuality: FilterQuality.high),
          cardContentBuilders: {
            CardValue.jack: (context) =>
                Image.asset("assets/images/Essberger/jh.png"),
            CardValue.queen: (context) =>
                Image.asset("assets/images/Essberger/qh.png"),
            CardValue.king: (context) =>
                Image.asset("assets/images/Essberger/kh.png"),
          }),
      Suit.diamonds: SuitStyle(
          builder: (context) => Image.asset(
              "assets/images/Essberger/diamond.png",
              filterQuality: FilterQuality.high),
          cardContentBuilders: {
            CardValue.jack: (context) =>
                Image.asset("assets/images/Essberger/jd.png"),
            CardValue.queen: (context) =>
                Image.asset("assets/images/Essberger/qd.png"),
            CardValue.king: (context) =>
                Image.asset("assets/images/Essberger/kd.png"),
          }),
      Suit.clubs: SuitStyle(
          builder: (context) => Image.asset("assets/images/Essberger/club.png",
              filterQuality: FilterQuality.high),
          cardContentBuilders: {
            CardValue.jack: (context) =>
                Image.asset("assets/images/Essberger/jc.png"),
            CardValue.queen: (context) =>
                Image.asset("assets/images/Essberger/qc.png"),
            CardValue.king: (context) =>
                Image.asset("assets/images/Essberger/kc.png"),
          })
    });
