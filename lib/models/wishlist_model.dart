import 'package:flutter/material.dart';

class WishlistProduct {
  final String Id;
  WishlistProduct({
    required this.Id,
  });
  Map<String, dynamic> toJson() => {
        'Id': Id,
      };
  static WishlistProduct fromJson(Map<String, dynamic> json) =>
      WishlistProduct(Id: json['Id']);

  // Map<String, Object?> toMapSql() {}
}
