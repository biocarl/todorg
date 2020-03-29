import 'package:flutter/material.dart';

Color getMainColor(int level) {
//  return Colors.blueAccent.withBlue(100);

  switch (level) {
    case 0:
    case 1:
      return Colors.white;
    case 2:
      return Colors.grey[50];
    case 3:
      return Colors.grey[100];
    case 4:
      return Colors.grey[200];
    default:
      return Colors.grey[100 * level - 200];
  }
}
