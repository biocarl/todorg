import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'bullet.dart';
import 'org_handler.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'edit_bullet.dart';
import 'custom_bar.dart';
import 'bullet_container.dart';

void main() {
  runApp(MaterialApp(
    title: "TodOrg",
    home: App(),
  ));
}

class AppState extends State<App> {
  String filePath = "";
  List<Bullet> bulletList = [];
  bool needsUpdate = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLastFile();
    });
  }

  _checkPermissions() {
    PermissionHandler().requestPermissions([PermissionGroup.storage]).then((p) {
      PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage)
          .then((p) => print(p));
    });
  }

  _loadLastFile() async {
    // obtain shared preferences
    var prefs = await SharedPreferences.getInstance();
    String filePath = prefs.getString('org-file');
    if (filePath != null && filePath.isNotEmpty) {
      this.filePath = filePath;
      await _parseOrgFile();
    }
  }

  _parseOrgFile() async {
    OrgFileHandler org = new OrgFileHandler(filePath);
    try {
      if (basename(filePath).startsWith("_")) {
        print("Parsing from ${this.filePath}");
        List<Bullet> parsedBullets = await org.parse();

        print(parsedBullets);
        setState(() {
          print("Setting new state");
          this.bulletList = parsedBullets;
          this.needsUpdate = false;
        });
      } else {
        throw FileSystemException();
      }
    } on FileSystemException {
      print("File does not exist (or is not valid) - adding dummy data");
      setState(() {
        this.bulletList.add(Bullet.create("Dummy1", false,1));
        this.bulletList.add(Bullet.create("Dummy2", true,1));
        this.bulletList.add(Bullet.create("Dummy3", false,1));
        this.bulletList.add(Bullet.create("Dummy3", false,1));
        this.bulletList.add(Bullet.create("Dummy3", false,1));
        this.bulletList.add(Bullet.create("Dummy3", false,1));
        this.bulletList.add(Bullet.create("Dummy3", false,1));
        this.bulletList.add(Bullet.create("Dummy3", false,1));
        this.bulletList.add(Bullet.create("Dummy3", false,1));
        this.bulletList.add(Bullet.create("Dummy3", false,1));
        this.needsUpdate = false;
      });
    }
  }

  Future<void> _updateOrgFile() async {
    print("Writing to ${this.filePath}");
    OrgFileHandler org = new OrgFileHandler(this.filePath);
    await org.update(this.bulletList);
    setState(() {
      this.needsUpdate = false;
    });
  }

  Future<String> _getTextFromUser(
      BuildContext context, String existingText) async {
    final String text = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditBullet(existingText)),
    );

    if (text != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
            content: Text(
                "The following note was ${existingText.isEmpty ? "added" : "updated"}: $text")));
    }

    return text;
  }

  _getNewFile() {
    FilePicker.getFile().then((file) {
      SharedPreferences.getInstance().then((prefs) {
        if (file != null) {
          print("Setting org-file ${file.absolute.path}");
          prefs.setString('org-file', file.absolute.path);
          this.filePath = file.absolute.path;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _parseOrgFile();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.check_circle_outline),
                  onPressed: () {
                    setState(() {
                      this.bulletList = bulletList
                          .where((element) => !element.isChecked)
                          .toList();
                      this.needsUpdate = true;
                    });
                  }),
              IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    print("No function yet");
                  }),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          onPressed: () {
            _getTextFromUser(context, "").then((inputText) {
              setState(() {
                if (inputText != null && inputText.isNotEmpty) {
                  //TODO move this to org_handler/converter
                  //Two line breaks means a bullet, otherwise a task
                  Bullet bullet = Bullet.create(inputText, false,1);
                  bullet.isTodo = !("\n".allMatches(inputText).length == 2);
                  if (!bullet.isTodo) {
                    bullet.title = bullet.title.trim();
                  }
                  bulletList.insert(0, bullet);
                  this.needsUpdate = true;
                }
              });
            });
          },
          child: Icon(Icons.add_box),
          backgroundColor: Colors.green,
        );
      }),
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            backgroundColor: needsUpdate ? Colors.orangeAccent : null,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              collapseMode: CollapseMode.none,
              title: Text("${basename(this.filePath)}"),
              background: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                      child: Text("TodOrg",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                  Flexible(
                      child: IconButton(
                    icon: Icon(Icons.arrow_drop_down_circle),
                    onPressed: _getNewFile,
                    color: Colors.white,
                  )),
                ],
              ),
            ),
          ),
        ];
      }, body: new Builder(builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: new RefreshIndicator(
                  onRefresh: _updateOrgFile,
                  child: ReorderableListView(
                    children: <Widget>[
                      for (final widget in bulletList)
                        GestureDetector(
                          key: Key(widget.title),
                          child: Dismissible(
                            key: Key(widget.title),
                            child: widget.isTodo
                                ? CheckboxListTile(
                                    value: widget.isChecked,
                                    title: BulletContainer(
                                        widget.title, widget.isChecked),
                                    onChanged: (checkValue) {
                                      setState(() {
                                        if (!checkValue) {
                                          widget.isChecked = false;
                                        } else {
                                          widget.isChecked = true;
                                        }
                                        this.needsUpdate = true;
                                      });
                                    },
                                  )
                                : ListTile(
                                    title: Text(widget.title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22.0))),
                            background: Container(
                              child: Icon(Icons.delete),
                              alignment: Alignment.centerRight,
                              color: Colors.redAccent,
                            ),
                            confirmDismiss: (dismissDirection) {
                              return showDialog(
                                  //On Dismissing
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Delete bullet?"),
                                      actions: <Widget>[
                                        FlatButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            }),
                                        FlatButton(
                                          child: Text("OK"),
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                        ), //OK Button
                                      ],
                                    );
                                  });
                            },
                            direction: DismissDirection.endToStart,
                            movementDuration: const Duration(milliseconds: 200),
                            onDismissed: (dismissDirection) {
                              //Delete todo
                              bulletList.remove(widget);
                              this.needsUpdate = true;
                              Fluttertoast.showToast(msg: "Todo Deleted!");
                            },
                          ),
                          onDoubleTap: () {
                            // Edit existing bullet
                            _getTextFromUser(context, widget.title)
                                .then((inputText) {
                              setState(() {
                                if (inputText != null && inputText.isNotEmpty) {
                                  int position = bulletList.indexOf(widget);
                                  bulletList.remove(widget);
                                  widget.title = inputText;
                                  bulletList.insert(position, widget);
                                  this.needsUpdate = true;
                                }
                              });
                            });
                          },
                        )
                    ],
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }
                        var replaceWiget = bulletList.removeAt(oldIndex);
                        bulletList.insert(newIndex, replaceWiget);
                        this.needsUpdate = true;
                      });
                    },
                  )),
            ),
          ],
        );
      })),
    );
  }
}

class App extends StatefulWidget {
  @override
  AppState createState() {
    return AppState();
  }
}
