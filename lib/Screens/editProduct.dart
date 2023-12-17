import 'dart:ffi';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProduct extends StatefulWidget {
  final Product currentProduct;

  EditProduct({required this.currentProduct});

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  Future _getImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future<String> uploadFile(File file, String fileName) async {
    final ref = FirebaseStorage.instance.ref().child('images');
    Reference referenceImageToUpload = ref.child(fileName);

    try {
      await referenceImageToUpload.putFile(file);
      final snapshot = await referenceImageToUpload.getDownloadURL();
      return snapshot;
    } catch (e) {
      print("Error uploading file: $e");
      return '';
    }
  }

  Future<void> updateProduct({
    required String des,
    required String name,
    required String price,
    required String imageUrl,
  }) async {
    print("Updating product");
    final docProduct = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.currentProduct.Id);

    final product = Product(
      Id: widget.currentProduct.Id,
      Description: des,
      Name: name,
      ImageUrl: imageUrl,
      Price: price,
      Quantity: widget.currentProduct.Quantity,
      Wishlisted: widget.currentProduct.Wishlisted,
    );

    final json = product.toJson();
    await docProduct.update(json);
    print("Product updated");
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  late String newImageUrl = '';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentProduct.Name;
    _priceController.text = widget.currentProduct.Price;
    _descriptionController.text = widget.currentProduct.Description;
    newImageUrl = widget.currentProduct.ImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: maincolour,
        title: const Text(
          'Editing Product',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                final doc = await FirebaseFirestore.instance
                    .collection('products')
                    .doc(widget.currentProduct.Id);
                doc.delete();
                Navigator.pop(context);
                Navigator.pop(context);
                return;
              },
              icon: Icon(
                Icons.delete,
                color: Colors.red,
              ))
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _getImage,
                child: Container(
                  width: 6 * MediaQuery.of(context).size.width / 7,
                  height: MediaQuery.of(context).size.height / 3,
                  color: Colors.grey,
                  child: (pickedFile == null)
                      ? Image.network(
                          widget.currentProduct.ImageUrl,
                          height: MediaQuery.of(context).size.height / 3,
                          width: 50,
                        )
                      : Image.file(
                          File(pickedFile!.path!),
                          height: MediaQuery.of(context).size.height / 3,
                          width: 50,
                        ),
                ),
              ),
              Column(
                children: [
                  TextField(
                    controller: _nameController,
                    maxLength: 15,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () async {
                    final String name = _nameController.text;
                    final String description = _descriptionController.text;
                    final String price = _priceController.text;
                    try {
                      if (pickedFile != null) {
                        final file = File(pickedFile!.path!);
                        final fileName = pickedFile!.name;

                        final imageUrl = await uploadFile(file, fileName);

                        if (imageUrl.isNotEmpty &&
                            price.isNotEmpty &&
                            name.isNotEmpty &&
                            description.isNotEmpty) {
                          await updateProduct(
                            des: description,
                            name: name,
                            imageUrl: imageUrl,
                            price: price,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Product updated successfully")),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("All the fields are required")),
                          );
                        }
                      } else if (widget.currentProduct.ImageUrl.isNotEmpty) {
                        final imageUrl = widget.currentProduct.ImageUrl;

                        if (imageUrl.isNotEmpty &&
                            price.isNotEmpty &&
                            name.isNotEmpty &&
                            description.isNotEmpty) {
                          await updateProduct(
                            des: description,
                            name: name,
                            imageUrl: imageUrl,
                            price: price,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Product updated successfully")),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("All the fields are required")),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Please pick an image")),
                        );
                      }
                    } catch (e) {
                      print("Error: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("An error occurred")),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
