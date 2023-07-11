import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'orderDetails.dart';

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text("Orders"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getOrders,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong"),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No orders yet"),
            );
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => OrderDetails(
                            isCompleted: data["orderStatus"] == "Completed"
                                ? true
                                : false,
                            isIssue:
                                data["orderStatus"] == "Issue" ? true : false,
                            isSeller: false,
                            orderID: data["orderID"],
                          )));
                },
                child: Card(
                  child: ListTile(
                    title: Text(data["name"] + " x" + data["quantity"]),
                    subtitle: Text(data["orderID"]),
                    trailing: Text(data["orderStatus"]),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> get getOrders {
    return FirebaseFirestore.instance
        .collection("orders")
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .snapshots();
  }
}
