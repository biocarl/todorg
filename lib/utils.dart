import 'package:flutter/services.dart' show rootBundle;

import 'bullet.dart';
import 'org_converter.dart';

// For debugging
Future<List<Bullet>> loadDebugData() async {
  print("Debug mode");
  var file = await _getFileData("assets/test.org");
  OrgConverter orgConverter = new OrgConverter();
  List<Bullet> bullets = orgConverter.parseFromString(file);
  return bullets;
}

Future<String> _getFileData(String path) async {
  return await rootBundle.loadString(path);
}
