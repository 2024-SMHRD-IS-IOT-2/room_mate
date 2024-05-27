import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class Gesture extends StatefulWidget {
  const Gesture({Key? key}) : super(key: key);

  @override
  State<Gesture> createState() => _GestureState();
}

class _GestureState extends State<Gesture> {
  bool gestureCheck = false;
  bool personCheck = false;
  Dio dio = Dio();
  String serverUrl = "http://121.147.52.9:8016";

  checkedGesture() async {
    try {
      if (gestureCheck) {
        // "Gesture 모드 카메라를 끄겠다"는 신호
        Response response =
            await dio.post('$serverUrl/receive_bool', data: {'signal': false});
        print(response.data.toString());
        sleep(Duration(seconds: 2));

        // "기존 카메라 켜겠다"는 신호
        // await dio.post('$serverUrl/receive_bool', data: {'signal': false});

        setState(() {
          gestureCheck = false;
        });
      } else {
        // "기존 카메라를 끄겠다"는 신호
        // await dio.post('$serverUrl/receive_bool', data: {'signal': false});
        // sleep(Duration(seconds: 2));

        // "Gesture 모드 카메라를 켜겠다"는 신호
        Response response =
            await dio.post('$serverUrl/receive_bool', data: {'signal': true});
        print("+++++++++++++++++++++++++++++" + response.data.toString());
        setState(() {
          gestureCheck = true;
          personCheck = false;
        });
      }
    } catch (e) {
      print('*******zz***********zz**' + e.toString());
    }
  }

  checkedPerson() async {
    if (personCheck) {
      Response response =
          await dio.post('$serverUrl/person', data: {'signal': false});
      print(response.data);
      setState(() {
        personCheck = false;
      });
    } else {
      Response response =
          await dio.post('$serverUrl/person', data: {'signal': true});
      print(response.data);
      setState(() {
        personCheck = true;
        gestureCheck = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // toolbarHeight: 50,
        title: Text(
          "Gesture",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue[300],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        side: BorderSide(width: 1),
                        backgroundColor:
                            gestureCheck ? Colors.lightBlue : null),
                    onPressed: () => checkedGesture(),
                    child: Text(
                      'Gesture',
                      style: TextStyle(fontSize: 80),
                    ))),
            Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        side: BorderSide(width: 1),
                        backgroundColor: personCheck ? Colors.lightBlue : null),
                    onPressed: () => checkedPerson(),
                    child: Text(
                      'Person',
                      style: TextStyle(fontSize: 80),
                    ))),
          ],
        ),
      ),
    );
  }
}
