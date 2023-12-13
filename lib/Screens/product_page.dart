import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/Login/logIn.dart';
import 'package:shop/constants.dart';
import 'package:shop/Screens/Cart.dart';
import 'package:shop/Screens/addProduct.dart';
import 'package:shop/Screens/viewProduct.dart';
import 'package:shop/Screens/wishlistPage.dart';
import 'package:shop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shop/widgets/bottomNavigationbar.dart';
import 'package:shop/widgets/wishlist.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({required this.w, required this.h});
  final double h, w;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  int _currentIndex = 1;
  String? curUserId = FirebaseAuth.instance.currentUser?.uid;
  Icon heart = Icon(Icons.favorite);
  Future<String> getUserRole() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Get the user's role from Firestore
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (snapshot.exists) {
          // Return the user's role
          return curUserId!; // Provide a default role
        } else {
          // User document not found
          throw Exception("User document not found");
        }
      } else {
        // User is not authenticated
        throw Exception("User is not authenticated");
      }
    } catch (e) {
      print("Error getting user role: $e");
      throw Exception("Error getting user role");
    }
  }

  Future<bool> _checkProductExistenceInWishlist(String productId) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('wishlist')
          .doc(productId)
          .get();

      return snapshot.exists;
    } catch (e) {
      print('Error checking product existence: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.red,
              ),
              tileColor: white,
              title: Center(child: Text('Log Out')),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LogIn()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Products"),
        centerTitle: true,
        // actions: [
        //   GestureDetector(
        //     onTap: () {
        //       setState(() {
        //         Navigator.push(context,
        //             MaterialPageRoute(builder: (context) => AddProduct()));
        //       });
        //     },
        //     child: Icon(Icons.add),
        //   ),
        //   SizedBox(width: 15),
        //   SizedBox(
        //     width: 5,
        //   )
        // ],
      ),
      body: Stack(
        children: [
          Container(
              color: Colors.white,
              child: StreamBuilder<List<Product>>(
                stream: readproducts(),
                builder: ((context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text('No products available.'),
                    );
                  } else {
                    final products = snapshot.data!;
                    print('$products');

                    return Center(
                      child: ListView.builder(
                        itemCount: (products.length / 2).ceil() *
                            2, // Ensure even number of items
                        itemBuilder: (context, index) {
                          final int firstIndex = index * 2;
                          final int secondIndex = firstIndex + 1;

                          return Wrap(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (firstIndex < products.length)
                                buildProduct(products[firstIndex]),
                              if (secondIndex < products.length)
                                buildProduct(products[secondIndex]),
                              if (secondIndex >= products.length)
                                // Expanded(
                                //   child:
                                Container(),
                              // ), // Add an empty container for odd number of products
                            ],
                          );
                        },
                      ),
                    );
                  }
                }),
              ))
        ],
      ),
      floatingActionButton: FutureBuilder<String>(
        future: getUserRole(), // Assuming getUserRole returns a Future<String>
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(); // Return an empty container while waiting for user role
          } else if (snapshot.hasData &&
              snapshot.data == "P0hlA6S1pebQKv2QEmld0J8rXfY2") {
            return FloatingActionButton(
              backgroundColor: Color(0xfff61f7a),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProduct(h: widget.h, w: widget.w),
                  ),
                );
              },
              child: Icon(
                Icons.add,
                color: white,
              ),
            );
          } else {
            return Container(); // Return an empty container if user is not admin
          }
        },
      ),
      bottomNavigationBar: MyBottomWidget(
          currentIndex: 1,
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

  Widget buildProduct(Product product) => GestureDetector(
        child: Container(
          width: 0.43 * widget.w,
          height: 0.34 * widget.h,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: blueShadow,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(widget.w / 30),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.Name.length > 10
                                ? '${product.Name.substring(0, 10)}'
                                : product.Name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.openSans(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          // Heart icon for wishlisting
                          IconButton(
                            onPressed: () async {
                              // Handle wishlisting logic here
                              await updateProductWishlist(
                                p: product,
                                wishlistStatus:
                                    await _checkProductExistenceInWishlist(
                                        product.Id),
                              );
                            },
                            icon: HeartIcon(
                              pId: product.Id,
                              c: Colors.red,
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
    setState(() {
      heart = HeartIcon(
        pId: p.Id,
        c: Colors.red,
      ) as Icon;
    });
  }

  Stream<List<Product>> readproducts() => FirebaseFirestore.instance
      .collection('products')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList());
}
