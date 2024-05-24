import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:room_mate/view/gallery.dart';
import 'package:room_mate/view/gesture.dart';
import 'package:room_mate/view/map.dart';

/// Flutter code sample for [NavigationBar].

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentPageIndex = 0;
  bool moving = false;

  @override
  Widget build(BuildContext context) {
    // final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.lightBlue,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          NavigationDestination(
            // icon: Badge(child: Icon(Icons.photo_album_outlined)), => Badge : 위쪽에 빨간 점 표시(선택된 아이콘 표시할 때 사용 가능)
            // 갤러리에서 사진이 추가되면 빨간점 표시되게 하면 좋을듯!
            icon: Icon(Icons.photo_album_outlined),
            label: 'Gallery',
          ),
          NavigationDestination(
            icon: Icon(Icons.gesture),
            label: 'Gallery',
          ),
        ],
      ),
      body: <Widget>[
        Home(), // 맵 페이지

        Gallery(), // 갤러리 페이지

        Gesture()
      ][currentPageIndex],
    );
  }
}
