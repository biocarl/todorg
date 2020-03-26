import 'package:flutter/material.dart';
import 'package:tudorg/bullet.dart';

class BulletContainer extends StatelessWidget {
  Bullet bullet;
  Function onCheckboxChange;
  Function onFold;
  Function onEditBullet;
  bool isCollapsed;
  bool hasChildren;

  BulletContainer(
      {Bullet bullet,
      Function onCheckboxChange,
      void Function() onFold,
      void Function() onDoubleTap, bool isCollapsed, bool hasChildren}) {
    this.bullet = bullet;
    this.onCheckboxChange = onCheckboxChange;
    this.onFold = onFold;
    this.onEditBullet = onDoubleTap;
    this.isCollapsed = isCollapsed;
    this.hasChildren = hasChildren;
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
                          fontWeight: FontWeight.w300,
                          color: Colors.grey[600],
                        ))
                    : Text(
                        bullet.title,
                        style: TextStyle(fontSize: 22.0,
                        fontWeight: FontWeight.w300 )),
                onChanged: onCheckboxChange),
          )
        : GestureDetector(
            onPanStart: (details) => this.onEditBullet(),
            onTap: this.onFold,
            child: ListTile(
              title: Text(bullet.title,
                  style: _getStyle()) ,
              trailing: (hasChildren) ? Icon((isCollapsed) ? Icons.arrow_drop_down : Icons.arrow_left) : null,
              subtitle: hasChildren || bullet.description.isNotEmpty ?
              Padding(
                      padding: EdgeInsets.only(left: 5, top: 5, bottom: 5),
                      child: Text(
                          (bullet.description.isNotEmpty && !isCollapsed) ?
                          bullet.description : "",
                      style: TextStyle(fontSize: 15),
                      )) : null,
              dense: true,
              isThreeLine: hasChildren || bullet.description.isNotEmpty,
            )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: new BoxDecoration(
            color: Colors.lightBlue[900 - 100 * this.bullet.level]),
        child: _widget());
  }

  TextStyle _getStyle() {
      return TextStyle(fontWeight: FontWeight.w300, fontSize: 20.0);
  }
}
