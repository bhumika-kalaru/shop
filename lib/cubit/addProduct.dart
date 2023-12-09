import 'dart:io';
import 'package:shop/models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProduct extends StatefulWidget {
  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  late Image _image = Image.asset('assets/google_light.png');
  final picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path) as Image;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Page'),
        actions: [
          IconButton(
              onPressed: () {
                final String name = _nameController.text;
                final String description = _descriptionController.text;
                createProduct(des: description, name: name, imagetoadd: _image);
              },
              icon: Icon(Icons.check))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
                onTap: _getImage,
                child: _image == null
                    ? Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      )
                    : _image),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Access the entered data
                final String name = _nameController.text;
                final String description = _descriptionController.text;

                // Do something with the data (e.g., save it, send it, etc.)
                // For now, just print it to the console
                print('Name: $name');
                print('Description: $description');
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future createProduct(
      {required String des,
      required String name,
      required Image imagetoadd}) async {
    final docProduct =
        FirebaseFirestore.instance.collection('products').doc('my-id');
    final product = Product(
        id: docProduct.id, description: des, name: name, img: imagetoadd);
    final json = product.toJson();
    await docProduct.set(json);
  }
}
