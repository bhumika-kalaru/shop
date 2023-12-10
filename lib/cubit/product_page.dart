import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/Login/logIn.dart';
import 'package:shop/constants.dart';
import 'package:shop/cubit/addProduct.dart';
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
        actions: [
          GestureDetector(
            onTap: () {
              setState(() {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddProduct()));
              });
            },
            child: Icon(Icons.add),
          ),
          SizedBox(width: 15),
          SizedBox(
            width: 5,
          )
        ],
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

                  return ListView(
                    children: products.map(buildProduct).toList(),
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
    );
  }

  Widget buildProduct(Product product) => GestureDetector(
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: blueShadow,
            borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              product.Name,
              style: GoogleFonts.openSans(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 32),
            ),
            Text(
              'Description: ' + product.Description,
              // style: lightText,
            ),
            Text('Price: ' + product.Price,
                style: GoogleFonts.openSans(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))
          ],
        ),
      ),
      onTap: () {});
  Stream<List<Product>> readproducts() => FirebaseFirestore.instance
      .collection('products')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Product.fromJson(doc.data())).toList());
}
