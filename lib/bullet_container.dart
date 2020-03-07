import 'package:flutter/material.dart';

class BulletContainer extends StatelessWidget {
  final String bulletTitle;
  final bool bulletIsChecked;

  BulletContainer(this.bulletTitle, this.bulletIsChecked) : super();

  Widget _widget() {
    if (bulletIsChecked) {
      return Text(
        bulletTitle,
        style: TextStyle(
          decoration: TextDecoration.lineThrough,
          fontStyle: FontStyle.italic,
          fontSize: 22.0,
          color: Colors.grey[600],
        ),
      );
    } else {
      return Text(
        bulletTitle,
        style: TextStyle(fontSize: 22.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _widget();
  }
}
