import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  //colors
  final Color primaryColor;
  final Color textFieldColor;
  final Color bodyTextColor;
  final Color appBarColor;
  final Color iconsColor;
  final Color lightWhite;
   // styles
  final TextStyle bodyTextStyle;
  final TextStyle appBarTextStyle;
  const AppTheme({required this.name,
    required this.primaryColor,
    required this.lightWhite,
    required this.textFieldColor,
    required this.bodyTextColor,
    required this.appBarColor,
    required this.iconsColor,
    required this.bodyTextStyle,
    required this.appBarTextStyle,
  });


  MaterialColor createMaterialColor() {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = primaryColor.red,
        g = primaryColor.green,
        b = primaryColor.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(primaryColor.value, swatch);
  }
  @override
  operator ==(Object? other) {
    if (
    other.hashCode == hashCode && other.runtimeType == runtimeType&&other is AppTheme && other.name==name ) {
      return true;
    }else {
      return false;
    }
  }

  @override
  int get hashCode => name.hashCode ;
}
