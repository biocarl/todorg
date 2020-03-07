import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'org_converter.dart';
import 'bullet.dart';

class OrgFileHandler {
  String fileName = "todos.org";

  OrgFileHandler(this.fileName);

  Future<File> update(List<Bullet> bullets) async {
    final file = File(fileName);
    OrgConverter converter = OrgConverter();
    String bulletString = converter.bulletsToString(bullets);
    Future<File> state = file.writeAsString(bulletString);
    return state;
  }

  Future<List<Bullet>> parse() async {
    final file = File(fileName);
    if (!(await file.exists())) {
      throw FileSystemException();
    }
    String contents = (await file.readAsLines()).join("\n");
    OrgConverter orgParser = OrgConverter();
    var tmp = orgParser.parseFromString(contents);
    return tmp;
  }
}
