import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/order/orders.dart';

class OrderDetails extends StatefulWidget {
  final String orderID;
  final bool isSeller;
  bool isIssue;
  final bool isCompleted;
  OrderDetails({
    super.key,
    required this.orderID,
    required this.isSeller,
    required this.isCompleted,
    required this.isIssue,
  });

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  alertBox(String title, String message, VoidCallback onPressed) async {
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

  issueAlert(String title, String message, VoidCallback onPressed) async {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")),
                TextButton(onPressed: onPressed, child: const Text("Report"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Order Details"),
          centerTitle: true,
          actions: [
            widget.isSeller
                ? Container()
                : widget.isCompleted
                    ? Container()
                    : widget.isIssue
                        ? IconButton(
                            onPressed: () {
                              alertBox("Call Us", "012 345 6789", () {
                                Navigator.of(context).pop();
                              });
                            },
                            icon: const Icon(
                              Icons.phone,
                              color: Colors.green,
                            ))
                        : IconButton(
                            onPressed: () {
                              issueAlert("Report an Issue",
                                  "Is there an issue?.\nCall us for help at 012 345 6789.\nBy clicking 'Report', the order will be suspended untill issue is resolved.",
                                  () {
                                FirebaseFirestore.instance
                                    .collection("orders")
                                    .doc(widget.orderID)
                                    .update({
                                  "orderStatus": "Issue",
                                });
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) => const Orders()));
                              });
                            },
                            icon: const Icon(Icons.report, color: Colors.red),
                          ),
          ],
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
                child: Text("Order not found"),
              );
            }
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.isIssue
                                ? const SizedBox.shrink()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: const Icon(
                                            Icons.soup_kitchen_outlined,
                                            size: 30,
                                            color: Colors.white,
                                          )),
                                      SizedBox(
                                        width: 50,
                                        child: Divider(
                                          thickness: 4,
                                          color: snapshot.data!.docs[0]
                                                      ['orderStatus'] ==
                                                  "Making Order"
                                              ? Colors.grey
                                              : Colors.green,
                                        ),
                                      ),
                                      Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: snapshot.data!.docs[0]
                                                        ['orderStatus'] ==
                                                    "Delivering"
                                                ? Colors.green
                                                : snapshot.data!.docs[0]
                                                            ['orderStatus'] ==
                                                        "Completed"
                                                    ? Colors.green
                                                    : Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: const Icon(
                                            Icons.delivery_dining,
                                            size: 30,
                                            color: Colors.white,
                                          )),
                                      SizedBox(
                                        width: 50,
                                        child: Divider(
                                          thickness: 4,
                                          color: snapshot.data!.docs[0]
                                                      ['orderStatus'] ==
                                                  "Completed"
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                      Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: snapshot.data!.docs[0]
                                                        ['orderStatus'] ==
                                                    "Completed"
                                                ? Colors.green
                                                : Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle_outline,
                                            size: 30,
                                            color: Colors.white,
                                          )),
                                    ],
                                  ),
                            const SizedBox(
                              height: 10,
                            ),
                            snapshot.data!.docs[0]['orderStatus'] ==
                                    "Delivering"
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "${snapshot.data!.docs[0]['orderStatus']} to:",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        snapshot.data!.docs[0]['address'],
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  )
                                : Text(
                                    snapshot.data!.docs[0]['orderStatus'],
                                    style: widget.isIssue
                                        ? const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Colors.red)
                                        : const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                  ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: GestureDetector(
                          onTap: () {
                            final imageProvider =
                                Image.network(snapshot.data!.docs[0]['image'])
                                    .image;
                            showImageViewer(context, imageProvider,
                                onViewerDismissed: () {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[100],
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 3), // changes position of shadow
                                  ),
                                ]),
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                            child: SizedBox(
                              width: 120,
                              height: 150,
                              child: FadeInImage(
                                placeholder:
                                    const AssetImage("assets/loading.gif"),
                                image: NetworkImage(
                                    snapshot.data!.docs[0]['image']),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Order ID: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              snapshot.data!.docs[0]['orderID'],
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Product Name: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              snapshot.data!.docs[0]['name'],
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Date: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              snapshot.data!.docs[0]['orderDate'],
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Quantity: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              snapshot.data!.docs[0]['quantity'],
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "RM  ${snapshot.data!.docs[0]['total']}",
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Payment: ",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              snapshot.data!.docs[0]['paymentMethod'] ==
                                      "online"
                                  ? "Online Banking"
                                  : snapshot.data!.docs[0]['paymentMethod'] ==
                                          "cash"
                                      ? "Cash on Delivery"
                                      : "Credit/Debit Card",
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: snapshot.data!.docs[0]['orderStatus'] ==
                                "Completed"
                            ? const Text("Order Completed")
                            : widget.isSeller
                                ? widget.isIssue
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            alertBox("Issue Resolved?",
                                                "Make sure that issue is resolved. Click 'Ok' to change order to Delivering.",
                                                () {
                                              FirebaseFirestore.instance
                                                  .collection("orders")
                                                  .doc(
                                                      snapshot.data!.docs[0].id)
                                                  .update({
                                                "orderStatus": "Delivering",
                                              });
                                              setState(() {
                                                widget.isIssue = false;
                                              });
                                              Navigator.of(context).pop();
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              fixedSize: const Size(250, 50)),
                                          child: const Text(
                                            "Issue Fixed",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          onPressed: snapshot.data!.docs[0]
                                                      ['orderStatus'] ==
                                                  "Making Order"
                                              ? () {
                                                  alertBox("Deliver?",
                                                      "Make sure that order is ready to deliver.",
                                                      () {
                                                    FirebaseFirestore.instance
                                                        .collection("orders")
                                                        .doc(snapshot
                                                            .data!.docs[0].id)
                                                        .update({
                                                      "orderStatus":
                                                          "Delivering",
                                                    });
                                                    Navigator.of(context).pop();
                                                  });
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: snapshot
                                                              .data!.docs[0]
                                                          ['orderStatus'] ==
                                                      "Making Order"
                                                  ? Colors.green
                                                  : snapshot.data!.docs[0]
                                                              ['orderStatus'] ==
                                                          "Issue"
                                                      ? Colors.green
                                                      : Colors.grey,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              fixedSize: const Size(250, 50)),
                                          child: Text(
                                            snapshot.data!.docs[0]
                                                        ['orderStatus'] ==
                                                    "Making Order"
                                                ? "Deliver"
                                                : snapshot.data!.docs[0]
                                                            ['orderStatus'] ==
                                                        "Issue"
                                                    ? "Pending"
                                                    : "Delivering",
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      )
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: snapshot.data!.docs[0]
                                                  ['orderStatus'] ==
                                              "Delivering"
                                          ? () {
                                              alertBox("Confirm?",
                                                  "Make sure that order is received.",
                                                  () {
                                                FirebaseFirestore.instance
                                                    .collection("orders")
                                                    .doc(snapshot
                                                        .data!.docs[0].id)
                                                    .update({
                                                  "orderStatus": "Completed",
                                                });
                                                Navigator.of(context).pop();
                                              });
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: snapshot.data!
                                                      .docs[0]['orderStatus'] ==
                                                  "Delivering"
                                              ? Colors.green
                                              : Colors.grey,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          fixedSize: const Size(250, 50)),
                                      child: Text(
                                        snapshot.data!.docs[0]['orderStatus'] ==
                                                "Issue"
                                            ? "Pending"
                                            : "Order Received",
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ));
  }

  Stream<QuerySnapshot> get getOrders {
    return FirebaseFirestore.instance
        .collection("orders")
        .where("orderID", isEqualTo: widget.orderID)
        .snapshots();
  }
}
