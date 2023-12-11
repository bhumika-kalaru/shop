import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/Login/logIn.dart';
import 'package:shop/constants.dart';
import 'package:shop/cubit/addProduct.dart';
import 'package:shop/cubit/viewProduct.dart';
import 'package:shop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({required this.w, required this.h});
  final double h, w;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListTile(
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
                          mainAxisAlignment: MainAxisAlignment.start,
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
        height: widget.h / 5,
        padding: EdgeInsets.all(widget.w / 20),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: blueShadow,
            borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(widget.w / 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              product.Name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.openSans(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 32),
            ),
            Text(
              'Description: ' + product.Description,
              overflow: TextOverflow.ellipsis,
              // style: lightText,
            ),
            Text('Price: ' + product.Price,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.openSans(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProduct(
                    w: widget.w, h: widget.h, currentProduct: product)));
      });
  Stream<List<Product>> readproducts() => FirebaseFirestore.instance
      .collection('products')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList());
}
