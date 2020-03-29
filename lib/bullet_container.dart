import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tudorg/bullet_list_tile.dart';
import 'package:tudorg/bullet.dart';
import 'package:tudorg/theme.dart';

class BulletContainer extends StatelessWidget {
  Bullet bullet;
  Function onCheckboxChange;
  Function onFold;
  Function onEditBullet;
  bool isCollapsed;
  bool hasChildren;
  double FONT_TITLE = 20;
  double FONT_DESCRIPTION = 18;

  BulletContainer(
      {Bullet bullet,
      Function onCheckboxChange,
      void Function() onFold,
      void Function() onEditBullet,
      bool isCollapsed,
      bool hasChildren}) {
    this.bullet = bullet;
    this.onCheckboxChange = onCheckboxChange;
    this.onFold = onFold;
    this.onEditBullet = onEditBullet;
    this.isCollapsed = isCollapsed;
    this.hasChildren = hasChildren;
  }

  Widget _widget() {
    if (!this.bullet.isVisible) {
      return null;
    }
    return bullet.isTodo
        ? GestureDetector(
            onPanStart: (details) => this.onEditBullet(),
            child: CheckboxListTile(
                dense: true,
                value: bullet.isChecked,
                title: (bullet.isChecked)
                    ? Text(bullet.title,
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          fontStyle: FontStyle.italic,
                          fontSize: FONT_TITLE,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey[600],
                        ))
                    : Text(bullet.title,
                        style: TextStyle(
                            fontSize: FONT_TITLE, fontWeight: FontWeight.w300)),
                onChanged: onCheckboxChange),
          )
        : GestureDetector(
            onPanStart: (details) => this.onEditBullet(),
            onTap: this.onFold,
            onLongPress: (hasChildren && !isCollapsed)
                ? () => Fluttertoast.showToast(msg: "Collapse before moving!")
                : null,
            child: BulletListTile(
              title: Text(bullet.title,
                  style: _getStyle(), textAlign: TextAlign.left),
              leading: (hasChildren)
                  ? Icon((isCollapsed)
                      ? Icons.arrow_right
                      : Icons.arrow_drop_down) //open and expand
                  : (bullet.title.isEmpty)
                      ? null //Like notebook description
                      : Icon(
                          Icons
                              .panorama_fish_eye, //plain bullets without children
                          color: Colors.transparent),
              description: (bullet.description.isNotEmpty && !isCollapsed)
                  ? Padding(
                      padding: (bullet.title.isNotEmpty)
                          ? EdgeInsets.zero
                          : EdgeInsets.only(left: 15, bottom: 8),
                      child: SelectableText(
                        bullet.description,
                        style: TextStyle(
                            fontSize: FONT_DESCRIPTION,
                            color: Colors.grey[500]),
                      ))
                  : null,
            ));
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = _widget();
    if (widget == null) {
      return Container();
    }
    return Container(
        color: getMainColor((this.bullet.level - 1)),
        child: Padding(
            padding: EdgeInsets.only(left: 12.0 * this.bullet.level),
            child: Card(
                margin: EdgeInsets.only(top: 2.5, bottom: 2.5),
                color: getMainColor(this.bullet.level),
                child: widget)));
  }

  TextStyle _getStyle() {
    return TextStyle(fontWeight: FontWeight.w300, fontSize: FONT_TITLE);
  }
}
