import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tudorg/bullet_list.dart';
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
          color: getMainColor(400),
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 200.0,
                  backgroundColor:
                      needsUpdate ? Colors.orangeAccent : getMainColor(400),
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
                          onPressed: _selectFileAndLoad,
                          color: Colors.white,
                        )),
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

  _selectFileAndLoad() {
    FilePicker.getFile().then((file) {
      SharedPreferences.getInstance().then((prefs) {
        if (file != null) {
          print("Setting org-file ${file.absolute.path}");
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
    var inputText = await getTextFromUser(context, "");
    setState(() {
      if (inputText != null && inputText.isNotEmpty) {
        //Two line breaks means a bullet, otherwise a task
        Bullet bullet = Bullet.create(inputText, false, 1);
        bullet.isTodo = !("\n".allMatches(inputText).length == 2);
        if (!bullet.isTodo) {
          bullet.title = bullet.title.trim();
        }
        bulletList.insert(0, bullet);
        this.needsUpdate = true;
      }
    });
  }
}
