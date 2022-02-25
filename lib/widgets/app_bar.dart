import 'package:flutter/material.dart';
import 'package:offer_app/models/setting_model.dart';
import 'package:offer_app/provider/setting_provider.dart';
import 'package:provider/provider.dart';

PreferredSizeWidget buildAppBar(
  context, {
  required String title,
  Widget? leading,
  List<Widget>? actions,
}) {
  Setting setting = Provider.of<SettingProvider>(context).setting;
  return AppBar(
    title: Text(
      title,
      style: setting.theme.appBarTextStyle,
    ),
    leading: leading,
    actions: actions,
    backgroundColor: setting.theme.appBarColor,
  );
}
