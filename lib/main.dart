import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tudorg/bullet_list.dart';
import 'package:tudorg/file_picker.dart';
import 'package:tudorg/theme.dart';
import 'bullet.dart';
import 'org_handler.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'edit_bullet.dart';
import 'package:flutter/foundation.dart';
import 'utils.dart';

void main() {
  runApp(MaterialApp(
    title: "TodOrg",
    home: App(),
  ));
}

class App extends StatefulWidget {
  @override
  AppState createState() {
    return AppState();
  }
}

class AppState extends State<App> {
  String filePath = "";
  List<Bullet> bulletList = [];
  bool needsUpdate = false;
  bool isLastFileSelection = false;


  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: getMainColor(0),
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                  icon: Icon(Icons.check_circle_outline),
                  onPressed: () => _deleteCheckedBullets()),
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
          onPressed: () => _addNewTask(context),
          splashColor: Colors.red,
          child: Icon(Icons.add_box),
          backgroundColor: Colors.green,
        );
      }),
      body: Container(
          color: getMainColor(0),
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  backgroundColor:
                      needsUpdate ? Colors.orangeAccent : getMainColor(0),
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    collapseMode: CollapseMode.none,
                    title: (isLastFileSelection)
                        ? GestureDetector(
                            child: Text(
                              "Select last opened file",
                              style: TextStyle(color: Colors.black),
                            ),
                            onTap: () => setState(() {
                              isLastFileSelection = false;
                            }),
                          )
                        : Text(
                            "${basename(this.filePath)}",
                            style: TextStyle(color: Colors.black),
                          ),
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                            child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 25.0))),
                        Flexible(
                            child: Text("TodOrg",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold))),
                        (isLastFileSelection)
                            ? OpenLastFilePicker(
                                onSelection: (selectedFile) async{
                                  _storeLastOpenedFile();
                                  setState(() {
                                    this.filePath = selectedFile;
                                    isLastFileSelection = false;
                                    _parseFile();
                                  });
                                },
                              )
                            : Flexible(
                                child: GestureDetector(
                                    child: IconButton(
                                      icon: Icon(Icons.arrow_drop_down_circle),
                                      onPressed: _selectFileAndLoad,
                                      color: Colors.black,
                                    ),
                                    onLongPress: () async {
                                      setState(() {
                                        isLastFileSelection = true;
                                      });
                                    }),
                              )
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: BulletList(
                onUpdate: () =>
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        this.needsUpdate = true;
                      });
                    }),
                onSave: _saveToFile,
                bulletList: this.bulletList),
          )),
    );
  }

  _loadDebugData() async {
    print("Debug mode");
    var bullets = await loadDebugData();
    setState(() {
      this.bulletList = bullets;
      this.filePath = "etc/dummy.org";
      this.needsUpdate = false;
    });
  }

  _checkPermissions() {
    PermissionHandler().requestPermissions([PermissionGroup.storage]).then((p) {
      PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage)
          .then((p) => print(p));
    });
  }

  _loadFromLastFile() async {
    // obtain shared preferences
    var prefs = await SharedPreferences.getInstance();
    String filePath = prefs.getString('org-file');
    if (filePath != null && filePath.isNotEmpty) {
      this.filePath = filePath;
      await _parseFile();
    }
  }

  _parseFile() async {
    OrgFileHandler org = new OrgFileHandler(filePath);
    try {
      print("Parsing from ${this.filePath}");
      List<Bullet> parsedBullets = await org.parse();

      setState(() {
        this.bulletList = parsedBullets;
        this.needsUpdate = false;
      });
    } on FileSystemException {
      print("File does not exist (or is not valid)");
    }
  }


  _storeLastOpenedFile() async {
    if (filePath == null) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int maxAmountToStore = 5; //inclusive
    String updatedFileList = filePath;

    // Get files
    String filesString = prefs.getString('last-opended');
    if (filesString != null) {
      List<String> files = filesString.split(" ");
      files.insert(0, filePath);
      files = files.toSet().toList(); //make elements distinct
      if (files.length > maxAmountToStore) {
        files.removeLast();
      }
      updatedFileList = files.join(" ");
    }
    prefs.setString('last-opended', updatedFileList);
  }

  _selectFileAndLoad() {
    FilePicker.getFile().then((file) {
      SharedPreferences.getInstance().then((prefs) async {
        if (file != null) {
          await _storeLastOpenedFile();
          prefs.setString('org-file', file.absolute.path);
          this.filePath = file.absolute.path;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _parseFile();
          });
        }
      });
    });
  }

  Future<void> _saveToFile() async {
    if (!kReleaseMode) {
      await _loadDebugData();
      return;
    }

    print("Writing to ${this.filePath}");
    OrgFileHandler org = new OrgFileHandler(this.filePath);
    await org.update(this.bulletList);
    setState(() {
      this.needsUpdate = false;
    });
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (kReleaseMode) {
        _loadFromLastFile();
      } else {
        await _loadDebugData();
      }
    });
  }

  _deleteCheckedBullets() {
    setState(() {
      this.bulletList =
          bulletList.where((element) => !element.isChecked).toList();
      this.needsUpdate = true;
    });
  }

  _addNewTask(BuildContext context) async {
    Bullet bullet = Bullet.create("", false, 1);
    var bulletEdited = await getBulletFromUser(context, bullet);
    setState(() {
      if (bulletEdited != null) {
        // TODO migrate this into editBullet widget: Two line breaks means a bullet, otherwise a task
        bulletEdited.isTodo =
            !("\n".allMatches(bulletEdited.title).length == 2);
        if (!bulletEdited.isTodo) {
          bulletEdited.title = bulletEdited.title.trim();
        }

        bulletList.insert(0, bulletEdited);
        this.needsUpdate = true;
      }
    });
  }


}

