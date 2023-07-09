import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/home/sellerHome.dart';

import '../../../widgets/button.dart';
import '../../../widgets/inputfield.dart';

class ProductDetails extends StatefulWidget {
  final String? productName;
  final bool? isSeller;
  const ProductDetails({
    super.key,
    this.productName,
    this.isSeller,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  bool isLoading = false;
  bool isEditing = false;

  @override
  void dispose() {
    priceController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  alertBox(String title, String message, VoidCallback onPressed) async {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(onPressed: onPressed, child: const Text("OK"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isEditing
            ? const Text("Edit Details")
            : const Text("Product Details"),
        centerTitle: true,
        leading: isEditing
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isEditing = false;
                  });
                },
                icon: const Icon(Icons.close))
            : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
        actions: [
          isEditing
              ? IconButton(
                  onPressed: () {
                    updateProduct(
                      name: nameController.text.trim(),
                      price: priceController.text.trim(),
                      description: descriptionController.text.trim(),
                      quantity: quantityController.text.trim(),
                    ).then((value) => Navigator.pop(context));
                  },
                  icon: const Icon(Icons.check))
              : const SizedBox.shrink(),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: readProducts,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.data == null) {
            return const Center(
              child: Text("No products yet."),
            );
          }

          return GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.rectangle,
                        border: const Border(
                          top: BorderSide(width: 2.0, color: Colors.black),
                          left: BorderSide(width: 2.0, color: Colors.black),
                          right: BorderSide(width: 2.0, color: Colors.black),
                          bottom: BorderSide(width: 2.0, color: Colors.black),
                        ),
                      ),
                      width: 340,
                      height: 250,
                      child: Expanded(
                        child: SizedBox(
                          width: 120,
                          height: 150,
                          child: FadeInImage(
                            placeholder: const AssetImage("assets/loading.gif"),
                            image:
                                NetworkImage(snapshot.data!.docs[0]['imgURL']),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InputField(
                        isEnabled: isEditing,
                        isPassword: false,
                        hasInitValue: true,
                        labelText: snapshot.data!.docs[0]['name'],
                        icondata: Icons.dashboard,
                        controller: isEditing
                            ? nameController
                            : TextEditingController(
                                text: snapshot.data!.docs[0]['name']),
                        isAuthField: false,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InputField(
                        isEnabled: isEditing,
                        isPassword: false,
                        hasInitValue: true,
                        labelText: snapshot.data!.docs[0]['price'],
                        icondata: Icons.attach_money_outlined,
                        controller: isEditing
                            ? priceController
                            : TextEditingController(
                                text: snapshot.data!.docs[0]['price']),
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
                          enabled: isEditing,
                          obscureText: false,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade400, width: 1.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            labelText: snapshot.data!.docs[0]['description'],
                            hintText: "Enter Short Description",
                            prefixIcon: const Icon(Icons.description),
                          ),
                          controller: isEditing
                              ? descriptionController
                              : TextEditingController(
                                  text: snapshot.data!.docs[0]['description']),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: InputField(
                        isEnabled: isEditing,
                        isPassword: false,
                        hasInitValue: true,
                        labelText: snapshot.data!.docs[0]['quantity'],
                        icondata: Icons.numbers,
                        controller: isEditing
                            ? quantityController
                            : TextEditingController(
                                text: snapshot.data!.docs[0]['quantity']),
                        isAuthField: false,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: isEditing
                          ? MyButton(
                              text: "Delete Item",
                              onPressed: () {
                                alertBox("Delete Product?",
                                    "Are you sure you want to delete this product?",
                                    () {
                                  final docBooking = FirebaseFirestore.instance
                                      .collection('products')
                                      .doc("T-${widget.productName}");
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SellerHome()));
                                  docBooking.delete();
                                });
                              },
                              isRed: true)
                          : MyButton(
                              isRed: false,
                              text: widget.isSeller == true
                                  ? "Edit Product"
                                  : "Add to Cart",
                              onPressed: () {
                                widget.isSeller == true
                                    ? setState(() {
                                        isEditing = true;
                                      })
                                    : setState(() {
                                        isLoading = true;
                                      });
                              }),
                    ),
                  ],
                ),
              )),
            ),
          );
        },
      ),
    );
  }

  Future updateProduct({
    required String name,
    required String price,
    required String description,
    required String quantity,
  }) async {
    await FirebaseFirestore.instance
        .collection('products')
        .doc("T-${widget.productName}")
        .update({
      'name': name,
      'price': price,
      'description': description,
      'quantity': quantity,
    });
  }

  Stream<QuerySnapshot> get readProducts {
    return FirebaseFirestore.instance
        .collection('products')
        .where('name', isEqualTo: widget.productName)
        .snapshots();
  }
}
