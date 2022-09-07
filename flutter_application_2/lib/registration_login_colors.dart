import 'package:flutter/material.dart';

hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

backgorud() {
  Container(
    decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
      hexStringToColor("#00dacf"),
      hexStringToColor("#fcfffd"),
      hexStringToColor("#fcfffd"),
      hexStringToColor("#fcfffd"),
      //hexStringToColor("#fcfffd"),
      hexStringToColor("#fcfffd"),
      hexStringToColor("#283466")
    ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
  );
}
