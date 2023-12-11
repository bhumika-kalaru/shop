import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/Login/logIn.dart';
import 'package:shop/constants.dart';
import 'package:shop/cubit/Cart.dart';
import 'package:shop/cubit/addProduct.dart';
import 'package:shop/cubit/viewProduct.dart';
import 'package:shop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shop/widgets/wishlist.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({required this.w, required this.h});
  final double h, w;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? curUserId = FirebaseAuth.instance.currentUser?.uid;
  Icon heart = Icon(Icons.favorite);
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
                leading: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CartPage(h: widget.h, w: widget.w)));
              },
              icon: Icon(Icons.shopping_cart, color: maincolour),
            )),
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
          Center(
            child: Container(
              color: Colors.white,
              child: StreamBuilder<List<Product>>(
                stream: readproducts(),
                builder: ((context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong! ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    final products = snapshot.data!;
                    print('$products');

                    return Center(
                      child: ListView.builder(
                        itemCount: (products.length / 2).ceil(),
                        itemBuilder: (context, index) {
                          final int firstIndex = index * 2;
                          final int secondIndex = firstIndex + 1;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (firstIndex < products.length)
                                buildProduct(products[firstIndex]),
                              if (secondIndex < products.length)
                                buildProduct(products[secondIndex]),
                            ],
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
    );
  }

  Widget buildProduct(Product product) => GestureDetector(
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
                          // Heart icon for wishlisting
                          IconButton(
                            onPressed: () async {
                              // Handle wishlisting logic here
                              await updateProductWishlist(
                                p: product,
                                wishlistStatus: !product.Wishlisted,
                              );
                            },
                            icon: HeartIcon(
                              isWishlisted: product.Wishlisted,
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
        isWishlisted: !p.Wishlisted,
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
