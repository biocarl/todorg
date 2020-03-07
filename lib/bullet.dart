class Bullet {
  String _title;
  bool _isChecked = false;
  bool _isTodo = true;
  int _level = 1;

  int get level => _level;

  set level(int value) {
    _level = value;
  }

  Bullet();

  Bullet.create(String title, bool isChecked) {
    this._isChecked = isChecked;
    this._title = title;
  }

  set title(String title) {
    this._title = title;
  }

  set isChecked(bool isChecked) {
    this._isChecked = isChecked;
  }

  set isTodo(bool isTodo) {
    this._isTodo = isTodo;
  }

  String get title {
    return this._title;
  }

  bool get isChecked {
    return this._isChecked;
  }

  bool get isTodo {
    return this._isTodo;
  }
}
