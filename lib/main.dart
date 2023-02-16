import 'package:flutter/material.dart';
import 'package:r_player/player.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(home: Player()));
}

