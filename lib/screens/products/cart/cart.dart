import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toba/widgets/button.dart';

import '../payment/payment.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  alertBox(String title, String message, VoidCallback onPressed) async {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: onPressed,
                    child: const Text("Proceed to Payment"))
              ],
            ));
  }

  deleteAlertBox(String title, String message, VoidCallback onPressed) async {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(onPressed: onPressed, child: const Text("Confirm"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Cart"),
          centerTitle: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: readCart,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final data = snapshot.data!.docs[index];

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: 150,
                            child: Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      height: 150,
                                      child: FadeInImage(
                                        placeholder: const AssetImage(
                                            "assets/loading.gif"),
                                        image: NetworkImage(snapshot
                                            .data!.docs[index]['image']),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['name'],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.lightGreen,
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  data['quantity'] + " unit",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                      fontSize: 16),
                                                ),
                                                // ignore: prefer_interpolation_to_compose_strings
                                                Text("Total: RM " +
                                                    (double.parse(
                                                                data['price']) *
                                                            int.parse(data[
                                                                'quantity']))
                                                        .toStringAsFixed(2)),
                                              ],
                                            ),
                                          ),
                                          Center(
                                            child: IconButton(
                                              onPressed: () {
                                                deleteAlertBox("Delete?",
                                                    "Are you sure you want to delete this item?",
                                                    () {
                                                  updateProductQuantity(
                                                      name: data['name'],
                                                      cqty: data['quantity']);
                                                  deleteCartItem(id: data.id);
                                                  Navigator.pop(context);
                                                });
                                              },
                                              icon: const Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                  StreamBuilder(
                    stream: readCart,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                      final totalPrice = snapshot.data!.docs.fold(
                          0,
                          (previousValue, element) =>
                              previousValue +
                              (double.parse(element['price']) *
                                  int.parse(element['quantity'])));
                      final subTotal = totalPrice.toStringAsFixed(2);
                      return SizedBox(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Total:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  Text("RM $subTotal",
                                      style: const TextStyle(fontSize: 18)),
                                ],
                              ),
                            ),
                            const Divider(
                              thickness: 2,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: MyButton(
                                text: "Checkout",
                                onPressed: () {
                                  alertBox("Checkout?",
                                      "Are you sure you want to checkout? \nTotal Payment: $subTotal",
                                      () {
                                    Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const PaymentPage()));
                                  });
                                },
                                isRed: false,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ));
  }

  Future deleteCartItem({
    required String id,
  }) async {
    await FirebaseFirestore.instance.collection('cart').doc(id).delete();
  }

  Future updateProductQuantity({
    required String name,
    required String cqty,
  }) async {
    final qty = (await FirebaseFirestore.instance
            .collection('products')
            .doc("T-$name")
            .get())
        .data()!['quantity'];
    await FirebaseFirestore.instance
        .collection('products')
        .doc("T-$name")
        .update({'quantity': (int.parse(qty) + int.parse(cqty)).toString()});
  }

  Stream<QuerySnapshot> get readCart {
    return FirebaseFirestore.instance
        .collection('cart')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .snapshots();
  }
}
