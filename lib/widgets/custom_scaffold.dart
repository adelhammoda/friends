import 'dart:async';

import 'package:flutter/material.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_s/responsive_s.dart';

class CustomScaffold extends StatefulWidget {
  final Widget child;
  final Widget? floatingActionButton;
  final Widget? navigationBar;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final PreferredSizeWidget? appBar;
  final CustomScaffoldController controller;

  const CustomScaffold({
    Key? key,
    required this.child,
    required this.controller,
    this.floatingActionButtonLocation =
        FloatingActionButtonLocation.miniEndDocked,
    this.floatingActionButton,
    this.navigationBar,
    this.appBar,
  }) : super(key: key);

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold>
    with SingleTickerProviderStateMixin {
  late final Animation<Offset> _animation;
  late final AnimationController _controller;
  late Responsive _responsive;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _responsive = Responsive(context);
  }

  void _triggerMSG(String msg) {
    if (!_controller.isAnimating) {
      _controller.forward();
      Timer(const Duration(seconds: 2), () {
        _controller.reverse();
        widget.controller.showMSG('');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _animation = Tween(begin: const Offset(0, 1.5), end: const Offset(0, 0))
        .animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInBack));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        floatingActionButton: widget.floatingActionButton,
        floatingActionButtonLocation: widget.floatingActionButtonLocation,
        bottomNavigationBar: widget.navigationBar,
        backgroundColor:
            Provider.of<SettingProvider>(context).setting.theme.primaryColor,
        appBar: widget.appBar,
        body: Stack(
          children: [
            widget.child,
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder<String>(
                valueListenable: widget.controller.valueListenable,
                builder: (ctx, value, child) {
                  if (value != '') {
                    _triggerMSG(value);
                  }
                  return value != ''
                      ? SlideTransition(
                          position: _animation,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            constraints: BoxConstraints(
                                // minHeight: _responsive.responsiveHeight(
                                //     forUnInitialDevices: 15),
                                // minWidth: _responsive.responsiveWidth(
                                //     forUnInitialDevices: 95),
                                ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    widget.controller.prefixWidget == null
                                        ? Container()
                                        : SizedBox(
                                            width: _responsive.responsiveWidth(
                                                forUnInitialDevices: 10),
                                            height: _responsive.responsiveWidth(
                                                forUnInitialDevices: 10),
                                            child:
                                                widget.controller.prefixWidget),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Text(
                                          widget.controller.message,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          value,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Provider.of<SettingProvider>(
                                                    context)
                                                .setting
                                                .theme
                                                .appBarColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container();
                },
              ),
            ),
          ],
        ));
  }
}

class CustomScaffoldController with ChangeNotifier {
  final ValueNotifier<String> valueListenable = ValueNotifier('');
  String message = 'Error';
  Widget? prefixWidget;
  Duration duration = const Duration(milliseconds: 400);
  double widthPercentage = 95;
  double heightPercentage = 15;

  void showMSG(
    String msg, {
    String title = 'Error',
    Widget? prefix,
    Duration duration = const Duration(milliseconds: 400),
    double widthPercentage = 15,
    double heightPercentage = 95,
  }) {
    message = title;
    this.widthPercentage = widthPercentage;
    this.heightPercentage = heightPercentage;
    prefixWidget = prefix;
    this.duration = duration;
    valueListenable.value = msg;
    valueListenable.notifyListeners();
  }
}
