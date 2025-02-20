import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

Map<String, pw.Alignment> cell_align_map = {
  "topCenter": pw.Alignment.topCenter,      // Aligns content to the top-center
  "topLeft": pw.Alignment.topLeft,          // Aligns content to the top-left
  "topRight": pw.Alignment.topRight,        // Aligns content to the top-right
  "center": pw.Alignment.center,            // Aligns content to the center (default)
  "centerLeft": pw.Alignment.centerLeft,    // Aligns content to the center-left
  "centerRight": pw.Alignment.centerRight,  // Aligns content to the center-right
  "bottomCenter": pw.Alignment.bottomCenter,// Aligns content to the bottom-center
  "bottomLeft": pw.Alignment.bottomLeft,    // Aligns content to the bottom-left
  "bottomRight": pw.Alignment.bottomRight,  // Aligns content to the bottom-right
};
// It is the Color map for selecting the color for user for pdf formatting
Map<String, Color> colorMap = {
  "Red": Colors.red,
  "Blue": Colors.blue,
  "Green": Colors.green,
  "Yellow": Colors.yellow,
  "Orange": Colors.orange,
  "Purple": Colors.purple,
  "Pink": Colors.pink,
  "Brown": Colors.brown,
  "Black": Colors.black,
  "White": Colors.white,
  "Grey": Colors.grey,
  "Cyan": Colors.cyan,
  "Teal": Colors.teal,
  "Lime": Colors.lime,
  "Amber": Colors.amber,
  "Indigo": Colors.indigo,
};
