import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/home/sellerHome.dart';

import '../../../widgets/button.dart';
import '../../../widgets/inputfield.dart';

class AddProducts extends StatefulWidget {
  const AddProducts({super.key});

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String img = '';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    priceController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  Future selectImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadImage() async {
    final path = 'images/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});
    final imageURL = await snapshot.ref.getDownloadURL();
    setState(() {
      img = imageURL;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Products"),
          centerTitle: true,
        ),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Center(
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                  padding: EdgeInsets.all(10.0),
                                  child: CircularProgressIndicator.adaptive()),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  selectImage();
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      shape: BoxShape.rectangle,
                                      border: const Border(
                                        top: BorderSide(
                                            width: 2.0, color: Colors.black),
                                        left: BorderSide(
                                            width: 2.0, color: Colors.black),
                                        right: BorderSide(
                                            width: 2.0, color: Colors.black),
                                        bottom: BorderSide(
                                            width: 2.0, color: Colors.black),
                                      ),
                                    ),
                                    width: 340,
                                    height: 250,
                                    child: pickedFile != null
                                        ? Stack(children: [
                                            Center(
                                              child: Expanded(
                                                child: Container(
                                                  color: Colors.blue[100],
                                                  child: ColorFiltered(
                                                    colorFilter:
                                                        ColorFilter.mode(
                                                            Colors
                                                                .black
                                                                .withOpacity(
                                                                    0.5),
                                                            BlendMode.darken),
                                                    child: Image.file(
                                                      File(pickedFile!.path!),
                                                      width: double.infinity,
                                                      fit: BoxFit.fill,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Center(
                                              child: Icon(
                                                Icons.photo,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                            )
                                          ])
                                        : const Icon(Icons.photo)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: InputField(
                                  isPassword: false,
                                  hasInitValue: false,
                                  labelText: "Name",
                                  icondata: Icons.dashboard,
                                  controller: nameController,
                                  isAuthField: false,
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: InputField(
                                  isPassword: false,
                                  hasInitValue: false,
                                  labelText: "Price",
                                  icondata: Icons.attach_money_outlined,
                                  controller: priceController,
                                  isAuthField: false,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  color: Colors.white,
                                  width: 300,
                                  child: TextFormField(
                                    obscureText: false,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 1.0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      labelText: "Short Description",
                                      hintText: "Enter Short Description",
                                      prefixIcon: const Icon(Icons.description),
                                    ),
                                    controller: descriptionController,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: InputField(
                                  isPassword: false,
                                  hasInitValue: false,
                                  labelText: "Quantity",
                                  icondata: Icons.numbers,
                                  controller: quantityController,
                                  isAuthField: false,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: MyButton(
                                    isRed: false,
                                    text: "Add Product",
                                    onPressed: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                      uploadImage().then((value) {
                                        createProduct(
                                          name: nameController.text.trim(),
                                          price: priceController.text.trim(),
                                          quantity:
                                              quantityController.text.trim(),
                                          description:
                                              descriptionController.text.trim(),
                                          imgURL: img,
                                        ).then((value) =>
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SellerHome())));
                                      });
                                    }),
                              ),
                            ],
                          ),
                        )),
            )));
  }

  Future createProduct({
    required String name,
    required String price,
    required String quantity,
    required String description,
    required String imgURL,
  }) async {
    //refer doc
    final docProduct =
        FirebaseFirestore.instance.collection('products').doc("T-$name");
    final product = Products(
        name: name,
        price: price,
        quantity: quantity,
        description: description,
        imgURL: imgURL);
    final json = product.toJson();
    try {
      await docProduct.set(json);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

class Products {
  final String name;
  final String price;
  final String quantity;
  final String description;
  final String imgURL;

  Products({
    required this.name,
    required this.price,
    required this.quantity,
    required this.description,
    required this.imgURL,
  });

  factory Products.fromJson(Map<String, dynamic> json) {
    return Products(
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      description: json['description'],
      imgURL: json['imgURL'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'description': description,
      'imgURL': imgURL,
    };
  }
}
