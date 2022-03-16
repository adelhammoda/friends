import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  final double size;

  const Loader({Key? key, this.size = 20}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Lottie.asset('assets/lottie/loader.json',
          fit: BoxFit.fill,
          width: size,
          alignment: Alignment.center),
    );
  }
}
