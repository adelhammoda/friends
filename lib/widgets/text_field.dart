import 'package:flutter/material.dart';
import 'package:friends/provider/setting_provider.dart';
import 'package:provider/provider.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool enabled;
  final int minLine;
  final int maxLine;
  final void Function()? onTap;
  final String? Function(String? value)? validator;
  final void Function(String? value)? onChanged;
  final TextInputType? textInputType;
  final TextEditingController? controller;
  final String? initialValue;
  final bool hideText,allowToolBar;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  const CustomTextField({
    Key? key,
    required this.hintText,
    this.hideText=false,
    this.allowToolBar=false,
    this.enabled=true,
    this.minLine=1,
    this.maxLine=1,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
    this.controller,
    this.textInputType,
    this.initialValue
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: minLine,
      maxLines: maxLine,
      onTap: onTap,
      readOnly: !enabled,
      obscuringCharacter: "*",
      toolbarOptions: ToolbarOptions(
        copy: allowToolBar?false:true,
        cut: allowToolBar?false:true,
        paste: allowToolBar?false:true,
        selectAll:allowToolBar?false:true,
      ),
      obscureText: hideText,
      style: TextStyle(
        color: Provider.of<SettingProvider>(context)
            .setting
            .theme.
        bodyTextColor
      ),
      validator: validator,
      onChanged: onChanged,
      initialValue: initialValue,
      controller: controller,
      keyboardType: textInputType,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        hintStyle: TextStyle(
          color: Provider.of<SettingProvider>(context)
              .setting
              .theme
              .primaryColor
        ),
          hintText: hintText,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Provider.of<SettingProvider>(context)
                    .setting
                    .theme
                    .bodyTextColor,
              )),
          filled: true,
          fillColor: Provider.of<SettingProvider>(context)
              .setting
              .theme
              .textFieldColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: Provider.of<SettingProvider>(context)
                    .setting
                    .theme
                    .bodyTextColor,
              ))),
    );
  }
}
