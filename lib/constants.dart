import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// late double height, width;
final Normal = GoogleFonts.montserrat(fontSize: 40);
final gabr = GoogleFonts.gabriela(fontSize: 24);

final Color? white = Colors.white;
final Color? blue = Colors.blue;
final Color? black = Colors.black;
// final Color? maincolour = Color(0xff2B3467);
final Color? BG = Color.fromARGB(255, 237, 239, 253);
final Color? maincolour = Color(0xff2B3467);
// final Color pink = Color(0xffEB455F);
final Color cream = Color(0xffFCFFE7);
// 0xff2B3467

final Color pink = Color.fromARGB(255, 252, 242, 247);
final Color amber = Colors.amber;
final Color one = maincolour!;
// final Color cream = Color(0xfff6d9b8);

List<BoxShadow> blueShadow = [
  BoxShadow(
      color: Color.fromARGB(255, 190, 196, 230),
      blurRadius: 10,
      offset: Offset(0, 4))
];
List<BoxShadow> pinkShadow = [
  BoxShadow(
      color: Color.fromARGB(255, 252, 242, 247),
      blurRadius: 12,
      offset: Offset(0, 4))
];




// class MyWidget extends StatelessWidget {
//   const MyWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     height = MediaQuery.of(context).size.height;
//     width = (MediaQuery.of(context).size.height);
//     return Container();
//   }
// }
