import 'package:flutter/material.dart';

class HeartIcon extends StatefulWidget {
  final bool isWishlisted;
  final Color c;

  HeartIcon({required this.isWishlisted, required this.c});

  @override
  _HeartIconState createState() => _HeartIconState();
}

class _HeartIconState extends State<HeartIcon> {
  @override
  Widget build(BuildContext context) {
    return Icon(
      widget.isWishlisted ? Icons.favorite : Icons.favorite_border,
      color: widget.c,
    );
  }
}
