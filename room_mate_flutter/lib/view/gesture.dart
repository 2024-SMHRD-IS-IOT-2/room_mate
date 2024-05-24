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
        Response response =
            await dio.post('$serverUrl/gesture', data: {'signal': false});
            print(response.data);
        setState(() {
          gestureCheck = false;
        });
      } else {
        Response response =
            await dio.post('$serverUrl/gesture', data: {'signal': true});
        print("+++++++++++++++++++++++++++++" + response.data);
        setState(() {
          gestureCheck = true;
          personCheck = false;
        });
      }
    } catch (e) {
      print('********************' + e.toString());
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
