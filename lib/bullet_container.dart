import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tudorg/bullet_tile.dart';
import 'package:tudorg/bullet.dart';
import 'package:tudorg/theme.dart';

class BulletContainer extends StatelessWidget {
  Bullet bullet;
  Function onCheckboxChange;
  Function onTap;
  Function onEditBullet;
  bool isCollapsed;
  bool hasChildren;
  List<int> checkedCheckboxRatio;

  BulletContainer(
      {Bullet bullet,
      Function onCheckboxChange,
      void Function() onTap,
      void Function() onEditBullet,
      bool isCollapsed,
      bool hasChildren,
      this.checkedCheckboxRatio}) {
    this.bullet = bullet;
    this.onCheckboxChange = onCheckboxChange;
    this.onTap = onTap;
    this.onEditBullet = onEditBullet;
    this.isCollapsed = isCollapsed;
    this.hasChildren = hasChildren;
  }

  Widget _bulletTile() {
    if (!this.bullet.isVisible) {
      return null;
    }
    return BulletTile(
      title: bullet.title,
      onCheckBoxChange: onCheckboxChange,
      isChecked: bullet.isChecked,
      checkboxRatio: checkedCheckboxRatio,
      collapsingArrow: (hasChildren)
          ? Icon((isCollapsed) ? Icons.arrow_right : Icons.arrow_drop_down)
          : (bullet.title.isEmpty)
              ? null //Like notebook description
              : Icon(Icons.panorama_fish_eye, //plain bullets without children
                  color: Colors.transparent),
      description: (bullet.description.isNotEmpty && !isCollapsed)
          ? bullet.description
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bulletTile = _bulletTile();
    return (bulletTile != null) ? card(bulletTile) : Container();
  }

  Widget card(Widget bulletTile) {
    return GestureDetector(
        onPanStart: (details) => this.onEditBullet(),
        onTap: this.onTap,
        onLongPress: (hasChildren && !isCollapsed)
            ? () => Fluttertoast.showToast(msg: "Collapse before moving!")
            : null,
        child: Container(
            color: getMainColor((this.bullet.level - 1)),
            child: Padding(
                padding: EdgeInsets.only(left: 12.0 * this.bullet.level),
                child: Card(
                    margin: EdgeInsets.only(top: 2.5, bottom: 2.5),
                    color: getMainColor(this.bullet.level),
                    child: bulletTile))));
  }
}
