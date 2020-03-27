class Bullet {
  String _title = "";
  String _description = "";
  bool _isChecked = false;
  bool _isTodo = true;
  int _level = 1;

  Bullet();

  Bullet.create(String title, bool isChecked, int level) {
    this._isChecked = isChecked;
    this._title = title;
    this._level = level;
  }

  static Bullet clone(Bullet toClone) {
    Bullet bullet = Bullet();
    bullet._title = toClone._title;
    bullet._description = toClone._description;
    bullet._isChecked = toClone._isChecked;
    bullet._isTodo = toClone._isTodo;
    bullet._level = toClone._level;
    return bullet;
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

  //TODO Wrap this into a stateful widget
  bool _isVisible = true;

  bool get isVisible => _isVisible;

  set isVisible(bool value) {
    _isVisible = value;
  }

  int get level => _level;

  set level(int value) {
    _level = value;
  }

  String get description => _description;

  set description(String value) {
    _description = value;
  }
}
