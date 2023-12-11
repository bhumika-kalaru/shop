import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/constants.dart';
import 'package:shop/main.dart';
import 'package:shop/models/product_model.dart';

class ViewProduct extends StatefulWidget {
  ViewProduct({required this.w, required this.h, required this.currentProduct});
  double w, h;
  Product currentProduct;

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  Icon heart = Icon(
    Icons.favorite_border,
    color: Colors.white,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: maincolour,
        leading: Container(
          margin: EdgeInsets.only(left: 4),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: white,
              )),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: IconButton(
                onPressed: () async {},
                icon: Icon(
                  Icons.edit,
                  color: pink,
                )),
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
              child: Column(
            children: [
              Expanded(
                child: Container(
                    // color: pink,
                    ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        // color: Colors.grey[100],
                        // margin: EdgeInsets.all(30),
                        padding: EdgeInsets.only(top: 90),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.all(20),
                              child: Text(
                                widget.currentProduct.Description,
                                style: GoogleFonts.cabin(
                                    textStyle: TextStyle(color: Colors.grey),
                                    fontSize: 18),
                              ),
                            ),
                            SizedBox(
                              height: 80,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )),
          Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Hero(
                    tag: 1,
                    child: Image.network(
                      widget.currentProduct.ImageUrl,
                    ),
                  ),
                ),
              ),
              Expanded(child: Container())
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: widget.h / 12,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  color: BG,
                  boxShadow: blueShadow,
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.currentProduct.Name,
                        style: GoogleFonts.openSans(
                            textStyle: TextStyle(color: maincolour),
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      ),
                      Text(
                        widget.currentProduct.Price,
                        style: GoogleFonts.dangrek(
                          textStyle: TextStyle(color: maincolour, fontSize: 30),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 130,
              // margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  // color: pink,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: maincolour),
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            if (widget.currentProduct.Wishlisted) {
                              heart = Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                              );
                            } else {
                              heart = Icon(
                                Icons.favorite,
                                color: Colors.white,
                              );
                            }
                          });
                        },
                        icon: heart),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Container(
                    height: 60,
                    child: Center(
                        child: Text(
                      'Add to Cart',
                      style: GoogleFonts.openSans(
                          textStyle:
                              TextStyle(color: Colors.white, fontSize: 24)),
                    )),
                    decoration: BoxDecoration(
                        color: maincolour,
                        borderRadius: BorderRadius.circular(30)),
                  ))
                ],
              ),
            ),
          ),
          // Container(
          //   // margin: EdgeInsets.only(top: 40),
          //   child: Align(
          //     alignment: Alignment.topCenter,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //       children: [
          //         IconButton(
          //             onPressed: () {
          //               Navigator.pop(context);
          //             },
          //             icon: Icon(
          //               Icons.arrow_back_ios,
          //               color: maincolour,
          //             )),
          //         IconButton(
          //             onPressed: () async {},
          //             icon: Icon(
          //               Icons.edit,
          //               color: maincolour,
          //             ))
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
