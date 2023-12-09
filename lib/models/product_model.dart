import 'dart:io';

import 'package:flutter/material.dart';

class Product {
  late String id;
  final String name;
  final String description;
  final String imageUrl;
  Product({
    this.id = '',
    required this.name,
    required this.description,
    required this.imageUrl,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'name': name,
        'Image': imageUrl,
      };
  static Product fromJson(Map<String, dynamic> json) => Product(
      id: json['id'],
      description: json['description'],
      name: json['name'],
      imageUrl: json['Image']);
}
