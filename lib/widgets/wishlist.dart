import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop/models/wishlist_model.dart';

class HeartIcon extends StatefulWidget {
  final String pId;
  final Color c;

  HeartIcon({required this.pId, required this.c});

  @override
  _HeartIconState createState() => _HeartIconState();
}

class _HeartIconState extends State<HeartIcon> {
  String? curUserId = FirebaseAuth.instance.currentUser?.uid;
  late Stream<bool> doesProductExistInCart;
  Future<void> updateProductWishlist({
    required String pId,
    required bool wishlistStatus,
  }) async {
    // Add your logic to update product wishlist status
    // Use productId to identify the product in the database
    String status = 'Adding to Wishlist', updatedStatus = "Added to Wishlist";
    if (!wishlistStatus) {
      status = 'Removing from wishlist';
      final doc = FirebaseFirestore.instance
          .collection('users')
          .doc(curUserId)
          .collection('wishlist')
          .doc(pId);
      doc.delete();
      return;
    }
    final docProduct =
        FirebaseFirestore.instance.collection('products').doc(pId);

    final product = WishlistProduct(Id: pId);

    final json = product.toJson();
    await docProduct.update(json);
    if (!wishlistStatus) {
      updatedStatus = "Removed from Wishlist";
    }
  }

  @override
  void initState() {
    super.initState();
    doesProductExistInCart = _checkProductExistence();
  }

  Stream<bool> _checkProductExistence() {
    try {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('wishlist')
          .doc(widget.pId)
          .snapshots()
          .map((snapshot) => snapshot.exists);
    } catch (e) {
      print('Error checking product existence: $e');
      return Stream.value(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: doesProductExistInCart,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Icon(Icons.favorite_border, color: widget.c);
        } else {
          final bool productExists = snapshot.data ?? false;

          return GestureDetector(
            onTap: () async {
              // Handle wishlisting logic here
              await updateProductWishlist(
                pId: widget.pId,
                wishlistStatus: !productExists,
              );
            },
            child: Icon(
              productExists ? Icons.favorite : Icons.favorite_border,
              color: widget.c,
            ),
          );
        }
      },
    );
  }
}
