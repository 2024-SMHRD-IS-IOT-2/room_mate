// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';

import '../model/touch_paint.dart';
import '../model/touch_painter.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dio = Dio();
  bool moving = false; // 위치이동 버튼 클릭/비클릭 여부에 따라 버튼 바뀌도록 하는 boolean
  Uint8List _imageBytes = Uint8List(0); // 이미지를 저장할 변수
  Offset? _destination; // 내가 찍은 좌표
  Offset? _robotCurrentLocation; // 로봇 실시간 위치
  Offset homedestination = Offset(100.0, 50.0); // 집 좌표
  bool buttonState = false; // true일 때 cancel icon과 이동중~ text가 나옴
  String serverUrl = "http://121.147.52.9:8016";
  bool homePoint = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initialization();
    getImage();
    Timer.periodic(Duration(seconds: 2), (timer) {
      fetchCoordinate();
    });
  }

  Future<void> getImage() async {
    try {
      // Dio를 사용하여 이미지를 가져옴
      // print("이미지 가져오기 전");
      Response response = await dio.get('$serverUrl/to_flutter_map_data',
          options: Options(responseType: ResponseType.bytes));
      // print('이미지 가져오기 성공!');

      // 가져온 이미지를 화면에 표시
      setState(() {
        _imageBytes = response.data;
        print('지도 이미지 : ' + _imageBytes.toString());
      });
    } catch (e) {
      print('지도 이미지 불러오기 실패 : $e');
    }
  }

  // flask로 목적지 좌표 보내는 코드 작성
  void sendDestination() async {
    try {
      // final response = await dio.post('$serverUrl/destination',
      //     data: {'signal': true, 'x': 0.0, 'y': 0.0});
      final response = await dio.post('$serverUrl/destination', data: {
        'signal': true,
        'x': mapValue(_destination!.dy.toDouble(), 0, 700,-0.6, 11.0),
        'y': mapValue(_destination!.dx.toDouble(), 0, 400, -0.5, 8.0)
      });
      print("************************좌표값 보냄!!" + response.data.toString());
      setState(() {
        moving = true;
      });
    } catch (e) {
      print('좌표값 보내기 실패 ㅠㅠ');
    }
  }

  // 집을 가는 코드 작성
  void goToHome() async {
    try {
      // final response = await dio.post('$serverUrl/destination',
      //     data: {'signal': true, 'x': 0.0, 'y': 0.0});
      final response = await dio.post('$serverUrl/destination',
          data: {'signal': true, 'x': 0.1, 'y': 0.0});
      print("************************집으로 보냄!!" + response.data.toString());
      setState(() {
        // CurrentLocation(destination: Offset(0,0), robotCurrentLocation: _robotCurrentLocation);
        // _destination = Offset(0,0);
        moving = true;
        buttonState = true;
        homePoint = true;
      });
    } catch (e) {
      print('좌표값 보내기 실패 ㅠㅠ');
    }
  }

  // 이동 중 멈추고 싶을 때 누르면 멈추는 코드 작성
  void cancelsendDestination() {
    _destination = null;
    dio.post('$serverUrl/stop', data: {'stop_signal': 'stop'});
    setState(() {
      moving = false;
      buttonState = false;
      homePoint = false;
    });
  }

  Future<void> fetchCoordinate() async {
    try {
      var response = await dio.post('$serverUrl/to_flutter_robot_location');
      if (response.data != null) {
        response.data['x'] = response.data['x'].toDouble();
        response.data['y'] = response.data['y'].toDouble();
        if(this.mounted) {
          setState(() {
          _robotCurrentLocation =
              Offset(response.data['x'], response.data['y']);
          // print("로봇값 넣은거" + _robotCurrentLocation.toString());
          if (_robotCurrentLocation != null || _destination != null) {
            // double tempRobotX = _robotCurrentLocation!.dx.toInt().toDouble();
            // double tempRobotY = _robotCurrentLocation!.dy.toInt().toDouble();
            // _robotCurrentLocation = Offset(tempRobotX, tempRobotY);
            double robotLocationX =
            mapValue(_robotCurrentLocation!.dy, -0.6, 13.5, 0, 700);
            double robotLocationY =
            mapValue(_robotCurrentLocation!.dx, -0.5, 5.8, 0, 400);
            _robotCurrentLocation = Offset(robotLocationX.toInt().toDouble(),
                robotLocationY.toInt().toDouble());
            print("현재 로봇 위치 : " + _robotCurrentLocation!.toString());

            print("목적지!!" + _destination!.toString());
            if ((_robotCurrentLocation!.dx.toInt() - 40 <=
                _destination!.dx.toInt() &&
                _destination!.dx.toInt() <=
                    _robotCurrentLocation!.dx.toInt() + 40) &&
                (_robotCurrentLocation!.dy.toInt() - 40 <=
                    _destination!.dy.toInt() &&
                    _destination!.dy.toInt() <=
                        _robotCurrentLocation!.dy.toInt() + 40)) {
              print("*************************************************도착!!");
              moving = false;
              myDialog(context);
              _destination = null;
            }
          }
        });
        }
      } else {
        print("로봇값 null");
      }
    } catch (e) {
      print("로봇 현재 위치 불러오기 실패 : $e");
    }
  }

  void myDialog(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 15),
              Image.asset(
                'imgs/splash_image.png',
                // height: 100,
              ),
              const Text(
                "룸메이트가 도착지에 도착했습니다!",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                  onPressed: () {
                    homePoint = false;
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '확인',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 13, 95, 189)),
                  ))
            ],
          ),
        );
      },
    );
  }

// 지도 좌표 범위 바꿔주는 함수!
  double mapValue(
      double value, double start1, double stop1, double start2, double stop2) {
    return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 50,
        title: Text(
          "Map",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Stack(
        // alignment: ,
        children: [
          // Mapping된 지도
          _imageBytes.length != 0
              ? Positioned.fill(
                  child: moving
                      // 움직이고 있을 땐, 포인트 안찍히도록!
                      ? Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: MemoryImage(_imageBytes),
                                  fit: BoxFit.fill)),
                          child: CurrentLocation(destination: homePoint
                              ? _destination=Offset(60,70)
                              : _destination, robotCurrentLocation: _robotCurrentLocation),
                        )
                      // 안움직이고 있을 땐, 포인트 찍히도록!
                      : GestureDetector(
                          onTapDown: (TapDownDetails details) {
                            setState(() {
                              // 터치된 위치를 화면의 좌표로 변환하여 바뀜
                              RenderBox referenceBox =
                                  context.findRenderObject() as RenderBox;
                              _destination = referenceBox
                                  .globalToLocal(details.globalPosition);
                              _destination = Offset(
                                  _destination!.dx.toInt().toDouble(),
                                  _destination!.dy.toInt().toDouble() - 90);
                              buttonState = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: MemoryImage(_imageBytes),
                                    fit: BoxFit.fill)),
                            child: CurrentLocation(destination: _destination, robotCurrentLocation: _robotCurrentLocation),
                          ),
                        ),
                )
              : Center(
                  child: CircularProgressIndicator()), // 이미지 로딩 중에는 로딩 스피너를 표시,

          // 각종 버튼들
          Positioned(
            bottom: 20,
            // left: 0,
            right: 10,
            child: Column(
              children: [
                Visibility(
                  visible: buttonState,
                  child: ElevatedButton(
                      style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(Size(70, 40))),
                      onPressed:
                          moving ? cancelsendDestination : sendDestination,
                      // ***** 집에 도착하면 X버튼 사라지게 하기 *****
                      child: moving
                          ? Icon(
                              Icons.cancel,
                              color: Colors.lightBlue[500],
                            )
                          : Image.asset(
                              'imgs/target.png',
                              height: 30,
                              width: 30,
                            )
                      // Text(moving ? "이동 취소" : "지정 위치로 이동"),
                      ),
                ),
                moving
                    ? Text(
                        '이동중~',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      )
                    : ElevatedButton(
                        style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all(Size(70, 40))),
                        onPressed: () => goToHome(),
                        child: Icon(
                          Icons.home,
                          color: Colors.lightBlue[500],
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

