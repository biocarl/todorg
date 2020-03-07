import 'package:flutter/material.dart';

class EditBullet extends StatefulWidget {
  String existingString;

  EditBullet(this.existingString);

  @override
  _EditBulletState createState() {
    return _EditBulletState(this.existingString);
  }
}

class _EditBulletState extends State<EditBullet> {
  var inputTextController = TextEditingController();
  String existingString;
  bool isTitle = true;

  _EditBulletState(String existingString) {
    this.existingString = existingString;
    if (this.existingString.isNotEmpty) {
      this.inputTextController.text = this.existingString;
      this.isTitle = false;
    }
  }

  @override
  void initState() {
    super.initState();
    this.inputTextController.addListener(() {
      print(this.inputTextController.text);
      if (this.inputTextController.text.contains("\n")) {
        setState(() {
          this.isTitle = false;
        });
      }
    });
  }

  method() {
    inputTextController.dispose();
    inputTextController.clear();
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
                      Navigator.pop(context, inputTextController.text);
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
