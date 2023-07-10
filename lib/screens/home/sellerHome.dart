import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/order/sellerOrder.dart';
import 'package:toba/screens/products/details/productDetails.dart';
import 'package:toba/screens/profile/profile.dart';

import '../products/form/addProducts.dart';

class SellerHome extends StatefulWidget {
  const SellerHome({super.key});

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    const screens = [
      Default(),
      SellerOrders(),
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
  RegExp regExp =
      RegExp(r'(I[A-Za-z0-9]+(_[A-Za-z0-9]+|-[A-Za-z0-9]+)+)\.[A-Za-z]{3}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddProducts()));
          },
          label: const Text("Add Products"),
          icon: const Icon(Icons.add),
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
                                  price: data['price'],
                                  description: data['description'],
                                  quantity: data['quantity'],
                                  image: imageAfterRegex,
                                  isSeller: true,
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
                                      image: NetworkImage(
                                          snapshot.data!.docs[index]['imgURL']),
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
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.lightGreen,
                                                      fontSize: 18),
                                                ),
                                                // ignore: prefer_interpolation_to_compose_strings
                                                Text("RM " + data['price']),
                                                Text(data['description']),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 50,
                                            height: 200,
                                            child: Center(
                                              child: Icon(
                                                Icons.chevron_right,
                                                color: Colors.lightGreen,
                                              ),
                                            )),
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
          },
        ));
  }

  Stream<QuerySnapshot> get readProducts {
    return FirebaseFirestore.instance.collection('products').snapshots();
  }
}
