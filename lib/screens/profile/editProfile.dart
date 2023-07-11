import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../widgets/inputfield.dart';

class EditProfile extends StatefulWidget {
  final String? name;
  final String? email;
  final String? phoneNo;
  final String? address;
  final String? photo;
  const EditProfile({
    super.key,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.address,
    required this.photo,
  });

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  String img = '';
  bool isEdit = false;
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

  Future selectImage() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return;
    }
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadImage() async {
    final path = 'images/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);

    final snapshot = await uploadTask!.whenComplete(() {});
    final imageURL = await snapshot.ref.getDownloadURL();
    setState(() {
      img = imageURL;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.close)),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              uploadImage().then((value) {
                updateUser(
                  name: nameController.text.trim() != ""
                      ? nameController.text.trim()
                      : widget.name!,
                  email: emailController.text.trim() != ""
                      ? emailController.text.trim()
                      : widget.email!,
                  phoneNo: phoneController.text.trim() != ""
                      ? phoneController.text.trim()
                      : widget.phoneNo!,
                  address: addressController.text.trim() != ""
                      ? addressController.text.trim()
                      : widget.address!,
                  photo: img != "" ? img : widget.photo!,
                ).then((value) {
                  setState(() {
                    isLoading = false;
                  });
                  Navigator.of(context).pop();
                });
              });
            },
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: StreamBuilder(
        stream: getUsers,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
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
          return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator.adaptive()),
                          Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("Updating..."),
                          )
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                        },
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    selectImage();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        shape: BoxShape.rectangle,
                                        border: Border.all(
                                            color: Colors.black, width: 2)),
                                    width: 200,
                                    height: 200,
                                    child: pickedFile != null
                                        ? Stack(children: [
                                            Center(
                                              child: Container(
                                                color: Colors.blue[100],
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                      Colors.black
                                                          .withOpacity(0.5),
                                                      BlendMode.darken),
                                                  child: Image.file(
                                                    File(pickedFile!.path!),
                                                    width: double.infinity,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const Center(
                                              child: Icon(
                                                Icons.photo,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                            )
                                          ])
                                        : Stack(children: [
                                            Center(
                                              child: Container(
                                                color: Colors.blue[100],
                                                child: ColorFiltered(
                                                  colorFilter: ColorFilter.mode(
                                                      Colors.black
                                                          .withOpacity(0.5),
                                                      BlendMode.darken),
                                                  child: snapshot.data!.docs[0]
                                                              ['photo'] !=
                                                          ""
                                                      ? Image.network(
                                                          snapshot.data!.docs[0]
                                                              ['photo'],
                                                          fit: BoxFit.cover,
                                                        )
                                                      : Image.network(
                                                          "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                                                          fit: BoxFit.cover,
                                                        ),
                                                ),
                                              ),
                                            ),
                                            const Center(
                                              child: Icon(
                                                Icons.photo,
                                                color: Colors.white,
                                                size: 60,
                                              ),
                                            )
                                          ]),
                                  )),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: InputField(
                                  isPassword: false,
                                  hasInitValue: false,
                                  labelText:
                                      snapshot.data!.docs[0]['name'] != ""
                                          ? snapshot.data!.docs[0]['name']
                                          : widget.name!,
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
                                  isEnabled: false,
                                  labelText:
                                      snapshot.data!.docs[0]['email'] != ""
                                          ? snapshot.data!.docs[0]['email']
                                          : widget.email!,
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
                                  labelText:
                                      snapshot.data!.docs[0]['phoneNo'] != ""
                                          ? snapshot.data!.docs[0]['phoneNo']
                                          : widget.phoneNo!,
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
                                      hintText: snapshot.data!.docs[0]
                                                  ['address'] !=
                                              ""
                                          ? snapshot.data!.docs[0]['address']
                                          : widget.address!,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 1.0),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      prefixIcon: const Icon(Icons.house),
                                    ),
                                    controller: addressController,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ));
        },
      ),
    );
  }

  Future updateUser({
    required String name,
    required String email,
    required String phoneNo,
    required String address,
    required String photo,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email!.substring(
            0, FirebaseAuth.instance.currentUser!.email!.indexOf('@')))
        .update({
      'name': name,
      'email': email,
      'phoneNo': phoneNo,
      'address': address,
      'photo': photo,
    });
  }

  Stream<QuerySnapshot> get getUsers {
    return FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .snapshots();
  }
}
