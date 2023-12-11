import 'package:flutter/material.dart';

class CartProduct {
  late String Id;
  final String ProductId;
  final String Quantity;
  CartProduct({
    required this.Id,
    required this.ProductId,
    required this.Quantity,
  });
  Map<String, dynamic> toJson() => {
        'id': Id,
        'productId': ProductId,
        'quantity': Quantity,
      };
  static CartProduct fromJson(Map<String, dynamic> json) => CartProduct(
      Id: json['id'], ProductId: json['productId'], Quantity: json['quantity']);

  // Map<String, Object?> toMapSql() {}
}
