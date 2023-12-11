import 'package:flutter/material.dart';

class CartProduct {
  late String Id;
  final String ProductId;
  CartProduct({
    required this.Id,
    required this.ProductId,
  });
  Map<String, dynamic> toJson() => {
        'id': Id,
        'productId': ProductId,
      };
  static CartProduct fromJson(Map<String, dynamic> json) =>
      CartProduct(Id: json['id'], ProductId: json['productId']);

  // Map<String, Object?> toMapSql() {}
}
