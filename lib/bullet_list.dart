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
      _unfoldFromDocumentRoot();
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
        key: Key(bullet.title), // TODO what happens if the title is not unique?
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.20,
        child: BulletContainer(
          bullet: bullet,
          isCollapsed: _isCollapsed(bullet),
          hasChildren: _hasChildren(bullet),
          onTap: () {
            if(bullet.isTodo && !_hasChildren(bullet)){
              _checkBullet(!bullet.isChecked, bullet);
            }else{
              _handleFold(bullet);
            }
          },
          onEditBullet: () => _editBullet(context, bullet),
          onCheckboxChange: (bullet.isTodo)
              ? (checkValue) => _checkBullet(checkValue, bullet)
              : null,
        ),
        movementDuration: const Duration(milliseconds: 100),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Promote',
            foregroundColor: Colors.grey[500],
            icon: Icons.format_indent_decrease,
            onTap: () => _changeBulletLevelOfSubtree(bullet, -1),
          ),
          IconSlideAction(
            caption: 'Demote',
            foregroundColor: Colors.grey[500],
            icon: Icons.format_indent_increase,
            onTap: () => _changeBulletLevelOfSubtree(bullet, 1),
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
            foregroundColor: Colors.green,
            icon: Icons.archive,
            onTap: () => _moveBulletToEnd(bullet),
          ),
          IconSlideAction(
            caption: 'Delete',
            foregroundColor: Colors.red,
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
      int numberOfChildren = _getIndexOfLastChild(oldIndex) - oldIndex;

      // Adapt new levels of subtree BEFORE moving
      int levelDeltaOfParent = _determineNewLevelAfterRelocation(newIndex) -
          _bulletList[oldIndex].level;
      _changeBulletLevelOfSubtree(_bulletList[oldIndex], levelDeltaOfParent);

      // Account for index shift
      if (oldIndex < newIndex) {
        newIndex -= 1 + numberOfChildren;
      }

      // Cut & paste subtree
      var replaceWidgets =
          _bulletList.sublist(oldIndex, oldIndex + numberOfChildren + 1);
      _bulletList.removeRange(oldIndex, oldIndex + numberOfChildren + 1);
      _bulletList.insertAll(newIndex, replaceWidgets);
      this.widget._onUpdate();
    });
  }

  int _determineNewLevelAfterRelocation(int bulletIndex) {
    // Do clone from next previous sibling which is visible
    int lowerBound = bulletIndex - 1;
    while (lowerBound > 0) {
      final Bullet prev = _bulletList[lowerBound];
      if (prev.isVisible) {
        if (!_hasChildren(prev)) {
          return _bulletList[lowerBound].level;
        } else {
          if (_isCollapsed(prev)) {
            return _bulletList[lowerBound].level;
          } else {
            return _bulletList[lowerBound].level +
                1; // A bullet which moved as direct child of a expanded parent will get a +1 rank relative to it, alternative: Copy level of sibling below
          }
        }
      }
      lowerBound--;
    }
    // First element in list is always root sibling
    return 1;
  }

  bool _hasChildren(Bullet bullet) {
    int position = _bulletList.indexOf(bullet);
    if (position == _bulletList.length - 1) {
      return false;
    }
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

  void _unfoldFromDocumentRoot() {
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

  void _moveBulletToEnd(Bullet bullet) {
    int position = _bulletList.indexOf(bullet);
    _moveSubtree(position, _bulletList.length);
    Fluttertoast.showToast(msg: "Bullet moved to end of file.");
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

  _changeBulletLevelOfSubtree(Bullet bullet, int levelDelta) {
    // No change
    if (levelDelta == 0) {
      return;
    }

    // Level 0 and beyond are not allowed TODO give visual feedback - wobbling effect
    if ((bullet.level + levelDelta) <= 0) {
      return;
    }

    int start = _bulletList.indexOf(bullet);
    int end = _getIndexOfLastChild(start);

    setState(() {
      for (int i = start; i <= end; i++) {
        _bulletList[i].level += levelDelta;
      }
    });
    Fluttertoast.showToast(msg: (levelDelta < 0) ? "Promoted" : "Demoted");
  }

  _handleFold(Bullet bullet) {
    if (bullet == _bulletList.last) {
      return;
    }
    int position = _bulletList.indexOf(bullet);
    //Check if bullet is already folded or not
    if (_bulletList[position + 1].isVisible) {
      _foldBullet(bullet);
    } else {
      _unfoldBullet(bullet);
    }
  }

  _editBullet(BuildContext context, Bullet bullet) async {
    Bullet bulletEdited = await getBulletFromUser(context, bullet);
    if (bulletEdited != null && bulletEdited != bullet) {
      setState(() {
        int position = _bulletList.indexOf(bullet);
        _bulletList.remove(bullet);
        _bulletList.insert(position, bulletEdited);
        this.widget._onUpdate();
      });
    }
  }

  _checkBullet(checkValue, Bullet bullet) {
    setState(() {
      bullet.isChecked = checkValue;
      this.widget._onUpdate();
    });
  }
}
