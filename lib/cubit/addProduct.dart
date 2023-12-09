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

  Future uploadFile() async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);
    final fileName = pickedFile!.name;
    final ref = FirebaseStorage.instance.ref().child('images');
    Reference referenceImageToUpload = ref.child(fileName);
    // uploadTask = ref.putFile(file);
    try {
      uploadTask = referenceImageToUpload.putFile(file);
      print('36');
      final snapshot = await uploadTask!.whenComplete(() {});
      print('38');
      final urlDownload = await snapshot.ref.getDownloadURL();
      print('40');
      ImageDownloadUrl = await referenceImageToUpload.getDownloadURL();
      print('42');
    } catch (e) {}
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double h = (MediaQuery.of(context).size.height),
        w = (MediaQuery.of(context).size.width);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Page'),
        actions: [
          IconButton(
              onPressed: () {
                final String name = _nameController.text;
                final String description = _descriptionController.text;
                uploadFile();
                if (ImageDownloadUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No Image Uploaded")));
                  return;
                }
                createProduct(
                    des: description, name: name, imageUrl: ImageDownloadUrl);
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: Padding(
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
                        height: h / 3,
                        width: w / 3,
                      )),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
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
              onPressed: () {
                // Access the entered data
                final String name = _nameController.text;
                final String description = _descriptionController.text;

                // Do something with the data (e.g., save it, send it, etc.)
                // For now, just print it to the console
                print('Name: $name');
                print('Description: $description');
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Future createProduct(
      {required String des,
      required String name,
      required String imageUrl}) async {
    final docProduct =
        FirebaseFirestore.instance.collection('products').doc('my-id');
    final product = Product(
        id: docProduct.id, description: des, name: name, imageUrl: imageUrl);
    final json = product.toJson();
    await docProduct.set(json);
  }
}
