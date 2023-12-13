import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/Login/logIn.dart';
import 'package:shop/constants.dart';
import 'package:shop/cubit/Cart.dart';
import 'package:shop/cubit/addProduct.dart';
import 'package:shop/cubit/product_page.dart';
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
  double totalPrice = 0;
  bool isUpdatingQuantity = false;
  bool placingOrder = false;
  int _currentIndex = 2;
  String? curUserId = FirebaseAuth.instance.currentUser?.uid;
  Icon heart = Icon(Icons.favorite);
  late List<CartProduct?> productsInCart = [];

  Future<List<CartProduct?>> getCartProducts(String userId) async {
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    return cartSnapshot.docs
        .map((doc) => doc.exists
            ? CartProduct.fromJson(doc.data() as Map<String, dynamic>)
            : null)
        .toList();
  }

  Future<double> calculateTotalPrice(List<CartProduct?> cartProducts) async {
    totalPrice = 0;
    for (var cartProduct in cartProducts) {
      if (cartProduct != null) {
        final productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(cartProduct.Id)
            .get();

        if (productSnapshot.exists) {
          final product = Product.fromJson(
            productSnapshot.data() as Map<String, dynamic>,
          );

          // Assuming the price is stored as a String, you may need to adjust this
          totalPrice +=
              double.parse(product.Price) * int.parse(cartProduct.Quantity);
        }
      }
    }

    return totalPrice;
  }

  Future<double> calculateTotalPriceUsingUserId(String userId) async {
    double totalPriceUsingId = 0;

    // Retrieve cart products for the given user
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    for (QueryDocumentSnapshot cartDoc in cartSnapshot.docs) {
      if (cartDoc.exists) {
        final productSnapshot = await FirebaseFirestore.instance
            .collection('products')
            .doc(cartDoc['productId']) // Replace with the actual field name
            .get();

        if (productSnapshot.exists) {
          final product = Product.fromJson(
            productSnapshot.data() as Map<String, dynamic>,
          );

          // Assuming the price is stored as a String, you may need to adjust this
          totalPrice += double.parse(product.Price) *
              int.parse(
                  cartDoc['quantity']); // Replace with the actual field name
        }
      }
    }

    return totalPriceUsingId;
  }

  Future<bool> isCartEmpty(String userId) async {
    QuerySnapshot isCart = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();
    if (isCart.docs.isEmpty) {
      return true;
    }
    return false;
  }

  Future<void> clearCart(String userId) async {
    setState(() {
      placingOrder = true;
    });

    // Check if the cart is empty
    QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    if (cartSnapshot.docs.isEmpty) {
      // Cart is empty, show a message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text("Cart is empty")),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      ).then((_) {
        setState(() {
          placingOrder = false;
        });
      });
      return;
    } else {
      // Cart is not empty, proceed with order placement

      // Update quantity to 0 for each cart product
      for (QueryDocumentSnapshot cartDoc in cartSnapshot.docs) {
        final cartProduct =
            CartProduct.fromJson(cartDoc.data() as Map<String, dynamic>);
        await updateProductQuantity(
            c: cartProduct, i: -int.parse(cartProduct.Quantity));
      }

      // Show order placed successfully message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text("Order placed successfully")),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      ).then((_) {
        setState(() {
          placingOrder = false;
        });
      });
    }
  }

  Future<void> handleCheckout() async {
    List<CartProduct?> cartProducts = await getCartProducts(curUserId!);
    if (cartProducts != null) {
      // await addOrderDetails(curUserId!, cartProducts);
      // Clear the cart
      await clearCart(
          curUserId!); // Show a success message or navigate to a confirmation screen
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cart is Empty')),
      );
    }
  }

  Future<void> updateProductQuantity({
    required CartProduct c,
    required int i,
  }) async {
    setState(() {
      isUpdatingQuantity =
          true; // Set the flag to true when starting the update
    });
    // Add your logic to update product wishlist status
    // Use productId to identify the product in the database

    int newQ = int.parse(c.Quantity) + i;

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
    if (newQ == 0) {
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(curUserId)
          .collection('cart')
          .doc(c.Id);
      doc.delete();
    }
    setState(() {
      isUpdatingQuantity =
          false; // Set the flag to false when the update is complete
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("My Cart"),
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.only(left: 4),
          child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
              )),
        ),
      ),
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 0.11 * widget.h),
            color: Colors.white,
            child: StreamBuilder<List<CartProduct>>(
              stream: readProductsInCart(curUserId!),
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
                    child: Text('No products added to Cart'),
                  );
                } else if (snapshot.hasData) {
                  productsInCart = snapshot.data!;
                  print('$productsInCart');

                  return Center(
                    child: ListView.builder(
                      itemCount: productsInCart.length,
                      itemBuilder: (context, index) {
                        return FutureBuilder<
                            DocumentSnapshot<Map<String, dynamic>>>(
                          future: FirebaseFirestore.instance
                              .collection('products')
                              .doc(productsInCart[index]!.Id)
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
                                  productUsingId, productsInCart[index]!);
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
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20))),
              padding: EdgeInsets.only(
                left: 20,
                right: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<double>(
                    future: calculateTotalPrice(productsInCart),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(
                          color: white,
                        );
                      } else if (snapshot.hasData) {
                        final totalPrice = snapshot.data!;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '  Total: ',
                              style: TextStyle(
                                  color: maincolour,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              ' \₹ ${totalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: maincolour,
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Text('');
                      }
                    },
                  ),
                  GestureDetector(
                    child: Container(
                      margin: EdgeInsets.all(12),
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      height: widget.h / 12,
                      decoration: BoxDecoration(
                          color: darkPink, // Adjust the color as needed
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_checkout_sharp,
                                color: white,
                                size: 28,
                              ),
                              // Expanded(child: Container()),
                              Text(
                                ' Checkout',
                                style: GoogleFonts.openSans(
                                    textStyle: TextStyle(
                                        color: Colors.white, fontSize: 24)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      await handleCheckout();
                      totalPrice = 0;
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          ),
          if (isUpdatingQuantity || placingOrder)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Product name
                      Text(
                        product.Name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.openSans(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Container(
                              height: 30,
                              width: 35,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors
                                    .grey[300], // Set the background color
                                borderRadius: BorderRadius.circular(
                                    30.0), // Optional: add border radius
                              ),
                              child: Center(
                                child: Icon(Icons.remove),
                              ),
                            ),
                            onTap: () async {
                              // setState(() async {
                              await updateProductQuantity(
                                  c: cartProduct, i: -1);
                              // });
                            },
                          ),
                          Text(
                            ' ' +
                                cartProduct.Quantity +
                                ' ', // Replace with actual quantity
                            style: TextStyle(fontSize: 18),
                          ),
                          GestureDetector(
                            child: Container(
                              height: 30,
                              width: 35,
                              margin: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors
                                    .grey[300], // Set the background color
                                borderRadius: BorderRadius.circular(
                                    30), // Optional: add border radius
                              ),
                              child: Icon(Icons.add),
                            ),
                            onTap: () async {
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
