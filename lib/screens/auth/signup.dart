import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:toba/screens/auth/landing.dart';

import '../../widgets/button.dart';
import '../../widgets/inputfield.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
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
            title: const Text("Sign Up"),
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
                                padding: EdgeInsets.all(10.0),
                                child: CircularProgressIndicator.adaptive()),
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Text("Signing up..."),
                            )
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
                              padding: const EdgeInsets.all(10.0),
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
                              padding: const EdgeInsets.all(10.0),
                              child: InputField(
                                isPassword: false,
                                hasInitValue: false,
                                labelText: "Name",
                                icondata: Icons.person,
                                controller: nameController,
                                isAuthField: false,
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: InputField(
                                isPassword: false,
                                hasInitValue: false,
                                labelText: "Phone Number",
                                icondata: Icons.phone,
                                controller: phoneController,
                                isAuthField: false,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                color: Colors.white,
                                width: 300,
                                child: TextFormField(
                                  obscureText: false,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade400,
                                          width: 1.0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    labelText: "Address",
                                    hintText: "Enter your Address",
                                    prefixIcon: const Icon(Icons.house),
                                  ),
                                  controller: addressController,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
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
                              padding: const EdgeInsets.all(10),
                              child: MyButton(
                                  isRed: false,
                                  text: "Sign Up",
                                  onPressed: () {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    signUp(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      address: addressController.text.trim(),
                                      phoneNo: phoneController.text.trim(),
                                      name: nameController.text.trim(),
                                      photo: "",
                                    );
                                  }),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text("Already Have an Account?"),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginPage()));
                                        },
                                        child: const Text("Log In"))
                                  ],
                                ))
                          ],
                        ),
                      )),
          ),
        ));
  }

  Future signUp({
    required String email,
    required String name,
    required String password,
    required String phoneNo,
    required String address,
    required String photo,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
    await FirebaseFirestore.instance
        .collection("users")
        .doc(email.substring(0, email.indexOf('@')))
        .set({
      "name": name,
      "phoneNo": phoneNo,
      "email": email,
      "address": address,
      "seller": false,
      "photo": photo,
    }).then((value) {
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const LandingPage()));
    });
  }
}
