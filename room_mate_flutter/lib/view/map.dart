import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initialization();
    getImage();
    Timer.periodic(Duration(milliseconds: 500), (timer) {
      fetchCoordinate();
    });

    // robot에서 지도데이터 받음
    // await dio.post('http://121.147.52.9:8016/to_flutter_map_data');

    // robot에서 robot의 실시간 위치 데이터 받음
    // Timer.periodic(const Duration(seconds: 1), (timer) async {
    //   await dio.post('http://121.147.52.9:8016/to_flutter_robot_location');
    // });
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    // print('ready in 3...');
    // await Future.delayed(const Duration(seconds: 1));
    // print('ready in 2...');
    // await Future.delayed(const Duration(seconds: 1));
    // print('ready in 1...');
    // await Future.delayed(const Duration(seconds: 1));
    // print('go!');
    // FlutterNativeSplash.remove();
  }

  Future<void> getImage() async {
    try {
      // Dio를 사용하여 이미지를 가져옴
      print("이미지 가져오기 전");
      Response response = await dio.get(
          'http://121.147.52.9:8016/to_flutter_map_data',
          options: Options(responseType: ResponseType.bytes));
      print('이미지 가져오기 성공!');

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
      final response = await dio.post('http://121.147.52.9:8016/destination',
          data: {
            'signal': true,
            'x': _destination!.dx.toInt(),
            'y': _destination!.dy.toInt()
          });
      print("좌표값 보냄!!" + response.data.toString());
      setState(() {
        moving = true;
      });
    } catch (e) {
      print('좌표값 보내기 실패 ㅠㅠ');
    }
  }

  // 집을 가는 코드 작성
  void goToHome() async {
    _destination = Offset(190, 550);
    print(_destination);
    try {
      final response = await dio.post('http://121.147.52.9:8016/go_to_home',
          data: {
            'signal': true,
            'x': _destination!.dx.toInt(),
            'y': _destination!.dy.toInt()
          });
      print(response.data.toString());
      setState(() {
        moving = true; // 이동중임을 표시
        buttonState = true;
        _destination = null; // 버튼을 누를 때 좌표 초기화
      });
    } catch (e) {
      print("집 좌표 보내기 실패 : " + e.toString());
    }
  }

  // 이동 중 멈추고 싶을 때 누르면 멈추는 코드 작성
  void cancelsendDestination() {
    _destination = null;
    dio.post('http://121.147.52.9:8016/stop', data: {'stop_signal': 'stop'});
    setState(() {
      moving = false;
      buttonState = false;
    });
  }

  Future<void> fetchCoordinate() async {
    try {
      // Dio를 사용하여 서버에서 좌표를 가져옵니다. 서버 URL은 적절하게 변경해야 합니다.
      var response =
          await dio.post('http://121.147.52.9:8016/to_flutter_robot_location');
      setState(() {
        // 서버 응답에서 좌표를 파싱하여 currentLocation을 업데이트합니다.
        // 이 예시에서는 JSON 응답을 {'x': 100, 'y': 200} 형태로 가정합니다.
        _robotCurrentLocation = Offset(response.data['x'], response.data['y']);
      });
    } catch (e) {
      print("로봇 현재 위치 불러오기 실패 : $e");
    }
  }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
                "Map",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
              ),
              centerTitle: true,
              backgroundColor: Colors.lightBlue[300],
            ),
          ],
        ),
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
                          child: CustomPaint(
                            painter: TouchPainter(destination: _destination),
                            size: Size.infinite,
                          ),
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
                                  _destination!.dx, _destination!.dy - 115);
                              buttonState = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: MemoryImage(_imageBytes),
                                    fit: BoxFit.fill)),
                            child: CustomPaint(
                              painter: TouchPainter(
                                  destination: _destination,
                                  robotLocation: _robotCurrentLocation),
                              size: Size.infinite,
                            ),
                          ),
                        ),
                )
              : CircularProgressIndicator(), // 이미지 로딩 중에는 로딩 스피너를 표시,

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

class TouchPainter extends CustomPainter {
  final Offset? destination;
  final Offset? robotLocation;
  // late Dio dio;

  TouchPainter(
      {this.destination,
      this.robotLocation}); // robotLocation은 required로 바꿔야한다!

  @override
  void paint(Canvas canvas, Size size) {
    final Paint destinationPaint = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15.0;

    final Paint robotLocationPaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 15.0;

    if (destination != null) {
      canvas.drawPoints(PointMode.points, [destination!], destinationPaint);
      print("목적지 좌표 : " +
          destination!.dx.toInt().toString() +
          "," +
          destination!.dy.toInt().toString());
    }

    if (robotLocation != null) {
      canvas.drawPoints(PointMode.points, [robotLocation!], robotLocationPaint);
      print("로봇 위치 : " +
          robotLocation!.dx.toInt().toString() +
          "," +
          robotLocation!.dy.toInt().toString());
    }
  }

  @override
  bool shouldRepaint(TouchPainter oldDelegate) {
    return oldDelegate.destination != destination ||
        oldDelegate.robotLocation != robotLocation;
  }
}
