import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  AddProduct({required this.w, required this.h});
  final double h, w;
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
    print("ent up function");
    final ref = FirebaseStorage.instance.ref().child('images');
    Reference referenceImageToUpload = ref.child(fileName);
    print("ref retrvd");
    ;

    try {
      print("try in up fun");
      await referenceImageToUpload.putFile(file);
      print("putted file");
      final snapshot = await referenceImageToUpload.getDownloadURL();
      print("url done");
      return snapshot;
    } catch (e) {
      print("catchhhh");
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
      Wishlisted: false,
    );
    final json = product.toJson();
    await docProduct.set(json);
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
        backgroundColor: maincolour,
        title: const Text('Creating Product'),
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
                  child: (pickedFile == null)
                      ? Container(
                          width: 6 * widget.w / 7,
                          height: widget.h / 3,
                          color: Colors.grey,
                          child:
                              const Icon(Icons.camera_alt, color: Colors.white),
                        )
                      : Image.file(
                          File(pickedFile!.path!),
                          height: widget.h / 3,
                          width: 50,
                        )),
              Column(
                children: [
                  TextField(
                    controller: _nameController,
                    maxLength: 12,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(5),
                    child: TextField(
                      maxLength: 5,
                      keyboardType: TextInputType.number,
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
                    print("142");
                    // Access the entered data
                    final String name = _nameController.text;
                    final String description = _descriptionController.text;
                    final String price = _priceController.text;
                    final String quantity = _quantityController.text;
                    try {
                      print("try");
                      // final result = await FilePicker.platform.pickFiles();
                      // if (result != null) {
                      // final pickedFile = result.files.first;
                      final file = File(pickedFile!.path!);
                      final fileName = pickedFile!.name;
                      print("bef upl");
                      // Upload image
                      final imageUrl = await uploadFile(file, fileName);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("just uploaded file"),
                        backgroundColor: Colors.red,
                      ));
                      print("bef creating");
                      if (imageUrl.isNotEmpty &&
                          price.isNotEmpty &&
                          name.isNotEmpty &&
                          description.isNotEmpty) {
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
                          const SnackBar(
                              content: Text("All the fields are required")),
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
