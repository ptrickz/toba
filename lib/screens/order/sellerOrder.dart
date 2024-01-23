import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'orderDetails.dart';

class SellerOrders extends StatefulWidget {
  const SellerOrders({super.key});

  @override
  State<SellerOrders> createState() => _SellerOrdersState();
}

class _SellerOrdersState extends State<SellerOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Orders"),
          centerTitle: true,
          automaticallyImplyLeading: false,
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
            return Column(children: [
              Expanded(
                  child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => OrderDetails(
                                      isCompleted: snapshot.data!.docs[index]
                                                  ["orderStatus"] ==
                                              "Completed"
                                          ? true
                                          : false,
                                      isIssue: snapshot.data!.docs[index]
                                                  ["orderStatus"] ==
                                              "Issue"
                                          ? true
                                          : false,
                                      isSeller: true,
                                      orderID: snapshot.data!.docs[index]
                                          ["orderID"],
                                    )));
                          },
                          child: Card(
                            child: ListTile(
                              leading: snapshot.data!.docs[index]
                                          ["orderStatus"] ==
                                      "Making Order"
                                  ? const Icon(Icons.soup_kitchen,
                                      color: Colors.blue)
                                  : snapshot.data!.docs[index]["orderStatus"] ==
                                          "Delivering"
                                      ? const Icon(Icons.delivery_dining,
                                          color: Colors.orange)
                                      : snapshot.data!.docs[index]
                                                  ['orderStatus'] ==
                                              "Issue"
                                          ? const Icon(Icons.warning_amber,
                                              color: Colors.red)
                                          : const Icon(Icons.done,
                                              color: Colors.green),
                              title: Text(snapshot.data!.docs[index]["name"] +
                                  " x" +
                                  snapshot.data!.docs[index]["quantity"]),
                              subtitle:
                                  Text(snapshot.data!.docs[index]["orderID"]),
                              trailing: Text(
                                snapshot.data!.docs[index]["orderStatus"] ==
                                        "Making Order"
                                    ? "To Fulfill"
                                    : snapshot.data!.docs[index]
                                                ["orderStatus"] ==
                                            "Delivering"
                                        ? "On the way"
                                        : snapshot.data!.docs[index]
                                                    ["orderStatus"] ==
                                                "Issue"
                                            ? "Issue"
                                            : "Completed",
                                style: TextStyle(
                                  color: snapshot.data!.docs[index]
                                              ["orderStatus"] ==
                                          "Making Order"
                                      ? Colors.blue
                                      : snapshot.data!.docs[index]
                                                  ["orderStatus"] ==
                                              "Delivering"
                                          ? Colors.orange
                                          : snapshot.data!.docs[index]
                                                      ["orderStatus"] ==
                                                  "Issue"
                                              ? Colors.red
                                              : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ))))
            ]);
          },
        ));
  }

  Stream<QuerySnapshot> get getOrders {
    return FirebaseFirestore.instance
        .collection("orders")
        .orderBy('orderStatus', descending: true)
        .orderBy(
          'orderDate',
          descending: true,
        )
        .snapshots();
  }
}
