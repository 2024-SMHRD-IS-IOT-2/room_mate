import 'dart:ui';

import 'package:flutter/material.dart';

class TouchPainter extends CustomPainter {
  Offset? destination;
  Offset? robotLocation;
  // late Dio dio;
  double? robotLocationX;
  double? robotLocationY;

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

    double mapValue(double value, double start1, double stop1, double start2,
        double stop2) {
      return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
    }

    if (destination != null) {
      double destinationX = destination!.dx.toInt().toDouble();
      double destinationY = destination!.dy.toInt().toDouble();
      destination = Offset(destinationX, destinationY);
      canvas.drawPoints(PointMode.points, [destination!], destinationPaint);
      print("목적지 좌표 : " +
          destination!.dx.toString() +
          "," +
          destination!.dy.toString());
    }
    // double x = robotLocation!.dx.toInt().toDouble();
    // double y = robotLocation!.dy.toInt().toDouble();
    // robotLocation = Offset(x, y);
    if (robotLocation != null) {
      // robotLocationX = mapValue(robotLocation!.dy, -0.5, 3, 0, 611);
      // robotLocationY = mapValue(robotLocation!.dx, -0.3, 1.4, 0, 310);
      // robotLocation = Offset(robotLocationX!.toInt().toDouble(),
      //     robotLocationY!.toInt().toDouble());

      canvas.drawPoints(PointMode.points, [robotLocation!], robotLocationPaint);
      print("로봇 위치 : " +
          robotLocation!.dx.toString() +
          "," +
          robotLocation!.dy.toString());
    }
  }

  @override
  bool shouldRepaint(TouchPainter oldDelegate) {
    return oldDelegate.destination != destination ||
        oldDelegate.robotLocation != robotLocation;
  }
}
