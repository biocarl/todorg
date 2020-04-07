import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tudorg/open_last_file_picker.dart';
import 'package:tudorg/theme.dart';
import 'package:tudorg/view_states.dart';

class TopBar extends StatefulWidget {
  final bool needsUpdate;
  final TopBarViewState topBarViewState;
  final Function(TopBarViewState state) switchState;
  final Function(String lastFile) onLastFileSelected;
  final Function() onOpenExistingFile;
  final Function(String fileName) onCreateNewFile;
  final String currentFileName;
  TopBar(
      {this.needsUpdate,
      this.topBarViewState,
      this.switchState,
      this.onLastFileSelected,
      this.onOpenExistingFile,
      this.onCreateNewFile,
      this.currentFileName});

  @override
  State<StatefulWidget> createState() {
    return _TopBarState();
  }
}

class _TopBarState extends State<TopBar> {
  // Wrap in widget
  final createNewFileTextController = TextEditingController();
  var isValidName = false;

  @override
  void initState() {
    super.initState();
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
    return SliverAppBar(
      expandedHeight: (widget.topBarViewState != TopBarViewState.defaultState)
          ? 190.0
          : 140,
      backgroundColor:
          widget.needsUpdate ? Colors.orangeAccent : getMainColor(0),
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
                child: Padding(padding: EdgeInsets.symmetric(vertical: 30.0))),
            _buildMiddleView(),
          ],
        ),
      ),
    );
  }

  Widget _buildMiddleView() {
    switch (widget.topBarViewState) {
      case TopBarViewState.defaultState:
        return Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                  child: IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () =>
                    widget.switchState(TopBarViewState.createNewFile),
                highlightColor: Colors.orangeAccent,
                color: Colors.black,
              )),
              GestureDetector(
                  child: IconButton(
                    icon: Icon(Icons.folder_open),
                    onPressed: widget.onOpenExistingFile,
                    highlightColor: Colors.orangeAccent,
                    color: Colors.black,
                  ),
                  onLongPress: () =>
                      widget.switchState(TopBarViewState.lastFileSelection))
            ],
          ),
        );
      case TopBarViewState.lastFileSelection:
        return OpenLastFilePicker(
          onSelection: (lastFileSelection) =>
              widget.onLastFileSelected(lastFileSelection),
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
                        onPressed: () => widget.onCreateNewFile(_getFileName()),
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
    switch (widget.topBarViewState) {
      case TopBarViewState.defaultState:
        return GestureDetector(
            child: Text(widget.currentFileName,
                style: Theme.of(context).textTheme.title),
            onTap: () => widget.switchState(TopBarViewState.defaultState));
      case TopBarViewState.lastFileSelection:
        return GestureDetector(
          child: Text("Select last opened file",
              style: TextStyle(color: Colors.black)),
          onTap: () => widget.switchState(TopBarViewState.defaultState),
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
                            onEditingComplete: () =>
                                widget.onCreateNewFile(_getFileName()),
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

  String _getFileName() {
    return createNewFileTextController.text + ".org";
  }
}
