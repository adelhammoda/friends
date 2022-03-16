import 'dart:convert';

import 'package:flutter/material.dart';

class Subscribe {
  final String name;
  final Duration duration;
  final DateTime startTime;
  final DateTime endTime;
  final double cost;
  final Color color;
  final String id;
  final String description;
  final String imageUrl;
  final Color? shadowColor;

  Subscribe(
      {required this.name,
      required this.duration,
      required this.imageUrl,
      required this.cost,
      required this.startTime,
      required this.endTime,
      required this.color,
      required this.id,
      required this.description,
      this.shadowColor});

  factory Subscribe.fromJSON(Map data) {
    return Subscribe(
        cost: data['cost'],
        imageUrl: data['imageUrl'],
        name: data['name'],
        duration: data['duration'],
        startTime: data['startTime'],
        endTime: data['endTime'],
        color: data['color'],
        id: data['id'],
        shadowColor: data['shadowColor'],
        description: data['description']);
  }

  Map<String, dynamic> toJSON() => {
        'imageUrl': imageUrl,
        'shadowColor': jsonEncode(colorToMap(shadowColor ?? Colors.grey)),
        'id': id,
        'name': name,
        'cost':cost,
        'description': description,
        'color': jsonEncode(colorToMap(color)),
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'duration': durationToString(duration)
      };

  static DateTime stringTODate(String string) => DateTime.parse(string);

  static Color mapToColor(Map data) =>
      Color.fromRGBO(data['r'], data['g'], data['b'], data['o']);

  static Map colorToMap(Color color) => {
        'r': color.red,
        'g': color.green,
        'b': color.blue,
        'o': color.opacity,
      };

  static String durationToString(Duration duration) =>
      duration.inSeconds.toString();

  static Duration stringToDuration(String string) =>
      Duration(seconds: int.tryParse(string) ?? 0);
}
