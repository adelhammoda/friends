


import 'package:flutter/material.dart';
import 'package:friends/widgets/loader.dart';

class WaitingPage extends StatelessWidget {
  const WaitingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const  Scaffold(
      backgroundColor: Colors.purpleAccent,
      body: Center(
        child: Loader(
          size: 60,
        ),
      ),
    );
  }
}
