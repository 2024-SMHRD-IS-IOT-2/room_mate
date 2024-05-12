import 'package:flutter/material.dart';
import 'package:room_mate/view/gallery.dart';
import 'package:room_mate/view/map.dart';

/// Flutter code sample for [NavigationBar].

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
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
        ],
      ),
      body: <Widget>[
        Home(), // 맵 페이지

        Gallery(), // 갤러리 페이지
      ][currentPageIndex],
    );
  }
}
