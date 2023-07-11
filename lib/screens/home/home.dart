import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/order/orders.dart';

import '../products/cart/cart.dart';
import '../products/details/productDetails.dart';
import '../profile/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  @override
  Widget build(BuildContext context) {
    const screens = [
      Default(),
      Orders(),
      ProfilePage(),
    ];
    return Scaffold(
        bottomNavigationBar: NavigationBarTheme(
          data: const NavigationBarThemeData(
            backgroundColor: Colors.white,
            indicatorColor: Colors.lightGreen,
          ),
          child: NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            height: 60,
            selectedIndex: index,
            onDestinationSelected: (index) {
              setState(() {
                this.index = index;
              });
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: "Home"),
              NavigationDestination(icon: Icon(Icons.receipt), label: "Orders"),
              NavigationDestination(icon: Icon(Icons.person), label: "Profile")
            ],
          ),
        ),
        body: screens[index]);
  }
}

class Default extends StatefulWidget {
  const Default({super.key});

  @override
  State<Default> createState() => _DefaultState();
}

class _DefaultState extends State<Default> {
  final cartref = FirebaseFirestore.instance
      .collection('cart')
      .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
      .snapshots();
  int cartItemQuantity = 0;
  @override
  void initState() {
    super.initState();
    cartref.listen((event) {
      setState(() {
        cartItemQuantity = event.docs.length;
      });
    });
  }

  final RegExp regExp =
      RegExp(r'(I[A-Za-z0-9]+(_[A-Za-z0-9]+|-[A-Za-z0-9]+)+)\.[A-Za-z]{3}');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          cartItemQuantity != 0
              ? Badge.count(
                  largeSize: 20,
                  alignment: Alignment.topLeft,
                  count: cartItemQuantity,
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const Cart()));
                      },
                      icon: const Icon(Icons.shopping_cart)))
              : IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const Cart()));
                  },
                  icon: const Icon(Icons.shopping_cart))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: readProducts,
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

            return SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: SingleChildScrollView(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final imageAfterRegex = regExp
                        .stringMatch(snapshot.data!.docs[index]['imgURL']);

                    final data = snapshot.data!.docs[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProductDetails(
                                  productName: data['name'],
                                  price: double.parse(data['price'])
                                      .toStringAsFixed(2),
                                  description: data['description'],
                                  quantity: data['quantity'],
                                  image: imageAfterRegex,
                                  isSeller: false,
                                )));
                      },
                      child: Padding(
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
                                      image: int.parse(snapshot.data!
                                                  .docs[index]['quantity']) <=
                                              0
                                          ? const NetworkImage(
                                              "https://www.seekpng.com/png/small/118-1182523_out-of-stock-png.png")
                                          : NetworkImage(snapshot
                                              .data!.docs[index]['imgURL']),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 180,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['name'],
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: int.parse(snapshot
                                                                          .data!
                                                                          .docs[
                                                                      index][
                                                                  'quantity']) <=
                                                              0
                                                          ? Colors.grey
                                                          : Colors.lightGreen,
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  // ignore: prefer_interpolation_to_compose_strings
                                                  "RM " +
                                                      double.parse(
                                                              data['price'])
                                                          .toStringAsFixed(2),
                                                  style: TextStyle(
                                                    color: int.parse(snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                ['quantity']) <=
                                                            0
                                                        ? Colors.grey
                                                        : Colors.black,
                                                  ),
                                                ),
                                                Text(
                                                  data['description'],
                                                  style: TextStyle(
                                                    color: int.parse(snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                ['quantity']) <=
                                                            0
                                                        ? Colors.grey
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Center(
                                          child: Icon(
                                            Icons.chevron_right,
                                            color: int.parse(snapshot
                                                            .data!.docs[index]
                                                        ['quantity']) <=
                                                    0
                                                ? Colors.grey
                                                : Colors.lightGreen,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
    );
  }

  Stream<QuerySnapshot> get readProducts {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }
}
