import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String ImageDownloadUrl = '';
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

  Future<void> createProduct({
    required String des,
    required String name,
    required String price,
    required String quantity,
    required String imageUrl,
  }) async {
    print("Creating product");
    final docProduct = FirebaseFirestore.instance.collection('products').doc();
    final product = Product(
      Id: docProduct.id,
      Description: des,
      Name: name,
      ImageUrl: imageUrl,
      Price: price,
      Quantity: quantity,
    );
    final json = product.toJson();
    await docProduct.set(json);
    print("Product created");
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // double h = (MediaQuery.of(context).size.height),
    //     w = (MediaQuery.of(context).size.width);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Page'),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: _getImage,
                  child: (pickedFile == null)
                      ? Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey,
                          child:
                              const Icon(Icons.camera_alt, color: Colors.white),
                        )
                      : Image.file(
                          File(pickedFile!.path!),
                          height: 50,
                          width: 50,
                        )),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Access the entered data
                  final String name = _nameController.text;
                  final String description = _descriptionController.text;
                  final String price = _priceController.text;
                  final String quantity = _quantityController.text;
                  try {
                    // final result = await FilePicker.platform.pickFiles();
                    // if (result != null) {
                    // final pickedFile = result.files.first;
                    final file = File(pickedFile!.path!);
                    final fileName = pickedFile!.name;

                    // Upload image
                    final imageUrl = await uploadFile(file, fileName);

                    if (imageUrl.isNotEmpty) {
                      // Image upload successful, create product
                      await createProduct(
                        des: description,
                        name: name,
                        imageUrl: imageUrl,
                        price: price,
                        quantity: quantity,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Product created successfully")),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error uploading image")),
                      );
                    }
                    // }
                  } catch (e) {
                    print("Error: $e");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("An error occurred")),
                    );
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
