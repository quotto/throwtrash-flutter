import 'package:flutter/material.dart';

Color trashColor(String trashType, Brightness brightness) {
  switch(trashType) {
    case "burn":
      return brightness == Brightness.light ? Colors.red : Colors.red.shade400;
    case "unburn":
      return brightness == Brightness.light ? Colors.blue : Colors.blue.shade600;
    case "plastic":
      return brightness == Brightness.light ? Colors.green : Colors.green.shade400;
    case "bin":
      return brightness == Brightness.light ? Colors.orange : Colors.orange.shade800;
    case "can":
      return brightness == Brightness.light ? Colors.pink : Colors.pink.shade400;
    case "petbottle":
      return brightness == Brightness.light ? Colors.lightGreen : Colors.lightGreen.shade700;
    case "paper":
      return brightness == Brightness.light ? Colors.brown : Colors.brown.shade400;
    case "resource":
      return brightness == Brightness.light ? Colors.teal : Colors.teal.shade400;
    case "coarse":
      return brightness == Brightness.light ? Colors.deepOrangeAccent : Colors.deepOrange;
    case "other":
      return brightness == Brightness.light ? Colors.grey : Colors.grey.shade800;
    default:
      return brightness == Brightness.light ? Colors.grey : Colors.grey.shade800;
  }
}
