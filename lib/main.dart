import 'package:flutter/material.dart';
import 'game_screen.dart';

void main() {
  runApp(XOGameApp());
}

class XOGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XO Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GameScreen(),
    );
  }
}
