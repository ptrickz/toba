import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/home/home.dart';
import 'package:toba/screens/home/sellerHome.dart';

import '../../../widgets/button.dart';
import '../../../widgets/inputfield.dart';

class ProductDetails extends StatefulWidget {
  final String? productName;
  final String? price;
  final String? description;
  final String? quantity;
  final String? image;
  final bool? isSeller;
  const ProductDetails({
    super.key,
    this.productName,
    this.isSeller,
    this.price,
    this.description,
    this.quantity,
    this.image,
  });

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController addController = TextEditingController();
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

  addItemBox(String title, String message, VoidCallback onPressed) async {
    return showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(message),
                    InputField(
                        isAuthField: false,
                        keyboardType: TextInputType.number,
                        labelText: "Quantity",
                        icondata: Icons.numbers,
                        controller: addController,
                        hasInitValue: false,
                        isPassword: false),
                  ],
                ),
              ),
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
                      name: nameController.text.trim() != ""
                          ? nameController.text.trim()
                          : widget.productName!,
                      price: priceController.text.trim() != ""
                          ? priceController.text.trim()
                          : widget.price!,
                      description: descriptionController.text.trim() != ""
                          ? descriptionController.text.trim()
                          : widget.description!,
                      quantity: quantityController.text.trim() != ""
                          ? quantityController.text.trim()
                          : widget.quantity!,
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
                    GestureDetector(
                      onTap: () {
                        final imageProvider =
                            Image.network(snapshot.data!.docs[0]['imgURL'])
                                .image;
                        showImageViewer(context, imageProvider,
                            onViewerDismissed: () {});
                      },
                      child: Container(
                        decoration:
                            BoxDecoration(color: Colors.grey[100], boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ]),
                        width: 340,
                        height: 250,
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
                                  final imageRef = FirebaseStorage.instance
                                      .ref("images/${widget.image}");
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SellerHome()));
                                  docBooking.delete();
                                  imageRef.delete();
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
                                addItemBox("Add to Cart?",
                                    "Insert Number of Items to add to cart.",
                                    () {
                                  createCartItems(
                                          name: widget.productName!,
                                          price: widget.price!,
                                          quantity: addController.text.trim(),
                                          image: snapshot.data!.docs[0]
                                              ['imgURL'],
                                          date: DateTime.now())
                                      .then((value) {
                                    try {
                                      reduceQuantity();
                                    } catch (e) {
                                      if (kDebugMode) {
                                        print(e);
                                      }
                                    }
                                  }).then((value) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                widget.isSeller == true
                                                    ? const SellerHome()
                                                    : const HomePage()));
                                  });
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

  Future reduceQuantity() async {
    final int quantity = int.parse(widget.quantity!);
    final int cartQuantity = int.parse(addController.text.trim());
    await FirebaseFirestore.instance
        .collection('products')
        .doc("T-${widget.productName}")
        .update({
      'quantity': (quantity - cartQuantity).toString() == "0"
          ? "Out of Stock"
          : (quantity - cartQuantity).toString(),
    });
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

Future createCartItems({
  required String name,
  required String price,
  required String quantity,
  required String image,
  required DateTime date,
}) async {
  String time = DateTime.now()
      .toString()
      .substring(10, 19)
      .replaceAll(" ", "")
      .replaceAll(":", "");
  String dateF = DateTime.now().toString().substring(0, 10);
  //refer doc
  final docCart =
      FirebaseFirestore.instance.collection("cart").doc("C-$name-$time-$dateF");
  final cart = CartItem(
    name: name,
    price: price,
    quantity: quantity,
    image: image,
    date: date,
  );
  final json = cart.toJson();
  try {
    await docCart.set(json);
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
}

class CartItem {
  final String name;
  final String price;
  final String quantity;
  final String image;
  final DateTime date;

  CartItem({
    required this.name,
    required this.price,
    required this.quantity,
    required this.image,
    required this.date,
  });
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      name: json["name"],
      price: json["price"],
      quantity: json["quantity"],
      image: json["image"],
      date: json["date"],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "price": price,
      "quantity": quantity,
      "image": image,
      "date": date,
    };
  }
}
