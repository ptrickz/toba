import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/button.dart';
import '../auth/landing.dart';

class SellerHome extends StatefulWidget {
  const SellerHome({super.key});

  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Seller : ${FirebaseAuth.instance.currentUser!.email!}"),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyButton(
                  isRed: false,
                  text: "Logout",
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut().then((value) =>
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LandingPage())));
                  }))
        ],
      ),
    ));
  }
}
