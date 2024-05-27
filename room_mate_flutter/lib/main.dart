import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:room_mate/view/bottom_navigation.dart';
import 'package:room_mate/view/map.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
  print('3');
  await Future.delayed(const Duration(seconds: 1));
  print('2');
  await Future.delayed(const Duration(seconds: 1));
  print('1');
  await Future.delayed(const Duration(seconds: 1));
  print('시작!!');
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigation(),
    );
  }
}
