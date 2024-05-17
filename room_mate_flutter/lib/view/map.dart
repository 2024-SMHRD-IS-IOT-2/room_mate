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
  Offset? _point; // 내가 찍은 좌표
  Offset homePoint = Offset(100.0, 50.0); // 집 좌표
  bool buttonState = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initialization();
    getImage();

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
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  Future<void> getImage() async {
    try {
      // Dio를 사용하여 이미지를 가져옴
      print("dddddddd");
      Response response = await dio.get(
          'http://121.147.52.9:8016/to_flutter_map_data',
          options: Options(responseType: ResponseType.bytes));
      print('ffffffffff');

      // 가져온 이미지를 화면에 표시
      setState(() {
        _imageBytes = response.data;
        print('***hihi***' + _imageBytes.toString());
      });
    } catch (e) {
      print('Failed to load image: $e');
    }
  }

  // flask로 목적지 좌표 보내는 코드 작성
  void sendDestination() async {
    try {
      final response = await dio.post('http://121.147.52.9:8016/destination',
          data: {
            'signal': true,
            'x': _point!.dx.toInt(),
            'y': _point!.dy.toInt()
          });
      print("대답!!" + response.data.toString());
      setState(() {
        moving = true;
      });
    } catch (e) {
      print('No destination');
    }
  }

  // 집을 가는 코드 작성
  goToHome() async {
    _point = Offset(190, 550);
    print(_point);
    try {
      final response = await dio.post('http://121.147.52.9:8016/go_to_home',
          data: {'x좌표': _point!.dx.toInt(), 'y좌표': _point!.dy.toInt()});
      print(response.data.toString());
      setState(() {
        moving = true;
        buttonState = true;
      });
    } catch (e) {
      print("I can't go to home bb" + e.toString());
    }
  }

  // 이동 중 멈추고 싶을 때 누르면 멈추는 코드 작성
  void cancelsendDestination() {
    _point = null;
    final response = dio
        .post('http://121.147.52.9:8016/stop', data: {'stop_signal': 'stop'});
    setState(() {
      moving = false;
      buttonState = false;
    });
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
                      ? Container(
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: MemoryImage(_imageBytes),
                                  fit: BoxFit.fill)),
                          child: CustomPaint(
                            painter: TouchPainter(point: _point, dio: dio),
                            size: Size.infinite,
                          ),
                        )
                      : GestureDetector(
                          onTapDown: (TapDownDetails details) {
                            setState(() {
                              // 터치된 위치를 화면의 좌표로 변환하여 바뀜
                              RenderBox referenceBox =
                                  context.findRenderObject() as RenderBox;
                              _point = referenceBox
                                  .globalToLocal(details.globalPosition);
                              _point = Offset(_point!.dx, _point!.dy - 115);
                              buttonState = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: MemoryImage(_imageBytes),
                                    fit: BoxFit.fill)),
                            child: CustomPaint(
                              painter: TouchPainter(point: _point, dio: dio),
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
                        style: TextStyle(color: Colors.white),
                      )
                    : ElevatedButton(
                        style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all(Size(70, 40))),
                        onPressed: () {
                          goToHome();
                          setState(() {
                            print("포인트!!" + _point!.dx.toInt().toString());
                            _point = null; // 버튼을 누를 때 좌표 초기화
                          });
                        },
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
  final Offset? point;
  late Dio dio;

  TouchPainter({this.point, required this.dio});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15.0;

    if (point != null) {
      canvas.drawPoints(PointMode.points, [point!], paint);
      print(point!.dx.toInt().toString() + "," + point!.dy.toInt().toString());
      // sendDestinationToFlask();
    }
  }

  // sendDestinationToFlask() async {
  //   print('aaaaaaaaaaaaa');
  //   final response = await dio.post('http://121.147.52.9:8016/destination',
  //       data: {'x좌표': point!.dx.toInt(), 'y좌표': point!.dy.toInt()});
  //   print("대답!!" + response.data.toString());
  // }

  @override
  bool shouldRepaint(TouchPainter oldDelegate) {
    return oldDelegate.point != point;
  }
}
