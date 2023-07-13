import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../widgets/button.dart';

class DeleteConfirmationPage extends StatefulWidget {
  final String? productName;
  const DeleteConfirmationPage({super.key, required this.productName});

  @override
  State<DeleteConfirmationPage> createState() => _DeleteConfirmationPageState();
}

class _DeleteConfirmationPageState extends State<DeleteConfirmationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Confirmation'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text("Delete Item: ${widget.productName}?"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MyButton(
              text: "Delete",
              onPressed: () {
                deleteProduct();
                Navigator.of(context).pop();
              },
              isRed: true,
            ),
          ),
        ],
      ),
    );
  }

  Future deleteProduct() async {
    //refer doc
    final docRef = FirebaseFirestore.instance
        .collection('products')
        .doc("T-${widget.productName}");
    await docRef.delete();
  }
}
