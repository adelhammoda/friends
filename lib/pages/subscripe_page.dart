import 'package:flutter/material.dart';
import 'package:friends/widgets/custom_scaffold.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({Key? key}) : super(key: key);

  @override
  State<SubscribePage> createState() => _SubsecripePageState();
}

class _SubsecripePageState extends State<SubscribePage> {
  final CustomScaffoldController _controller = CustomScaffoldController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        child:Column(
          children: [
            // SubscribeWidget(),
            Text("coming soon",style: TextStyle(
              fontSize: 18,

            ),)
          ],
        )
        , controller: _controller);
  }
}
