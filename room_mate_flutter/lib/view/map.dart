import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Uint8List _imageBytes = Uint8List(0); // 이미지를 저장할 변수
  // String tempImagePath = 'imgs/dog.jpg';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getImage();

    // robot에서 지도데이터 받음
    // await dio.post('http://121.147.52.9:8016/to_flutter_map_data');

    // robot에서 robot의 실시간 위치 데이터 받음
    // Timer.periodic(const Duration(seconds: 1), (timer) async {
    //   await dio.post('http://121.147.52.9:8016/to_flutter_robot_location');
    // });
  }

  Future<void> getImage() async {
    try {
      // Dio를 사용하여 이미지를 가져옴
      Response response = await dio.get(
          'http://121.147.52.9:8016/to_flutter_map_data',
          options: Options(responseType: ResponseType.bytes));

      // 가져온 이미지를 화면에 표시
      setState(() {
        _imageBytes = response.data;
        print('***hihi***' + _imageBytes.toString());
      });
    } catch (e) {
      print('Failed to load image: $e');
    }
  }

  final dio = Dio();
  bool moving = false; // 위치이동 버튼 클릭/비클릭 여부에 따라 버튼 바뀌도록 하는 boolean

  // flask로 목적지 좌표 보내는 코드 작성
  void sendDestination() {
    setState(() {
      // await dio.post('http://121.147.52.9:8016/destination',
      //     queryParameters: {'x': 12, 'y': 10});
      moving = true;
    });
  }

  // 이동 중 멈추고 싶을 때 누르면 멈추는 코드 작성
  void cancelsendDestination() {
    setState(() {
      moving = false;
    });
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // flask에서 데이터 받기
  void getFromFlask() async {
    try {
      final response = await dio.post('http://121.147.52.9:8016/send_data'
          // queryParameters: {'hong': 'cheol'}
          );
      print(response.data);
    } catch (e) {
      print('catch: $e');
    }
    print("hihi");
  }

  // flask에게 데이터 보내기
  void sendToFlask() async {
    final response = await dio.post('http://172.30.1.47:5000/id',
        queryParameters: {'id': 123, 'name': 'dio'}); // key에 value 담아서 보내기
    print(response.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Map Page"),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[200],
      ),
      body: Card(
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              // Mapping된 지도
              _imageBytes.length != 0
                  ? GestureDetector(
                      child: Image.memory(
                        _imageBytes,
                        fit: BoxFit.cover,
                      ),
                    )
                  : CircularProgressIndicator(), // 이미지 로딩 중에는 로딩 스피너를 표시,
              // Icon(
              //   Icons.map_outlined,
              //   size: 300,
              // ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: moving ? cancelsendDestination : sendDestination,
                child: Text(moving ? "이동 취소" : "지정 위치로 이동"),
              ),
              moving
                  ? Text(
                      '이동중~',
                      style: TextStyle(color: Colors.grey),
                    )
                  : ElevatedButton(
                      // ***********************나중에 "이동중"이 아니라, "집으로 돌아가는 중~" 이라는 텍스트로 만들기!!***********************
                      // ***********************sendDestination이 아닌 "집으로 돌아가는 함수" 만들기***********************
                      onPressed: () {},
                      child: Text('집으로 돌아가기'),
                    ),
              ElevatedButton(
                  onPressed: () => getFromFlask(),
                  child: Text('Flask에서 데이터 받기!')),
              ElevatedButton(
                  onPressed: () => sendToFlask(),
                  child: Text('Flask에게 데이터 보내기!!'))
            ],
          ),
        ),
      ),
    );
  }
}
