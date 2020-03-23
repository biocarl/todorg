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
import 'bullet_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
          color: Colors.blue,
          child: NestedScrollView(headerSliverBuilder:
              (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: 200.0,
                backgroundColor:
                    needsUpdate ? Colors.orangeAccent : Colors.blue,
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
                          children: _buildBulletTree(context),
                          onReorder: (oldIndex, newIndex) =>
                              _moveSubtree(oldIndex, newIndex),
                        )),
                  ),
                ]);
          }))),
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

        setState(() {
          print("Setting new state");
          this.bulletList = parsedBullets;
          this.needsUpdate = false;
        });
      } else {
        throw FileSystemException();
      }
    } on FileSystemException {
      print("File does not exist (or is not valid)");
    }
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

  Future<void> _updateOrgFile() async {
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

  int _determineNewLevelAfterRelocation(int bulletIndex) {
    //In bounds: Copy from previous node
    if (bulletIndex > 0 && bulletIndex < bulletList.length) {
      return bulletList[bulletIndex - 1].level;
    }
    // For first element is root sibling
    return 1;
  }

  int _getIndexOfLastChild(int rootIndex) {
    int index = rootIndex;
    while (index + 1 < bulletList.length &&
        bulletList[index + 1].level > bulletList[rootIndex].level) {
      print("Root: ${bulletList[rootIndex].level}");
      print("Next: ${bulletList[index + 1].level}");
      index++;
    }
    return index;
  }

  void _foldBullet(Bullet root) {
    int position = bulletList.indexOf(root);
    setState(() {
      int index = position + 1;
      while (
          index < bulletList.length && bulletList[index].level > root.level) {
        bulletList[index].isVisible = false;
        index++;
      }
    });
  }

  void _unfoldBullet(Bullet root) {
    int position = bulletList.indexOf(root);
    int maxChildLevel =
        0; //Defines the currently highest bullet level < root.level. Bullets which a level smaller than maxChildLevel are collapsed
    int index = position + 1;

    setState(() {
      //Is child
      while (
          index < bulletList.length && bulletList[index].level > root.level) {
        /*

        Determine the direct children of root (possibly with not defined hierarchies in between)

        * Title (Root)
        **** Title (see 1.)
          ***** Title (hidden)
        *** Title (see 3.)
        *** Title (see 2.)

        1. First child after root is always visible
        2. A sibling also has to be visible
        3. A child which is higher up in the hierarchy than the previous highest visible child also has to be visible

        */
        if (maxChildLevel == 0 ||
            bulletList[index].level == maxChildLevel ||
            bulletList[index].level < maxChildLevel) {
          bulletList[index].isVisible = true;
          maxChildLevel = bulletList[index].level;
        } // Is indirect child and therefore hidden TODO we can assume that bullet is already hidden by default
        else if (bulletList[index].level > maxChildLevel) {
          bulletList[index].isVisible = false;
        }
        index++;
      }
    });
  }

  void _deleteBullet(Bullet bullet) {
    setState(() {
      bulletList.remove(bullet);
      this.needsUpdate = true;
      Fluttertoast.showToast(msg: "Todo Deleted!");
    });
  }

  _changeBulletLevel(Bullet bullet, int levelDelta) {
    setState(() {
      int position = bulletList.indexOf(bullet);
      bulletList[position].level += levelDelta;
    });
    Fluttertoast.showToast(msg: "Promoted");
  }

  List<Widget> _buildBulletTree(BuildContext context) {
    List<Widget> list = new List();
    for (final bullet in bulletList) {
      list.add(Slidable(
        key: Key(bullet.title),
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: BulletContainer(
            bullet: bullet,
            onFold: () => _handleFold(bullet),
            onDoubleTap: () => _editBullet(context, bullet),
            onCheckboxChange: (checkValue) {
              setState(() {
                if (!checkValue) {
                  bullet.isChecked = false;
                } else {
                  bullet.isChecked = true;
                }
                this.needsUpdate = true;
              });
            }),
        movementDuration: const Duration(milliseconds: 200),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Promote',
            color: Colors.grey[100],
            icon: Icons.format_indent_decrease,
            onTap: () => _changeBulletLevel(bullet, -1),
          ),
          IconSlideAction(
            caption: 'Demote',
            color: Colors.grey[100],
            icon: Icons.format_indent_increase,
            onTap: () => _changeBulletLevel(bullet, 1),
          ),
        ],
        dismissal: SlidableDismissal(
          dismissThresholds: <SlideActionType, double>{
            SlideActionType.primary: 1.0
          },
          child: SlidableDrawerDismissal(),
          onDismissed: (actionType) => _deleteBullet(bullet),
        ),
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Archive',
            color: Colors.green,
            icon: Icons.archive,
            onTap: () => Fluttertoast.showToast(msg: "Not supported yet"),
          ),
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => _deleteBullet(bullet),
          ),
        ],
      ));
    }
    return list;
  }

  _handleFold(Bullet bullet) {
    if (bullet == bulletList.last) {
      return;
    }
    int position = bulletList.indexOf(bullet);
    //Check if bullet is already folded or not
    if (bulletList[position + 1].isVisible) {
      print("fold");
      _foldBullet(bullet);
    } else {
      _unfoldBullet(bullet);
    }
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (kReleaseMode) {
        _loadLastFile();
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
    var inputText = await _getTextFromUser(context, "");
    setState(() {
      if (inputText != null && inputText.isNotEmpty) {
        //TODO move this to org_handler/converter
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

  _moveSubtree(int oldIndex, int newIndex) {
    setState(() {
      int diff = _getIndexOfLastChild(oldIndex) - oldIndex;
      if (oldIndex < newIndex) {
        newIndex -= 1 + diff;
      }else{
        print("Other case");
      }

      var replaceWigets = bulletList.sublist(oldIndex, oldIndex+diff + 1);
      bulletList.removeRange(oldIndex, oldIndex+diff + 1);

      bulletList.insertAll(newIndex, replaceWigets);
      //TODO if there is a subtree adapt all ranks relative to new root rank
      // For now rank is adapted when for single node is moved
      if(replaceWigets.length == 1) {
        bulletList[newIndex].level =
            _determineNewLevelAfterRelocation(newIndex);
      }
      this.needsUpdate = true;
    });
  }

  _editBullet(BuildContext context, Bullet bullet) {
    // Edit existing bullet
    _getTextFromUser(context, bullet.title).then((inputText) {
      setState(() {
        if (inputText != null && inputText.isNotEmpty) {
          int position = bulletList.indexOf(bullet);
          bulletList.remove(bullet);
          bullet.title = inputText;
          bulletList.insert(position, bullet);
          this.needsUpdate = true;
        }
      });
    });
  }
}
