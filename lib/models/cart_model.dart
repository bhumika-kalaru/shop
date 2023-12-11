import 'package:flutter/material.dart';

class CartProduct {
  late String Id;
  final String Quantity;
  CartProduct({
    required this.Id,
    required this.Quantity,
  });
  Map<String, dynamic> toJson() => {
        'id': Id,
        'quantity': Quantity,
      };
  static CartProduct fromJson(Map<String, dynamic> json) =>
      CartProduct(Id: json['id'], Quantity: json['quantity']);

  // Map<String, Object?> toMapSql() {}
}
