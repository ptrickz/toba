import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/auth/signup.dart';
import 'package:toba/screens/home/home.dart';

import '../../widgets/button.dart';
import 'login.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(28.0),
                          child: CircularProgressIndicator.adaptive(),
                        ),
                        Padding(
                          padding: EdgeInsets.all(18.0),
                          child: Text("Loading..."),
                        )
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return const Scaffold(
                    body: Center(
                  child: Text("Something went wrong"),
                ));
              } else {
                if (snapshot.hasData) {
                  return const HomePage();
                } else {
                  return Scaffold(
                      body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(55, 20, 55, 20),
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border(
                                top:
                                    BorderSide(width: 1.0, color: Colors.black),
                                left:
                                    BorderSide(width: 1.0, color: Colors.black),
                                right:
                                    BorderSide(width: 1.0, color: Colors.black),
                                bottom:
                                    BorderSide(width: 1.0, color: Colors.black),
                              ),
                              image: DecorationImage(
                                image: AssetImage("assets/logo.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                            width: 100,
                            height: 100,
                          ),
                        ),
                        MyButton(
                            isRed: false,
                            text: "Login",
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                            }),
                        MyButton(
                            isRed: false,
                            text: "Sign Up",
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const SignUp()));
                            }),
                      ],
                    ),
                  ));
                }
              }
            }));
  }
}
