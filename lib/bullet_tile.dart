import 'package:flutter/material.dart';
import 'dart:math';

class BulletTile extends StatelessWidget {

  const BulletTile({
    this.foldArrow,
    this.title,
    this.description,
    this.onCheckBoxChange,
    this.isChecked,this.checkboxRatio,
  });
  final Widget foldArrow;
  final String title;
  final String description;

  // If checkbox
  final Function(bool) onCheckBoxChange;
  final bool isChecked;
  final List<int> checkboxRatio;

  @override
  Widget build(BuildContext context) {
    bool isCheckBox = onCheckBoxChange != null;
    List<Widget> widgets = [];

    if (foldArrow != null) {
      widgets.add(Expanded(flex: 1, child: foldArrow));
    }

    widgets.add(Expanded(
      flex: 9,
      child: _BulletContent(
          isChecked: (isCheckBox && isChecked),
          checkboxRatio:  checkboxRatio,
          title: title,
          description: description), // empty when notebook description
    ));

    if (isCheckBox) {
      widgets.add(Expanded(
          flex: 1,
          child: Checkbox(
              value: isChecked,
              onChanged: (checkValue) => this.onCheckBoxChange(checkValue))));
    }

    return Container(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 10, top: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgets,
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
    this.isChecked, this.checkboxRatio,
  }) : super(key: key);

  final String title;
  final String description;
  final double FONT_TITLE = 20;
  final double FONT_DESCRIPTION = 18;

  final bool isChecked;
  final List<int> checkboxRatio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ( checkboxRatio!= null) ? Text( " ${checkboxRatio[0]}/${ checkboxRatio[1]}",
            style: TextStyle(
              color: (checkboxRatio[0] == checkboxRatio[1]) ? Colors.green : Colors.orangeAccent,
            ),
          ) : Container(),
          Container(
              child: Text(title,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: FONT_TITLE,
                    decoration: (isChecked) ? TextDecoration.lineThrough : null,
                    color: (isChecked) ? Colors.grey[500] : null,
                    fontStyle: (isChecked) ? FontStyle.italic : null,
                  ),
                  textAlign: TextAlign.left)),
          (this.description != null && this.description.isNotEmpty)
              ? Container(
                  child: Padding(
                      padding: (title.isNotEmpty)
                          ? EdgeInsets.symmetric(vertical: 5)
                          : EdgeInsets.only(
                              left: 15, bottom: 8), // e.g. notebook description
                      child: SelectableText(
                        description,
                        style: TextStyle(
                            fontSize: FONT_DESCRIPTION,
                            decoration:
                                (isChecked) ? TextDecoration.lineThrough : null,
                            fontStyle: (isChecked) ? FontStyle.italic : null,
                            color: Colors.grey[500]),
                      )))
              : Container(),
//          Padding(padding: EdgeInsets.symmetric(vertical: 1.0)),
        ],
      ),
    );
  }
}
