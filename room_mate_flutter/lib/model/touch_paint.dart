import 'package:flutter/cupertino.dart';
import 'package:room_mate/model/touch_painter.dart';


class CurrentLocation extends StatefulWidget {
  const CurrentLocation({super.key, required this.destination, required this.robotCurrentLocation});

  final Offset? destination;
  final Offset? robotCurrentLocation;

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TouchPainter(
          destination: widget.destination,
          robotLocation: widget.robotCurrentLocation),
      size: Size.infinite,
    );;
  }
}

// class CurrentLocation{
//   Offset? destination;
//   Offset? robotCurrentLocation;
//   CurrentLocation({required this.destination, required this.robotCurrentLocation});
//
//   Widget build(BuildContext context){
//     return CustomPaint(
//       painter: TouchPainter(
//           destination: destination,
//           robotLocation: robotCurrentLocation),
//       size: Size.infinite,
//     );
// }}