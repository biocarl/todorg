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
  var inputTextController = TextEditingController();
  Bullet bullet;
  bool isTitle = true;

  _EditBulletState(Bullet bullet) {
    this.bullet = bullet;
    if (this.bullet.title.isNotEmpty) {
      this.inputTextController.text = bullet.title;
      this.isTitle = false;
    }
  }

  @override
  void initState() {
    super.initState();
    this.inputTextController.addListener(() {
      if (this.inputTextController.text.contains("\n")) {
        setState(() {
          this.isTitle = false;
        });
      }
    });
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
              child: TextField(
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(20.0),
                    labelText:
                        'Enter ${this.isTitle ? "the task title" : "the description"}',
                    hintText: "... what's up?"),
                style: TextStyle(
                  fontSize: 22.0,
                  //color: Theme.of(context).accentColor,
                ),
                controller: inputTextController,
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
                    // this will take space as minimum as posible(to center)
                    children: <Widget>[
//                FlatButton(
//                  onPressed: () {
//                    Navigator.pop(context,
//                        this.existingString); //TODO can you return null? For not wanting to update/create a bullet?
//                  },
//                  child: Text('Cancel'),
//                ),
                  FlatButton(
                    onPressed: () {
                      Bullet bulletEdited = Bullet.clone(bullet);
                      bulletEdited.title = inputTextController.text;
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
