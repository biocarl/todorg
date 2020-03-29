import 'package:flutter/material.dart';
import 'package:tudorg/bullet.dart';

Future<Bullet> getBulletFromUser(BuildContext context, Bullet bullet) async {
  final Bullet bulletEdited = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => EditBullet(bullet)));

  // TODO output something meaningful here
//  if (text != null) {
//    Scaffold.of(context)
//      ..removeCurrentSnackBar()
//      ..showSnackBar(SnackBar(
//          content: Text(
//              "The following note was ${existingBullet ? "added" : "updated"}: $text")));
//  }

  return bulletEdited;
}

class EditBullet extends StatefulWidget {
  Bullet bullet;

  EditBullet(this.bullet);

  @override
  _EditBulletState createState() {
    return _EditBulletState(this.bullet);
  }
}

class _EditBulletState extends State<EditBullet> {
  var titleTextController = TextEditingController();
  var descriptionTextController = TextEditingController();
  Bullet bullet;
  bool isTitle = true;

  _EditBulletState(Bullet bullet) {
    this.bullet = bullet;
    this.titleTextController.text = bullet.title;
    this.descriptionTextController.text = bullet.description;
  }

  @override
  void initState() {
    super.initState();
    // TODO Do one field for Header and description
//    this.titleTextController.addListener(() {
//      if (this.titleTextController.text.contains("\n")) {
//        setState(() {
//          this.isTitle = false;
//        });
//      }
//    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pick an option'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child:TextField(
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20.0),
                    labelText: 'Enter the description here.',
                    hintText: "... specify."),
                style: TextStyle(
                  fontSize: 22.0,
                  //color: Theme.of(context).accentColor,
                ),
                controller: descriptionTextController,
                cursorWidth: 5.0,
                autocorrect: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                //onSubmitted: ,
              ),
            ),
            Container(
              child:TextField(
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20.0),
                    labelText: 'Enter the title here',
                    hintText: "... what's up?"),
                style: TextStyle(
                  fontSize: 22.0,
                  //color: Theme.of(context).accentColor,
                ),
                controller: titleTextController,
                cursorWidth: 5.0,
                autocorrect: true,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                //onSubmitted: ,
              ),
            ),
            Center(
                child: new ButtonBar(mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                FlatButton(
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                  child: Text('Cancel'),
                ),
                  FlatButton(
                    onPressed: () {
                      Bullet bulletEdited = Bullet.clone(bullet);
                      bulletEdited.title = titleTextController.text;
                      bulletEdited.description = descriptionTextController.text;
                      Navigator.pop(context, bulletEdited);
                    },
                    child: Text('Save',
                        style: new TextStyle(
                          fontSize: 15.0,
                        )),
                  ),
                ])),
          ],
        ),
      ),
    );
  }
}
