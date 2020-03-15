import 'package:flutter/material.dart';
import 'package:tudorg/bullet.dart';

class BulletContainer extends StatelessWidget {
  Bullet bullet;
  Function onChanged;
  bool isHidden = false;

  BulletContainer(Bullet bullet, Function onChanged, bool isHidden) {
    this.bullet = bullet;
    this.onChanged = onChanged;
    this.isHidden = isHidden;
  }

  Widget _widget() {
    if (this.isHidden) {
      return Container();
    }
    return bullet.isTodo
        ? CheckboxListTile(
            value: bullet.isChecked,
            title: (bullet.isChecked)
                ? Text(bullet.title,
                    style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontStyle: FontStyle.italic,
                      fontSize: 22.0,
                      color: Colors.grey[600],
                    ))
                : Text(
                    bullet.title,
                    style: TextStyle(fontSize: 22.0),
                  ),
            onChanged: onChanged)
        : ListTile(
            title: Text(bullet.title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0)),
            trailing: Icon(Icons.more_vert));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
            color: Colors.lightBlue[900 - 100 * this.bullet.level]),
        child: _widget());
  }
}
