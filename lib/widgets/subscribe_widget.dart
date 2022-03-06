import 'package:flutter/material.dart';
import 'package:responsive_s/responsive_s.dart';

class SubscribeWidget extends StatelessWidget {
  final Color color;
  final String name;
  final Duration duration;
  final double price;
  final String unit;

  const SubscribeWidget(
      {Key? key, required this.color, required this.name, required this.duration, required this.price, required this.unit,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Responsive _responsive = Responsive(context);


    return Container(

        width: _responsive.responsiveWidth(forUnInitialDevices: 80),

    );
  }
}
