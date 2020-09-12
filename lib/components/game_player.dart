class GamePlayer {
  String name;
  int points;
  bool isFinished;

  GamePlayer(this.name);

  void initialize() {
    this.points = 0;
    this.isFinished = false;
  }

  void set(int points, bool isFinished) {
    this.points = points;
    this.isFinished = isFinished;
  }

  void newRound() {
    this.isFinished = false;
  }

  void addPoints(int points) {
    this.points += points;
  }

  void subtractPoints() {
    if (this.points > 9) {
      this.points -= 10;
    } else {
      this.points -= 1;
    }
  }

  void finish() {
    this.isFinished = true;
  }

  toJson() {
    return {
      'name': name,
      'points': points,
      'isFinished': isFinished,
    };
  }
}
