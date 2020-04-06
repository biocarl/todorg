import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tudorg/bullet_list.dart';
import 'package:tudorg/open_last_file_picker.dart';
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

enum TopBarViewState { defaultState, lastFileSelection, createNewFile }

class AppState extends State<App> {
  String filePath = "";
  List<Bullet> bulletList = [];
  bool needsUpdate = false;
  TopBarViewState topBarViewState = TopBarViewState.defaultState;

  final createNewFileTextController = TextEditingController();
  var isValidName = false;
  String parentPath = ""; //Android only

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    if (Platform.isAndroid) {
      _checkOnFirstStart();
    }
    _loadData();
    this.createNewFileTextController.addListener(() {
      if (this.createNewFileTextController.text.trim().length > 2) {
        setState(() {
          isValidName = true;
        });
      } else if (isValidName) {
        setState(() {
          isValidName = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        color: getMainColor(0),
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          child: Row(
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
                  expandedHeight: (topBarViewState != TopBarViewState.defaultState) ? 190.0 : 140,
                  backgroundColor:
                      needsUpdate ? Colors.orangeAccent : getMainColor(0),
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    collapseMode: CollapseMode.none,
                    title: _buildBottomView(context),
                    background: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                            child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 30.0))),
                        _buildMiddleView(),
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

  Widget _buildMiddleView() {
    switch (topBarViewState) {
      case TopBarViewState.defaultState:
        return Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                  child: IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () => setState(() {
                  topBarViewState = TopBarViewState.createNewFile;
                }),
                highlightColor: Colors.orangeAccent,
                color: Colors.black,
              )),
              GestureDetector(
                  child: IconButton(
                    icon: Icon(Icons.folder_open),
                    onPressed: _selectFileAndLoad,
                    highlightColor: Colors.orangeAccent,
                    color: Colors.black,
                  ),
                  onLongPress: () async {
                    setState(() {
                      topBarViewState = TopBarViewState.lastFileSelection;
                    });
                  }),
            ],
          ),
        );
      case TopBarViewState.lastFileSelection:
        return OpenLastFilePicker(
          onSelection: (selectedFile) async {
            await _storeLastOpenedFile();
            setState(() {
              this.filePath = selectedFile;
              topBarViewState = TopBarViewState.defaultState;
              _parseFile();
            });
          },
        );
      case TopBarViewState.createNewFile:
        return Padding(
          padding: EdgeInsets.only(top: 0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                            (isValidName)
                                ? "2. Confirm"
                                : "1. Select file name",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold)))),
                Flexible(
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: RawMaterialButton(
                        onPressed: () => _createNewFile(),
                        child: Icon(
                          (isValidName) ? Icons.save : Icons.edit,
                          color: (isValidName) ? Colors.white : Colors.grey,
                          size: 25,
                        ),
                        shape: new CircleBorder(),
                        elevation: 0,
                        fillColor:
                            (isValidName) ? Colors.green : Colors.transparent,
                        padding: const EdgeInsets.all(10.0),
                      )),
                )
              ]),
        );
    }
  }

  Widget _buildBottomView(BuildContext context) {
    switch (topBarViewState) {
      case TopBarViewState.defaultState:
        return GestureDetector(
          child: Text("${basename(this.filePath)}",
              style: Theme.of(context).textTheme.title),
          onTap: () => setState(() {
            topBarViewState = TopBarViewState.defaultState;
          }),
        );
      case TopBarViewState.lastFileSelection:
        return GestureDetector(
          child: Text("Select last opened file",
              style: TextStyle(color: Colors.black)),
          onTap: () => setState(() {
            topBarViewState = TopBarViewState.defaultState;
          }),
        );
      case TopBarViewState.createNewFile:
        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(flex: 1),
              Flexible(
                  flex: 5,
                  child: FractionallySizedBox(
                    widthFactor: 0.4,
                    heightFactor: 0.3,
                    child: Container(
                        child: TextField(
                            autofocus: true,
                            cursorColor: Colors.grey,
                            cursorWidth: 2,
                            onEditingComplete: () => _createNewFile(),
                            cursorRadius: Radius.circular(1.23),
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              hintText: 'file',
                              focusedBorder: const UnderlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 2.0),
                              ),
                              contentPadding: EdgeInsets.all(10),
                              alignLabelWithHint: true,
                              suffixText: ".org",
                              suffixStyle: Theme.of(context)
                                  .textTheme
                                  .title
                                  .copyWith(color: Colors.grey),
                            ),
//                            textAlign: (isValidName) ? TextAlign.right : TextAlign.center,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.title,
                            controller: createNewFileTextController)),
                  )),
//            Expanded(child: ,
//            Expanded(child: Container(child: Text("confirm",style: TextStyle(color: Colors.black),))),
            ]);
    }
  }

  _createNewFile() async {
//    if(Platform.isIOS){
//      throw UnimplementedError();
//    }
    String fileName = createNewFileTextController.text + ".org";
    File file = File(await _getRootDirectory() + "/" + fileName);
    if (await file.exists()) {
      Fluttertoast.showToast(msg: "File already exists");
      return;
    }
    file.create().then((f) async {
      await _storeLastOpenedFile();
      Fluttertoast.showToast(
          msg: "File written to directory ${f.absolute.path}");
      setState(() {
        filePath = f.absolute.path;
        topBarViewState = TopBarViewState.defaultState;
      });
      _parseFile();
    });
  }

  Future<String> _getRootDirectory() async {
    if (Platform.isAndroid) {
      //Android
      // Get stored path string from first startup (if empty ask again)
      // [X] 1. Use the file_picker and just select one file in your project directory
      // [ ] 2. Use folder_picker plugin
      // [ ] 3. Use your fancier version of this
      return parentPath;
      // Android-specific code
    } else if (Platform.isIOS) {
      //iOS
      // Get with getDocuments of local storage
      // Ask Bettina - what do you see when you click on the file_picker on iOS
      Directory appDocDir = await getApplicationDocumentsDirectory();
      return appDocDir.absolute.path;
      throw UnimplementedError("Not implemented for iOS yet");
    }
  }

  void _checkOnFirstStart() async {
    var prefs = await SharedPreferences.getInstance();
    String folderPath = prefs.getString('android-org-folder');
    if (folderPath == null || folderPath.isEmpty) {
      //TODO use this component only temporary since this requires you to select a file in the parent dir you want to select
      var selectedFile = await FilePicker.getFile();
      if (selectedFile != null) {
        folderPath = selectedFile.parent.absolute.path;
        prefs.setString('android-org-folder', folderPath);
      }
    }
    ;
    setState(() {
      this.parentPath = folderPath;
    });
  }
}
