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
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => OrderDetails(
                                    isCompleted:
                                        data["orderStatus"] == "Completed"
                                            ? true
                                            : false,
                                    isIssue: data["orderStatus"] == "Issue"
                                        ? true
                                        : false,
                                    isSeller: true,
                                    orderID: data["orderID"],
                                  )));
                        },
                        child: Card(
                          child: ListTile(
                            leading: data["orderStatus"] == "Making Order"
                                ? const Icon(Icons.soup_kitchen,
                                    color: Colors.blue)
                                : data["orderStatus"] == "Delivering"
                                    ? const Icon(Icons.delivery_dining,
                                        color: Colors.orange)
                                    : data['orderStatus'] == "Issue"
                                        ? const Icon(Icons.warning_amber,
                                            color: Colors.red)
                                        : const Icon(Icons.done,
                                            color: Colors.green),
                            title: Text(data["name"] + " x" + data["quantity"]),
                            subtitle: Text(data["orderID"]),
                            trailing: Text(
                              data["orderStatus"] == "Making Order"
                                  ? "To Fulfill"
                                  : data["orderStatus"] == "Delivering"
                                      ? "On the way"
                                      : data["orderStatus"] == "Issue"
                                          ? "Issue"
                                          : "Completed",
                              style: TextStyle(
                                color: data["orderStatus"] == "Making Order"
                                    ? Colors.blue
                                    : data["orderStatus"] == "Delivering"
                                        ? Colors.orange
                                        : data["orderStatus"] == "Issue"
                                            ? Colors.red
                                            : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ));
  }

  Stream<QuerySnapshot> get getOrders {
    return FirebaseFirestore.instance.collection("orders").snapshots();
  }
}
