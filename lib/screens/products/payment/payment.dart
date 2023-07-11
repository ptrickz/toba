import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/home/home.dart';

import '../../../widgets/button.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

enum PaymentMethod { online, cash, card }

class _PaymentPageState extends State<PaymentPage> {
  alertBox(String title, String message, VoidCallback onPressed) async {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(onPressed: onPressed, child: const Text("Ok"))
              ],
            ));
  }

  PaymentMethod? _paymentMethod = PaymentMethod.cash;
  @override
  Widget build(BuildContext context) {
    String dateF = DateTime.now().toString().substring(0, 10);
    String time = DateTime.now()
        .toString()
        .substring(10, 19)
        .replaceAll(" ", "")
        .replaceAll(":", "");
    String emailFormatted = FirebaseAuth.instance.currentUser!.email!
        .toLowerCase()
        .replaceAll("@gmail.com", "")
        .replaceAll("@yahoo.com", "")
        .toUpperCase();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Payment"),
      ),
      body: StreamBuilder(
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
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final data = snapshot.data!.docs[index];
                      return ListTile(
                        leading: Image.network(
                          data['image'],
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                        title: Text(data['name']),
                        subtitle: Text(
                            "RM ${double.parse(data['price']).toStringAsFixed(2)}"),
                        trailing: Text("x${data['quantity']}"),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("RM $subTotal",
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                const Divider(
                  thickness: 2,
                ),
                const Text("Payment Method",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Column(
                  children: [
                    RadioListTile<PaymentMethod>(
                      title: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Cash on Delivery'),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.money),
                        ],
                      ),
                      value: PaymentMethod.cash,
                      groupValue: _paymentMethod,
                      onChanged: (PaymentMethod? value) {
                        setState(() {
                          _paymentMethod = value;
                        });
                      },
                    ),
                    RadioListTile<PaymentMethod>(
                      title: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Credit/Debit Card'),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.credit_card),
                        ],
                      ),
                      value: PaymentMethod.card,
                      groupValue: _paymentMethod,
                      onChanged: (PaymentMethod? value) {
                        setState(() {
                          _paymentMethod = value;
                        });
                      },
                    ),
                    RadioListTile<PaymentMethod>(
                      title: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Online Banking'),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(Icons.currency_exchange),
                        ],
                      ),
                      value: PaymentMethod.online,
                      groupValue: _paymentMethod,
                      onChanged: (PaymentMethod? value) {
                        setState(() {
                          _paymentMethod = value;
                        });
                      },
                    ),
                  ],
                ),
                const Divider(
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyButton(
                    text: "Pay",
                    onPressed: () {
                      final data = snapshot.data!.docs[0];
                      getUserData().then((value) {
                        createOrder(
                          name: data['name'],
                          email: value['email'],
                          image: data['image'],
                          address: value['address'],
                          phone: value['phoneNo'],
                          quantity: data['quantity'],
                          paymentMethod: describeEnum(_paymentMethod!),
                          total: subTotal,
                          orderStatus: "Making Order",
                          orderDate: dateF,
                          orderTime: time,
                          orderID: emailFormatted + dateF + time,
                        );
                      }).then((value) {
                        FirebaseFirestore.instance
                            .collection('cart')
                            .where('email',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser!.email!)
                            .get()
                            .then((value) {
                          for (var i = 0; i < value.docs.length; i++) {
                            value.docs[i].reference.delete();
                          }
                        });
                      });
                      alertBox("Success", "Order Has been Placed!", () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const HomePage()));
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
    );
  }

  Future getUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email!.substring(
            0, FirebaseAuth.instance.currentUser!.email!.indexOf('@')))
        .get();
    return userData;
  }

  Stream<QuerySnapshot> get readCart {
    return FirebaseFirestore.instance
        .collection('cart')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email!)
        .snapshots();
  }

  Future createOrder({
    required String name,
    required String email,
    required String image,
    required String address,
    required String phone,
    required String quantity,
    required String paymentMethod,
    required String total,
    required String orderStatus,
    required String orderDate,
    required String orderTime,
    required String orderID,
  }) async {
    //refer doc
    final doc = FirebaseFirestore.instance.collection('orders').doc(orderID);
    final order = Order(
      name: name,
      email: email,
      image: image,
      address: address,
      phone: phone,
      quantity: quantity,
      paymentMethod: paymentMethod,
      total: total,
      orderStatus: orderStatus,
      orderDate: orderDate,
      orderTime: orderTime,
      orderID: orderID,
    );
    final data = order.toJson();
    try {
      await doc.set(data);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

class Order {
  final String name;
  final String email;
  final String image;
  final String address;
  final String phone;
  final String quantity;
  final String paymentMethod;
  final String total;
  final String orderStatus;
  final String orderDate;
  final String orderTime;
  final String orderID;

  Order({
    required this.name,
    required this.email,
    required this.image,
    required this.address,
    required this.phone,
    required this.quantity,
    required this.paymentMethod,
    required this.total,
    required this.orderStatus,
    required this.orderDate,
    required this.orderTime,
    required this.orderID,
  });
  factory Order.fromJson(Map<String, dynamic> data) {
    return Order(
      name: data['name'],
      email: data['email'],
      image: data['image'],
      address: data['address'],
      phone: data['phone'],
      quantity: data['quantity'],
      paymentMethod: data['paymentMethod'],
      total: data['total'],
      orderStatus: data['orderStatus'],
      orderDate: data['orderDate'],
      orderTime: data['orderTime'],
      orderID: data['orderID'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'image': image,
      'address': address,
      'phone': phone,
      'quantity': quantity,
      'paymentMethod': paymentMethod,
      'total': total,
      'orderStatus': orderStatus,
      'orderDate': orderDate,
      'orderTime': orderTime,
      'orderID': orderID,
    };
  }
}
