import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/auth/landing.dart';
import 'package:toba/widgets/button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(FirebaseAuth.instance.currentUser!.email!),
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
