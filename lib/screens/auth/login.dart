import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/auth/signup.dart';
import 'package:toba/screens/home/home.dart';
import 'package:toba/screens/home/sellerHome.dart';

import '../../widgets/button.dart';
import '../../widgets/inputfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  alertBox(String title, String message) async {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("OK"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Login"),
            centerTitle: true,
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Center(
                child: isLoading
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(55, 20, 55, 20),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border(
                                    top: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    left: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    right: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    bottom: BorderSide(
                                        width: 1.0, color: Colors.black),
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
                            const Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator.adaptive()),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(55, 20, 55, 20),
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border(
                                    top: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    left: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    right: BorderSide(
                                        width: 1.0, color: Colors.black),
                                    bottom: BorderSide(
                                        width: 1.0, color: Colors.black),
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
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: InputField(
                                isPassword: false,
                                hasInitValue: false,
                                labelText: "Email",
                                icondata: Icons.email,
                                controller: emailController,
                                isAuthField: false,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: InputField(
                                isPassword: true,
                                hasInitValue: false,
                                labelText: "Password",
                                icondata: Icons.lock,
                                controller: passwordController,
                                isAuthField: false,
                                keyboardType: TextInputType.visiblePassword,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: MyButton(
                                isRed: false,
                                text: "Login",
                                onPressed: signIn,
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Don't Have an Account?"),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignUp()));
                                        },
                                        child: const Text("Sign Up"))
                                  ],
                                ))
                          ],
                        ),
                      )),
          ),
        ));
  }

  Future signIn() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
        ),
      );
    } else {
      setState(() {
        isLoading = true;
      });
      try {
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim())
            .then((value) {
          setState(() {
            isLoading = false;
          });
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage()));
        });
        // await FirebaseFirestore.instance
        //     .collection('users')
        //     .doc(matricController.text.trim())
        //     .get()
        //     .then((doc) {
        //   if (doc.exists) {
        //     FirebaseAuth.instance
        //         .signInWithEmailAndPassword(
        //             email: doc['email'], password: passwordController.text)
        //         .then((value) {
        //       setState(() {
        //         isLoading = false;
        //       });
        //       doc['staff'] == true
        //           ? Navigator.pushReplacement(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => const SellerHome()))
        //           : Navigator.pushReplacement(
        //               context,
        //               MaterialPageRoute(
        //                   builder: (context) => const HomePage()));
        //     }).catchError((e) {
        //       setState(() {
        //         isLoading = false;
        //       });
        //       alertBox("Wrong Credentials!",
        //           "Wrong password or matric no, try again");
        //     });
        //   } else if (!doc.exists) {
        //     setState(() {
        //       isLoading = false;
        //     });
        //     alertBox("No such user!", "Please sign up first");
        //   } else {
        //     setState(() {
        //       isLoading = false;
        //     });
        //     alertBox("Connection Error!", "Please try again later");
        //   }
        // });
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}
