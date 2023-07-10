import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  const Cart({super.key});

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cart"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("User Cart"),
      ),
    );
  }

  Stream<QuerySnapshot> get readCart {
    return FirebaseFirestore.instance.collection('cart').snapshots();
  }
}
