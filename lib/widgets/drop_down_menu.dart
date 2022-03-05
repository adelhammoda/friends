import 'package:flutter/material.dart';
import 'package:friends/provider/auth_provider.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_s/responsive_s.dart';

class CustomDropDownMenu extends StatefulWidget {
  final Curve curve;
  final List<Map> data;
  final String hintText;

  const CustomDropDownMenu(
      {Key? key,
      required this.hintText,
      required this.data,
      this.curve = Curves.easeIn})
      : super(key: key);

  @override
  _CustomDropDownMenuState createState() => _CustomDropDownMenuState();
}

class _CustomDropDownMenuState extends State<CustomDropDownMenu>
    with SingleTickerProviderStateMixin {
  late Responsive _responsive;
  late SettingProvider _settingProvider;
  late final Animation<double> _animation;
  late final AnimationController _controller;

  final GlobalKey _key = GlobalKey();
  final GlobalKey _containerKey = GlobalKey();
  late double _height = _responsive.responsiveHeight(forUnInitialDevices: 7);
  double _containerHeight = 0;
  double _columnHeight = 0;
  String? userChoice;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _containerHeight = _containerKey.currentContext?.size?.height ?? 0;
      _columnHeight =
          (_key.currentContext?.size?.height ?? 0) + _containerHeight;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _responsive = Responsive(context);
    _settingProvider = SettingProvider(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      clipBehavior: Clip.antiAlias,
      curve: Curves.easeInBack,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: const Duration(milliseconds: 400),
      width: double.infinity,
      height: _height,
      child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(children: [
            Container(
              key: _containerKey,
              padding: const EdgeInsets.all(6),
              width: double.infinity,
              height: _responsive.responsiveHeight(forUnInitialDevices: 7),
              decoration: BoxDecoration(
                color: _settingProvider.setting.theme.textFieldColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    userChoice ?? widget.hintText,
                    style: TextStyle(
                        color: _settingProvider.setting.theme.bodyTextColor),
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          _height = _height == _containerHeight
                              ? _columnHeight
                              : _containerHeight;
                        });
                        _controller.isCompleted
                            ? _controller.reverse()
                            : _controller.forward();
                      },
                      child: AnimatedIcon(
                        icon: AnimatedIcons.menu_close,
                        progress: _animation,
                        color: _settingProvider.setting.theme.iconsColor,
                      ))
                ],
              ),
            ),
            Column(
              key: _key,
              children: widget.data.map<Widget>((e) {
                return InkWell(
                    onTap: () {
                      Provider.of<AuthProvider>(context, listen: false)
                          .changeUserType(e['value']);
                      setState(() {
                        userChoice = userChoice==e['name']?null:e['name'];
                        _height = _containerHeight;
                      });
                      _controller.reverse();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.center,
                            tileMode: TileMode.mirror,
                            colors: [
                              Provider.of<AuthProvider>(context).userType == e['value']
                                  ? _settingProvider.setting.theme.bodyTextColor
                                  : _settingProvider
                                  .setting.theme.appBarColor,
                              Provider.of<AuthProvider>(context).userType == e['value']
                                  ? _settingProvider.setting.theme.primaryColor
                                  : _settingProvider
                                  .setting.theme.bodyTextColor,

                            ]
                          ),
                                                            borderRadius: BorderRadius.circular(10)),
                        width: double.infinity,
                        child: Text(
                          e['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color:
                              Provider.of<AuthProvider>(context).userType != e['value']
                                  ? _settingProvider.setting.theme.bodyTextColor
                                  : _settingProvider
                                  .setting.theme.appBarColor),
                        ),
                      ),
                    ));
              }).toList()
                ..add(IconButton(
                    onPressed: () {
                      Provider.of<AuthProvider>(context, listen: false)
                          .changeUserType('');
                      setState(() {
                        userChoice = null;
                      });
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: _settingProvider.setting.theme.textFieldColor,
                    ))),
            ),
          ])),
    );
  }
}
