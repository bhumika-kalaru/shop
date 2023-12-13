import 'dart:io';

import 'package:flutter/material.dart';

class Product {
  late String Id;
  final String Price, Quantity;
  final String Name;
  final String Description;
  final String ImageUrl;
  final bool Wishlisted;
  Product({
    this.Id = '',
    required this.Price,
    required this.Quantity,
    required this.Name,
    required this.Description,
    required this.ImageUrl,
    required this.Wishlisted,
  });
  Map<String, dynamic> toJson() => {
        'id': Id,
        'description': Description,
        'name': Name,
        'image': ImageUrl,
        'price': Price,
        'quantity': Quantity,
        'wishlisted': Wishlisted,
      };
  static Product fromJson(Map<String, dynamic> json) => Product(
      Id: json['id'],
      Description: json['description'],
      Name: json['name'],
      ImageUrl: json['image'],
      Quantity: json['quantity'],
      Price: json['price'],
      Wishlisted: json['wishlisted']);

  // Map<String, Object?> toMapSql() {}
}
