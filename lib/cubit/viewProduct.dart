import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/constants.dart';
import 'package:shop/cubit/editProduct.dart';
import 'package:shop/main.dart';
import 'package:shop/models/cart_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/wishlist_model.dart';
import 'package:shop/widgets/wishlist.dart';

class ViewProduct extends StatefulWidget {
  ViewProduct({required this.w, required this.h, required this.currentProduct});
  double w, h;
  Product currentProduct;

  @override
  State<ViewProduct> createState() => _ViewProductState();
}

class _ViewProductState extends State<ViewProduct> {
  String? curUserId = FirebaseAuth.instance.currentUser?.uid;
  Icon heart = Icon(Icons.favorite);

  Future<bool> doesProductExistInCart(String productId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(curUserId)
          .collection('cart')
          .doc(productId)
          .get();

      return snapshot.exists;
    } catch (e) {
      // Handle any potential errors (e.g., Firestore query error)
      print('Error checking product existence: $e');
      return false;
    }
  }

  Future<void> createCartProduct({
    required String pId,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("29")),
    );
    print("Creating product");
    final docProduct = FirebaseFirestore.instance
        .collection('users')
        .doc(curUserId)
        .collection('cart')
        .doc(pId);
    final product = CartProduct(
      Id: pId,
      Quantity: '1',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("38")),
    );
    final json = product.toJson();
    await docProduct.set(json);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("43")),
    );
  }

  Future<bool> doesProductExistInWishList(String productId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(curUserId)
          .collection('wishlist')
          .doc(productId)
          .get();

      return snapshot.exists;
    } catch (e) {
      // Handle any potential errors (e.g., Firestore query error)
      print('Error checking product existence: $e');
      return false;
    }
  }

  Future<void> createWishlistProduct({
    required String pId,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("29")),
    );
    print("Creating product");
    final docProduct = FirebaseFirestore.instance
        .collection('users')
        .doc(curUserId)
        .collection('wishlist')
        .doc(pId);
    final product = WishlistProduct(Id: pId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("38")),
    );
    final json = product.toJson();
    await docProduct.set(json);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("43")),
    );
  }

  Future<void> updateProductQuantity({
    required Product p,
    required int i,
  }) async {
    // Add your logic to update product wishlist status
    // Use productId to identify the product in the database
    print("53");
    int newQ = int.parse(p.Quantity) + i;
    final docProduct =
        FirebaseFirestore.instance.collection('products').doc(p.Id);

    print("58");
    final product = Product(
      Id: p.Id,
      Description: p.Description,
      Name: p.Name,
      ImageUrl: p.ImageUrl,
      Price: p.Price,
      Quantity: newQ.toString(),
      Wishlisted: p.Wishlisted,
    );

    print("69");
    final json = product.toJson();
    await docProduct.update(json);
    print("72");
    setState(() {
      heart = HeartIcon(
        pId: p.Id,
        c: Colors.red,
      ) as Icon;
    });
  }

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
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProduct(
                              currentProduct: widget.currentProduct)));
                },
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
                      onPressed: () async {
                        // setState(() async {
                        await updateProductWishlist(
                            p: widget.currentProduct,
                            wishlistStatus: !widget.currentProduct.Wishlisted);
                        // });
                      },
                      icon: HeartIcon(
                        pId: widget.currentProduct.Id,
                        c: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: GestureDetector(
                    child: Container(
                      height: 50,
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
                    ),
                    onTap: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("273")),
                      );
                      bool exists = await doesProductExistInCart(
                          widget.currentProduct.Id);
                      if (!exists) {
                        await createCartProduct(pId: widget.currentProduct.Id);
                      } else {
                        await updateProductQuantity(
                            p: widget.currentProduct, i: 1);
                      }
                    },
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

  Future<void> updateProductWishlist({
    required Product p,
    required bool wishlistStatus,
  }) async {
    String updatedStatus = "Added to Wishlist";
    final docProduct = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.currentProduct.Id);

    final product = Product(
      Id: widget.currentProduct.Id,
      Description: widget.currentProduct.Description,
      Name: widget.currentProduct.Name,
      ImageUrl: widget.currentProduct.ImageUrl,
      Price: widget.currentProduct.Price,
      Quantity: widget.currentProduct.Quantity,
      Wishlisted: wishlistStatus,
    );

    final json = product.toJson();
    await docProduct.update(json);
    if (!wishlistStatus) {
      updatedStatus = "Removed from Wishlist";
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(updatedStatus)),
    );
    setState(() {
      heart = HeartIcon(
        pId: widget.currentProduct.Id,
        c: white!,
      ) as Icon;
    });
  }
}
