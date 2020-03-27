import 'package:flutter/material.dart';
import 'package:tudorg/bullet.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'bullet.dart';
import 'bullet_container.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'edit_bullet.dart';

class BulletList extends StatefulWidget {
  List<Bullet> _bulletList;
  Function _onSave;
  Function _onUpdate;

  BulletList({Function onSave, List<Bullet> bulletList, Function onUpdate}) {
    this._bulletList = bulletList;
    this._onSave = onSave;
    this._onUpdate = onUpdate;
  }

  @override
  _BulletListState createState() {
    return _BulletListState();
  }
}

class _BulletListState extends State<BulletList> {
  // Init stateful things in here
  List<Bullet> _bulletList = [];

  @override
  void didUpdateWidget(BulletList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget?._bulletList != null && _bulletList != widget._bulletList) {
      _bulletList = widget._bulletList;
      _unfoldFromRoot();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: new RefreshIndicator(
                  onRefresh: this.widget._onSave,
                  child: ReorderableListView(
                    children: _buildBulletTree(context),
                    onReorder: (oldIndex, newIndex) =>
                        _moveSubtree(oldIndex, newIndex),
                  )),
            ),
          ]);
    });
  }

  List<Widget> _buildBulletTree(BuildContext context) {
    List<Widget> list = new List();
    for (final bullet in _bulletList) {
      list.add(Slidable(
        key: Key(bullet.title),
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: BulletContainer(
            bullet: bullet,
            isCollapsed: _isCollapsed(bullet),
            hasChildren: _hasChildren(bullet),
            onFold: () => _handleFold(bullet),
            onDoubleTap: () => _editBullet(context, bullet),
            onCheckboxChange: (checkValue) {
              setState(() {
                if (!checkValue) {
                  bullet.isChecked = false;
                } else {
                  bullet.isChecked = true;
                }
                this.widget._onUpdate();
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

  _moveSubtree(int oldIndex, int newIndex) {
    setState(() {
      print("old: ${oldIndex}, new: ${newIndex}");
      int diff = _getIndexOfLastChild(oldIndex) - oldIndex;
      print(diff);
      if (oldIndex < newIndex) {
        newIndex -= 1 + diff;
      } else {
        print("Other case");
      }

      print("old: ${oldIndex}, new: ${newIndex}");

      var replaceWigets = _bulletList.sublist(oldIndex, oldIndex + diff + 1);
      _bulletList.removeRange(oldIndex, oldIndex + diff + 1);

      _bulletList.insertAll(newIndex, replaceWigets);
      //TODO if there is a subtree adapt all ranks relative to new root rank
      // For now rank is adapted when for single node is moved
      if (replaceWigets.length == 1) {
        _bulletList[newIndex].level =
            _determineNewLevelAfterRelocation(newIndex);
      }
      this.widget._onUpdate();
    });
  }

  int _determineNewLevelAfterRelocation(int bulletIndex) {
    //In bounds: Copy from previous node
    if (bulletIndex > 0 && bulletIndex < _bulletList.length) {
      return _bulletList[bulletIndex - 1].level;
    }
    // For first element is root sibling
    return 1;
  }

  bool _hasChildren(Bullet bullet) {
    int position = _bulletList.indexOf(bullet);
    if (position == _bulletList.length - 1) {
      return false;
    }

//    if(bullet.description.isNotEmpty){ //also counts as children
//      return true;
//    }

    return bullet.level < _bulletList[position + 1].level;
  }

  bool _isCollapsed(Bullet bullet) {
    if (_hasChildren(bullet)) {
      int position = _bulletList.indexOf(bullet);
      return !(_bulletList[position + 1].isVisible);
    }
    return false;
  }

  int _getIndexOfLastChild(int rootIndex) {
    int index = rootIndex;
    while (index + 1 < _bulletList.length &&
        _bulletList[index + 1].level > _bulletList[rootIndex].level) {
      index++;
    }
    return index;
  }

  void _foldBullet(Bullet root) {
    int position = _bulletList.indexOf(root);
    setState(() {
      int index = position + 1;
      while (
          index < _bulletList.length && _bulletList[index].level > root.level) {
        _bulletList[index].isVisible = false;
        index++;
      }
    });
  }

  void _unfoldBullet(Bullet root) {
    int position = _bulletList.indexOf(root);
    _unfoldByIndex(position, root.level);
  }

  //Showing only highest hierarchy (on startup)
  void _unfoldFromRoot() {
    _unfoldByIndex(-1, 0);
  }

  //Unfold the next hierarchy coming after the bullet with position
  void _unfoldByIndex(int position, int rootLevel) {
    int maxChildLevel =
        0; //Defines the currently highest bullet level < root.level. Bullets which a level smaller than maxChildLevel are collapsed
    int index = position + 1;

    setState(() {
      //Is child
      while (
          index < _bulletList.length && _bulletList[index].level > rootLevel) {
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
            _bulletList[index].level == maxChildLevel ||
            _bulletList[index].level < maxChildLevel) {
          _bulletList[index].isVisible = true;
          maxChildLevel = _bulletList[index].level;
        } // Is indirect child and therefore hidden TODO we can assume that bullet is already hidden by default
        else if (_bulletList[index].level > maxChildLevel) {
          _bulletList[index].isVisible = false;
        }
        index++;
      }
    });
  }

  void _deleteBullet(Bullet bullet) {
    setState(() {
      int position = _bulletList.indexOf(bullet);
      int deleteToIndex = _getIndexOfLastChild(position);
      _bulletList.removeRange(position, deleteToIndex + 1);
      this.widget._onUpdate();
      Fluttertoast.showToast(msg: "Bullet Deleted!");
    });
  }

  _changeBulletLevel(Bullet bullet, int levelDelta) {
    setState(() {
      int position = _bulletList.indexOf(bullet);
      _bulletList[position].level += levelDelta;
    });
    Fluttertoast.showToast(msg: "Promoted");
  }

  _handleFold(Bullet bullet) {
    if (bullet == _bulletList.last) {
      return;
    }
    int position = _bulletList.indexOf(bullet);
    //Check if bullet is already folded or not
    if (_bulletList[position + 1].isVisible) {
      print("fold");
      _foldBullet(bullet);
    } else {
      _unfoldBullet(bullet);
    }
  }

  _editBullet(BuildContext context, Bullet bullet) {
    // Edit existing bullet
    getTextFromUser(context, bullet.title).then((inputText) {
      setState(() {
        if (inputText != null && inputText.isNotEmpty) {
          int position = _bulletList.indexOf(bullet);
          _bulletList.remove(bullet);
          bullet.title = inputText;
          _bulletList.insert(position, bullet);
          this.widget._onUpdate();
        }
      });
    });
  }
}
