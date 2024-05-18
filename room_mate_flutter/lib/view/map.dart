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
  Offset? _destitionPoint; // 내가 찍은 좌표
  Offset homedestitionPoint = Offset(100.0, 50.0); // 집 좌표
  bool buttonState = false; // true일 때 cancel icon과 이동중~ text가 나옴

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
      final response =
          await dio.post('http://121.147.52.9:8016/destination', data: {
        'signal': true,
        'x': _destitionPoint!.dx.toInt(),
        'y': _destitionPoint!.dy.toInt()
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
  goToHome() async {
    _destitionPoint = Offset(190, 550);
    print(_destitionPoint);
    try {
      final response =
          await dio.post('http://121.147.52.9:8016/go_to_home', data: {
        'signal': true,
        'x': _destitionPoint!.dx.toInt(),
        'y': _destitionPoint!.dy.toInt()
      });
      print(response.data.toString());
      setState(() {
        moving = true; // 이동중임을 표시
        buttonState = true;
        _destitionPoint = null; // 버튼을 누를 때 좌표 초기화
      });
    } catch (e) {
      print("집 좌표 보내기 실패 : " + e.toString());
    }
  }

  // 이동 중 멈추고 싶을 때 누르면 멈추는 코드 작성
  void cancelsendDestination() {
    _destitionPoint = null;
    dio.post('http://121.147.52.9:8016/stop', data: {'stop_signal': 'stop'});
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
                            painter: TouchPainter(
                                destitionPoint: _destitionPoint, dio: dio),
                            size: Size.infinite,
                          ),
                        )
                      : GestureDetector(
                          onTapDown: (TapDownDetails details) {
                            setState(() {
                              // 터치된 위치를 화면의 좌표로 변환하여 바뀜
                              RenderBox referenceBox =
                                  context.findRenderObject() as RenderBox;
                              _destitionPoint = referenceBox
                                  .globalToLocal(details.globalPosition);
                              _destitionPoint = Offset(_destitionPoint!.dx,
                                  _destitionPoint!.dy - 115);
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
                                  destitionPoint: _destitionPoint, dio: dio),
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
  final Offset? destitionPoint;
  late Dio dio;

  TouchPainter({this.destitionPoint, required this.dio});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 15.0;

    if (destitionPoint != null) {
      canvas.drawPoints(PointMode.points, [destitionPoint!], paint);
      print(destitionPoint!.dx.toInt().toString() +
          "," +
          destitionPoint!.dy.toInt().toString());
    }
  }

  @override
  bool shouldRepaint(TouchPainter oldDelegate) {
    return oldDelegate.destitionPoint != destitionPoint;
  }
}
