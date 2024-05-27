import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final dio = Dio();
  late Future<List<String>> _imageUrls = getImageUrls();
  List selected = []; // boolean List : 선택 됐는지 안됐는지 확인
  Set selectedList = {}; // 선택된 사진들 담는 set
  bool visibleButton = false; // 사진 선택 전에 버튼 안보이도록
  Key key = UniqueKey(); // 화면 새로고침 하기위한 key

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initState에서는 async-await 못쓰니 .then 사용하면 된다!!
    _imageUrls.then((value) {
      int length = value.length;
      print("List 길이 :" + length.toString());
      selected = List.filled(length, false);
      print(selected);
    });
  }

  Future<List<String>> getImageUrls() async {
    try {
      final response = await Dio().get('http://121.147.52.9:8016/get_photos');
      if (response.statusCode == 200) {
        final imageUrls = List<String>.from(response.data);
        print("사진들: " + imageUrls.toString());
        return imageUrls;
      } else {
        throw Exception('연결(200) 실패');
      }
    } catch (e) {
      throw Exception('이미지 불러오는데 실패...: $e');
    }
  }

  // 삭제버튼 눌렀을 때 삭제할 사진 set를 flask로 보내기
  void deletePhotos() async {
    final response = await dio.post('http://121.147.52.9:8016/delete_photos',
        data: {'photos': selectedList.toList()});

    if (response.statusCode == 200) {
      setState(() {
        _imageUrls = getImageUrls();
        _imageUrls.then((value) {
          int length = value.length;
          selected = List.filled(length, false);
          print(selected);
        });
        refreshCurrentPage();
        print('삭제 성공!');
        visibleButton = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 삭제 실패...')),
      );
    }

    // print(response.data['message']);
  }

  void refreshCurrentPage() {
    setState(() {
      key = UniqueKey();
    });
  }

  /////////////////////////////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 50,
        title: Text(
          "Gallery",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Container(
        key: key,
        child: Stack(
          children: [
            FutureBuilder<List<String>>(
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
                          print("체크된 리스트들!!" + selectedList.toString());
                          setState(() {});
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Stack(children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              child: Image.network(
                                snapshot.data![index],
                                fit: BoxFit.cover,
                              ),
                            ),
                            selected[index]
                                ? Positioned(
                                    right: 10,
                                    child: Icon(
                                      Icons.check_circle,
                                      color: Colors.lightBlue,
                                    ),
                                  )
                                : Positioned(
                                    right: 10,
                                    child: Icon(
                                      Icons.circle,
                                      color: Colors.grey[200],
                                    ),
                                  )
                          ]),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('사진 데이터 가져오기 실패 : ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Visibility(
                visible: visibleButton,
                child: ElevatedButton(
                  onPressed: () => deletePhotos(),

                  // 버튼 누르면 새로고침 되도록 -> 근데 첫 화면으로 돌아가버림. -> UniqueKey() 이용!
                  // Navigator.pushReplacement(
                  //   context,
                  //   PageRouteBuilder(
                  //     pageBuilder: (context, animation1, animation2) =>
                  //         BottomNavigation(),
                  //     transitionDuration: Duration(seconds: 0),
                  //   ),
                  // );

                  child: Text(
                    '선택 사진 삭제',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.lightBlue[800]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
