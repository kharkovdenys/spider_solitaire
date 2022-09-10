class GameCard {
  int value;
  int suit;
  bool face;
  @override
  bool operator ==(other) =>
      other is GameCard &&
      other.value == value &&
      other.suit == suit &&
      other.face == face;
  GameCard(this.value, this.suit, this.face);
  set setFace(bool face) => this.face = face;
  @override
  int get hashCode => int.parse('$value$suit$face');
}
