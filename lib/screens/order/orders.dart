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
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OrderDetails(
                              isCompleted: snapshot.data!.docs[index]
                                          ['orderStatus'] ==
                                      "Completed"
                                  ? true
                                  : false,
                              isIssue: snapshot.data!.docs[index]
                                          ["orderStatus"] ==
                                      "Issue"
                                  ? true
                                  : false,
                              isSeller: false,
                              orderID: snapshot.data!.docs[index]["orderID"],
                            )));
                  },
                  child: Card(
                      child: ListTile(
                    title: Text(snapshot.data!.docs[index]["name"] +
                        " x" +
                        snapshot.data!.docs[index]["quantity"]),
                    subtitle: Text(snapshot.data!.docs[index]["orderID"]),
                    trailing: Text(snapshot.data!.docs[index]["orderStatus"]),
                  ))));
        },
      ),
    );
  }

  Stream<QuerySnapshot> get getOrders {
    return FirebaseFirestore.instance
        .collection("orders")
        .orderBy('orderStatus', descending: true)
        .orderBy(
          'orderDate',
          descending: true,
        )
        .where("email", isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .snapshots();
  }
}
