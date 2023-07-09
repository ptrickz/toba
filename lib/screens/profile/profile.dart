import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/button.dart';
import '../auth/landing.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
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
                                    builder: (context) =>
                                        const LandingPage())));
                      }))
            ],
          ),
        ));
  }
}
