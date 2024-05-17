import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  late Future<List<String>> _imageUrls;
  List selected = []; // boolean List : 선택 됐는지 안됐는지 확인
  Set selectedList = {}; // 선택된 사진들 담는 set
  bool visibleButton = false; // 사진 선택 전에 버튼 안보이도록

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageUrls = getImageUrls();

    // initState에서는 async-await 못쓰니 .then 사용하면 된다!!
    _imageUrls.then((value) {
      int length = value.length;
      print("List 길이 :" + length.toString());
      selected = List.filled(length, false);
      print(selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppBar(
              toolbarHeight: 50,
              title: Text(
                "Gallery",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
              ),
              centerTitle: true,
              backgroundColor: Colors.lightBlue[300],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _imageUrls,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return GridView.builder(
                    // shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          selected[index] = !selected[index];
                          if (selected[index]) {
                            selectedList.add(snapshot.data![index]);
                          } else {
                            selectedList.remove(snapshot.data![index]);
                          }

                          if (selectedList.length != 0) {
                            visibleButton = true;
                          } else {
                            visibleButton = false;
                          }
                          print(selected);
                          print("리스트들!!" + selectedList.toString());
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.network(
                            snapshot.data![index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
          Visibility(
            visible: visibleButton,
            child: ElevatedButton(
              onPressed: () {},
              child: Text('선택 사진 삭제'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<List<String>> getImageUrls() async {
  try {
    final response = await Dio().get('http://121.147.52.9:8016/get_photos');
    if (response.statusCode == 200) {
      final imageUrls = List<String>.from(response.data);
      print("사진들: " + imageUrls.toString());
      return imageUrls;
    } else {
      throw Exception('Failed to fetch image URLs');
    }
  } catch (e) {
    throw Exception('Failed to fetch image URLs: $e');
  }
}
