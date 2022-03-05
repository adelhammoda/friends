import 'package:flutter/material.dart';

List<Widget> buildFromMap(Map<dynamic, dynamic> data) {
  return List.generate(
      data.length,
      (index) => Column(
            children: [
              Text(data[index]['title']),
              Text(data[index]['info']),
            ],
          ));
}
