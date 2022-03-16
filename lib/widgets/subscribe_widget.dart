
import 'package:flutter/material.dart';
import 'package:friends/models/subscripe.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_s/responsive_s.dart';

import '../provider/setting_provider.dart';

class SubscribeWidget extends StatefulWidget {
  final PageController controller;
  final Subscribe subscribe;

  const SubscribeWidget(
      {Key? key, required this.subscribe,required this.controller})
      : super(key: key);

  @override
  State<SubscribeWidget> createState() => _SubscribeWidgetState();
}


class _SubscribeWidgetState extends State<SubscribeWidget> with SingleTickerProviderStateMixin {
  late final Responsive _responsive = Responsive(context);
  late final SettingProvider _setting = Provider.of<SettingProvider>(context);
  late final AnimationController _animationController;
  late final Animation<Offset> _animation;


  @override
  void initState() {
    super.initState();
    _animationController =  AnimationController(vsync:this,duration: const Duration(
      milliseconds: 500
    ) );
    _animation = Tween(
        begin: Offset(-1,0),
        end: Offset(0,0)
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutSine));
  }
  @override
  Widget build(BuildContext context) {





    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 20),
      child: Container(
        width: _responsive.responsiveWidth(forUnInitialDevices: 80),
        height: _responsive.responsiveHeight(forUnInitialDevices: 50),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15)
        ),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.hardEdge,
          children: [
            Container(
              clipBehavior: Clip.hardEdge,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                    widget.subscribe.imageUrl,
                  ),
                  onError: (object,stackTrack){

                  }
                ),
                color: widget.subscribe.color,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: widget.subscribe.shadowColor?.withOpacity(0.5)??Colors.white.withOpacity(0.5),
                    offset: Offset(0,0),
                    blurRadius: 3,
                    spreadRadius: 3
                  )
                ]
              ),
                width: _responsive.responsiveWidth(forUnInitialDevices: 80),
                height: _responsive.responsiveHeight(forUnInitialDevices: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.subscribe.name,style: TextStyle(
                              fontSize: 20,
                              color: _setting.setting.theme.appBarColor,
                              fontWeight: FontWeight.bold,
                            ),),
                            Text(widget.subscribe.cost.toString()+' \$',style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _setting.setting.theme.textFieldColor,
                              fontSize: 19,
                            ),)
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(widget.subscribe.description),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Text('Start At',
                              style: TextStyle(
                                fontSize: 17,
                                color: _setting.setting.theme.textFieldColor,
                                fontWeight: FontWeight.bold
                              ),),
                              Padding(
                                padding: const EdgeInsets.only(left: 5,top: 5),
                                child: Text(DateFormat.yMd().format(widget.subscribe.startTime)),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Text('End At',
                              style: TextStyle(
                                  fontSize: 17,
                                  color: _setting.setting.theme.textFieldColor,
                                  fontWeight: FontWeight.bold
                              ),),
                            Padding(
                              padding: const EdgeInsets.only(left: 5,top: 5),
                              child: Text(DateFormat.yMd().format(widget.subscribe.endTime)),
                            )
                          ],
                        ),

                      ],


                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(onPressed: (){
                    print('i am in on pressed function');
                    _animationController.forward();
                    // print(widget.controller.page);
                    // widget.controller.animateToPage(3, duration: const Duration(milliseconds:500), curve: Curves.easeInCubic);
                  },
                    child: Row(
                    mainAxisSize:MainAxisSize.min,

                    children: [
                      Text('subscribe',),
                      Icon(Icons.arrow_forward)
                    ],
                  ),)

                ],
              ),


            ),
            SlideTransition(
              position: _animation ,
              child: Container(
                clipBehavior: Clip.hardEdge,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _setting.setting.theme.lightWhite.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(15),
                ),
                width: _responsive.responsiveWidth(forUnInitialDevices: 80),
                height: _responsive.responsiveHeight(forUnInitialDevices: 50),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(onPressed: (){
                        _animationController.reverse();
                      }, icon: Icon(Icons.close)),
                      Text("Go to code page and press on go to generate your own code .\n Note : don't shar this code with another . \n"
                          "Then scan this code with one of subscription center in your area",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _setting.setting.theme.appBarColor,
                      ),),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton(onPressed: (){
                          widget.controller.animateToPage(3, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
                        }, child: Text('Go to page')),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
