import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/Login/logIn.dart';
import 'package:shop/constants.dart';
import 'package:shop/cubit/Cart.dart';
import 'package:shop/cubit/addProduct.dart';
import 'package:shop/cubit/viewProduct.dart';
import 'package:shop/cubit/wishlistPage.dart';
import 'package:shop/models/cart_model.dart';
import 'package:shop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shop/widgets/bottomNavigationbar.dart';
import 'package:shop/widgets/wishlist.dart';

class CartPage extends StatefulWidget {
  const CartPage({required this.w, required this.h});
  final double h, w;

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _currentIndex = 2;
  String? curUserId = FirebaseAuth.instance.currentUser?.uid;
  Icon heart = Icon(Icons.favorite);

  Future<void> updateProductQuantity({
    required CartProduct c,
    required int i,
  }) async {
    // Add your logic to update product wishlist status
    // Use productId to identify the product in the database
    int newQ = int.parse(c.Quantity) + i;
    if (newQ == 0) {
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(curUserId)
          .collection('cart')
          .doc(c.Id);
      doc.delete();
      return;
    }
    final docProduct = FirebaseFirestore.instance
        .collection('users')
        .doc(curUserId)
        .collection('cart')
        .doc(c.Id);

    final product = CartProduct(
      Id: c.Id,
      Quantity: newQ.toString(),
    );

    final json = product.toJson();
    await docProduct.update(json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("My Cart"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: StreamBuilder<List<CartProduct>>(
              stream: readProductsInCart(curUserId!),
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
                              return buildCartProduct(
                                  productUsingId, productsInCart[index]);
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xfff61f7a),
        onPressed: () {
          setState(() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AddProduct(h: widget.h, w: widget.w)));
          });
        },
        child: Icon(
          Icons.add,
          color: white,
        ),
      ),
      bottomNavigationBar: MyBottomWidget(
          currentIndex: 2,
          onTabTapped: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Handle navigation based on index
            if (_currentIndex == 0) {
              // Navigate to WishlistPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WishlistPage(
                      h: widget.h,
                      w: widget.w), // Replace with your WishlistPage
                ),
              );
            } else if (_currentIndex == 1) {
              // Navigate to CartPage
              Navigator.pop(context);
            }
          }),
    );
  }

  Widget buildCartProduct(Product product, CartProduct cartProduct) =>
      GestureDetector(
        child: Container(
          height: widget.h / 6,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: blueShadow,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(widget.w / 40),
          child: Row(
            children: [
              // Left side with product image
              Expanded(
                flex: 1, // Takes 3/5 of the available space
                child: Container(
                  padding: EdgeInsets.all(widget.w / 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 237, 243, 248),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
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
              // Right side with product details
              Expanded(
                flex: 1, // Takes 2/5 of the available space
                child: Container(
                  padding: EdgeInsets.all(widget.w / 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Product name
                      Text(
                        product.Name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.openSans(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      // Product price
                      Text(
                        product.Price,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.openSans(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Product quantity control
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () async {
                              // setState(() async {
                              await updateProductQuantity(
                                  c: cartProduct, i: -1);
                              // });
                            },
                          ),
                          Text(
                            cartProduct
                                .Quantity, // Replace with actual quantity
                            style: TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () async {
                              await updateProductQuantity(c: cartProduct, i: 1);
                            },
                          ),
                        ],
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

  Future<void> updateProductWishlist({
    required Product p,
    required bool wishlistStatus,
  }) async {
    // Add your logic to update product wishlist status
    // Use productId to identify the product in the database
    String status = 'Adding to Wishlist', updatedStatus = "Added to Wishlist";
    if (!wishlistStatus) {
      status = 'Removing from wishlist';
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(status)),
    );
    final docProduct =
        FirebaseFirestore.instance.collection('products').doc(p.Id);

    final product = Product(
      Id: p.Id,
      Description: p.Description,
      Name: p.Name,
      ImageUrl: p.ImageUrl,
      Price: p.Price,
      Quantity: p.Quantity,
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
        pId: p.Id,
        c: Colors.red,
      ) as Icon;
    });
  }

  Stream<List<CartProduct>> readProductsInCart(String curUserId) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(curUserId)
          .collection('cart')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CartProduct.fromJson(doc.data()))
              .toList());
}
