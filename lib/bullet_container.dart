import 'package:flutter/material.dart';
import 'package:tudorg/bullet.dart';

class BulletContainer extends StatelessWidget {
  Bullet bullet;
  Function onCheckboxChange;
  Function onFold;
  Function onEditBullet;

  BulletContainer(
      {Bullet bullet,
      Function onCheckboxChange,
      void Function() onFold,
      void Function() onDoubleTap}) {
    this.bullet = bullet;
    this.onCheckboxChange = onCheckboxChange;
    this.onFold = onFold;
    this.onEditBullet = onDoubleTap;
  }

  Widget _widget() {
    if (!this.bullet.isVisible) {
      return Container();
    }
    return bullet.isTodo
        ? GestureDetector(
            onPanStart: (details) => this.onEditBullet(),
            child: CheckboxListTile(
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
                onChanged: onCheckboxChange),
          )
        : GestureDetector(
            onPanStart: (details) => this.onEditBullet(),
            onTap: this.onFold,
            child: ListTile(
                title: Text(bullet.title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 22.0)),
                trailing: Icon(Icons.more_vert)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
            color: Colors.lightBlue[900 - 100 * this.bullet.level]),
        child: _widget());
  }
}
