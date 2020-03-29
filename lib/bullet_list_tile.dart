import 'package:flutter/material.dart';
import 'dart:math';

class BulletListTile extends StatelessWidget {
  const BulletListTile({
    this.leading,
    this.title,
    this.description,
  });

  final Widget leading;
  final Text title;
  final Widget description;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 10, top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            (leading != null) ? Expanded(flex: 1, child: leading) : Container(),
            Expanded(
              flex: 9,
              child: _BulletContent(
                title: title,
                description: description,
              ), // empty when notebook description
            ),
          ],
        ),
      ),
    );
  }
}

class _BulletContent extends StatelessWidget {
  const _BulletContent({
    Key key,
    this.title,
    this.description,
  }) : super(key: key);

  final Text title;
  final Widget description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(child: title),
          Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Container(child: description),
          Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
        ],
      ),
    );
  }
}
