import 'bullet.dart';

enum _State { TODO, DONE }

String _get(_State state) {
  return state.toString().split(".").last;
}

class OrgConverter {
  OrgConverter();

  bool _hasMatch(String string, String regex) {
    RegExp regExp = new RegExp(regex);
    return regExp.hasMatch(string);
  }

  Match _group(String string, String regex) {
    RegExp regExp = new RegExp(regex);
    return regExp.allMatches(string).elementAt(0);
  }

  String bulletsToString(List<Bullet> bullets) {
    String result = "";
    bullets.forEach((bullet) {
      result += "*" * bullet.level + " ";
      if (bullet.isTodo) {
        if (bullet.isChecked) {
          result += "${_get(_State.DONE)}";
        } else {
          result += "${_get(_State.TODO)}";
        }
        result += " ";
      }
      result += bullet.title;
      result += "\n";
    });
    return result.trim();
  }

  List<Bullet> parseFromString(String raw) {
    int currentLevel = 0;

    List<Bullet> bullets = List<Bullet>();
    raw += "\n"; //in case files contains a single line

    raw.split("\n").forEach((line) {
      if (line.isNotEmpty) {
        if (_hasMatch(line, r"^[\*]+\s")) {
          Bullet bullet = new Bullet();
          String title = _group(line, r"^([\*]+)\s(.+)").group(2);
          int level = _group(line, r"^([\*]+)\s(.+)").group(1).length;
          if (title.startsWith(_get(_State.TODO))) {
            title = title.replaceFirst(_get(_State.TODO), "").trim();
            bullet.isTodo = true;
            bullet.isChecked = false;
          } else if (title.startsWith(_get(_State.DONE))) {
            title = title.replaceFirst(_get(_State.DONE), "").trim();
            bullet.isTodo = true;
            bullet.isChecked = true;
          } else {
            bullet.isTodo = false;
          }
          bullet.title = title.trim();
          bullet.level = level;
          bullets.add(bullet);
        } else {
          //here we assume that ever non header still the previous header continuing as multiline
          if (bullets.last != null) {
            bullets.last.title += "\n${line}";
          } else {
            // no previous header means creating a non-todo bullet
            Bullet bullet = new Bullet();
            bullet.isTodo = false;
            bullet.title = line;
            bullets.add(bullet);
          }
        }
      }
    });
    return bullets;
  }
}
