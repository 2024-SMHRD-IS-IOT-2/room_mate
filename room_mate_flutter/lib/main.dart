import 'package:flutter/material.dart';
import 'package:room_mate/view/bottom_navigation.dart';
import 'package:room_mate/view/map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: NavigationExample(),
    );
  }
}
