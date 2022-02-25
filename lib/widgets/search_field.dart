import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final void Function(String searchStr)? onChanged;
  final Color? borderColor;

  const SearchField({
    Key? key,
    this.onChanged,
    this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(7),
            borderSide: BorderSide(width: 1, color: borderColor??Colors.black)),
      ),
    );
  }
}
