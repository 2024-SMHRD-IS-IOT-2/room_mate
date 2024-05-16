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
  bool selected = false;
  List selectedList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _imageUrls = getImageUrls();
  }

  @override
  Widget build(BuildContext context) {
    // aws에서 불러온 사진리스트
    List<String> photoList = [];

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
                  return SingleChildScrollView(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selected = true;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              snapshot.data![index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
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
            visible: selected,
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
      print("사진들: " + response.data.toString());
      return imageUrls;
    } else {
      throw Exception('Failed to fetch image URLs');
    }
  } catch (e) {
    throw Exception('Failed to fetch image URLs: $e');
  }
}
