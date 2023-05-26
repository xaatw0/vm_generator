class CountUpLogic {
  int _counter = 0;
  int get counter => _counter;

  void countUp() {
    _counter++;
  }

  void countDouble() {
    _counter = _counter * 2;
  }
}
