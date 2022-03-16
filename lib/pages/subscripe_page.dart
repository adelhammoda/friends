import 'package:flutter/material.dart';
import 'package:friends/models/subscripe.dart';
import 'package:friends/widgets/custom_scaffold.dart';
import 'package:friends/widgets/subscribe_widget.dart';

class SubscribePage extends StatefulWidget {
  final PageController controller;
  const SubscribePage({Key? key,required this.controller}) : super(key: key);

  @override
  State<SubscribePage> createState() => _SubsecripePageState();
}

class _SubsecripePageState extends State<SubscribePage> {
  final CustomScaffoldController _controller = CustomScaffoldController();



  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: double.infinity,),
            // SubscribeWidget(),
           SubscribeWidget(
               subscribe:Subscribe(
             cost: 120.9,
             imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ63lb0fXSsdZMXooYEY7SGzhO31NAcn34Gug&usqp=CAU',
             shadowColor: Colors.blue,
             duration: Duration(days: 30),
             color: Colors.cyanAccent,
             name: 'Monthly',
             id: '1234',
             description: 'every month get your subscribe and start your offers world '
                 'every month get your subscribe and start your offers world '
                 'This friends app on beta channel. will be ready soon for users',
             endTime: DateTime.now().add(Duration(days: 30)),
             startTime: DateTime.now()
           ),controller: widget.controller,),
          ],
        )
        , controller: _controller);
  }
}
