import 'dart:io';

import 'package:flutter/material.dart';

class Product {
  late String Id;
  final String Price, Quantity;
  late final String Name;
  final String Description;
  final String ImageUrl;
  Product({
    this.Id = '',
    required this.Price,
    required this.Quantity,
    required this.Name,
    required this.Description,
    required this.ImageUrl,
  });
  Map<String, dynamic> toJson() => {
        'id': Id,
        'description': Description,
        'name': Name,
        'image': ImageUrl,
        'price': Price,
        'quantity': Quantity,
      };
  static Product fromJson(Map<String, dynamic> json) => Product(
      Id: json['id'],
      Description: json['description'],
      Name: json['name'],
      ImageUrl: json['image'],
      Quantity: json['quantity'],
      Price: json['price']);

  // Map<String, Object?> toMapSql() {}
}
