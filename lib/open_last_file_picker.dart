import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OpenLastFilePicker extends StatefulWidget{
  final Function(String selectedFile) onSelection;

  OpenLastFilePicker({this.onSelection});

  @override
  State<StatefulWidget> createState() {
    return _OpenLastFilePickerState();
  }
}

class _OpenLastFilePickerState extends State<OpenLastFilePicker>{
  int selectedFileIndex = 0;
  List<String> lastOpenedFiles = [];

  _getLastOpenedFiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> files = prefs.getString('last-opended').split(" ");
    setState(() {
      lastOpenedFiles = files.sublist(1); // Do not show currently open file itself
    });
  }

  _buildLastOpenedFilesItems() {
    List<Widget> widgets = List();
    lastOpenedFiles.forEach((fileString) => widgets.add(Text(
        "${basename(fileString)}",
        style: TextStyle(color: Colors.black, fontSize: 25))));
    return widgets;
  }

  @override
  void initState() {
    super.initState();
    _getLastOpenedFiles();
  }

  @override
  Widget build(BuildContext context) {
    if(lastOpenedFiles.isEmpty){
      return Container();
    }

    return GestureDetector(
      onTap: () async {
        this.widget.onSelection(lastOpenedFiles[selectedFileIndex]);
      },
      child: SizedBox(
        height: 100,
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          useMagnifier: true,
          onSelectedItemChanged: (int index) => selectedFileIndex = index,
          children: _buildLastOpenedFilesItems(),
          itemExtent: 30, //height of each item
          looping: false,
        ),
      ),
    );
  }
}
