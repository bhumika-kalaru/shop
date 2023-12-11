import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/constants.dart';
import 'package:shop/cubit/Cart.dart';
import 'package:shop/cubit/viewProduct.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/models/wishlist_model.dart';
import 'package:shop/widgets/bottomNavigationbar.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({required this.w, required this.h});
  final double h, w;
  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  int _currentIndex = 0;
  String? curUserId = FirebaseAuth.instance.currentUser?.uid;
  Stream<List<WishlistProduct>> readProductsInWishlist(String curUserId) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(curUserId)
          .collection('wishlist')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => WishlistProduct.fromJson(doc.data()))
              .toList());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: StreamBuilder<List<WishlistProduct>>(
              stream: readProductsInWishlist(curUserId!),
              builder: ((context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong! ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final productsInCart = snapshot.data!;
                  print('$productsInCart');

                  return Center(
                    child: ListView.builder(
                      itemCount: productsInCart.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance
                              .collection('products')
                              .doc(productsInCart[index].Id)
                              .get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(
                                color: white,
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              final productUsingId = Product.fromJson(
                                  snapshot.data!.data()
                                      as Map<String, dynamic>);
                              return buildWishlistProduct(
                                productUsingId,
                              );
                            } else {
                              return Text('No data available');
                            }
                          },
                        );
                      },
                    ),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MyBottomWidget(
          currentIndex: 0,
          onTabTapped: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Handle navigation based on index
            if (_currentIndex == 1) {
              // Navigate to WishlistPage
              Navigator.pop(context);
            } else if (_currentIndex == 2) {
              // Navigate to CartPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(h: widget.h, w: widget.w),
                ),
              );
            }
          }),
    );
  }

  Widget buildWishlistProduct(Product product) => GestureDetector(
        child: Container(
          width: 3 * widget.w / 7,
          height: widget.h / 3,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: blueShadow,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(widget.w / 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Displaying product image with blue background
              Expanded(
                flex: 3, // Takes 3/5 of the available space
                child: Container(
                  padding: EdgeInsets.all(widget.w / 25),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 237, 243, 248),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      product.ImageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2, // Takes 2/5 of the available space
                child: Container(
                  padding: EdgeInsets.all(widget.w / 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            product.Name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.openSans(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        product.Price,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.openSans(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewProduct(
                w: widget.w,
                h: widget.h,
                currentProduct: product,
              ),
            ),
          );
        },
      );
}
