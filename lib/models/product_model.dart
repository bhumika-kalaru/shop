import 'dart:io';

import 'package:flutter/material.dart';

class Product {
  late String id;
  final String name;
  final String description;
  final Image img;
  Product({
    this.id = '',
    required this.name,
    required this.description,
    required this.img,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'name': name,
        'Image': img,
      };
  static Product fromJson(Map<String, dynamic> json) => Product(
      id: json['id'],
      description: json['description'],
      name: json['name'],
      img: json['Image']);
}
