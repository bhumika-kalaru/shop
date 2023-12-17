import 'dart:math';
import 'package:shop/Login/logIn.dart';
import 'package:shop/Login/signUp.dart';
import 'package:shop/Login/verify.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop/Screens/product_page.dart';
import '../constants.dart';
import 'package:flutter/material.dart';

import 'forgotPassword.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  // late TextEditingController emailController, password_controller;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height,
        w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Log in ",
          style:
              GoogleFonts.openSans(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: w / 10, vertical: h / 40),
            child: TextFormField(
              controller: emailController,
              decoration: InputDecoration(hintText: "Email"),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: w / 10, vertical: h / 40),
            child: TextFormField(
              // obscureText: true,
              controller: passwordController,
              decoration: InputDecoration(hintText: "Password"),
            ),
          ),
          GestureDetector(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: h / 80),
                height: h / 25,
                width: w / 4,
                child: Center(
                    child: Text(
                  "Submit",
                  style: GoogleFonts.openSans(
                      color: white, fontWeight: FontWeight.w500, fontSize: 18),
                )),
                decoration: BoxDecoration(
                    color: maincolour,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: blueShadow),
              ),
              onTap: () async {
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProductPage(
                              h: h,
                              w: w,
                            )),
                    (Route<dynamic> route) => false,
                  );
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("No user found for that email."),
                      backgroundColor: Colors.red,
                    ));
                    print('No user found for that email.');
                  } else if (e.code == 'wrong-password') {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Wrong Password"),
                      backgroundColor: Colors.red,
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("$e"),
                      backgroundColor: Colors.red,
                    ));
                  }
                }
              }
              // {
              // setState(() {
              // signIn();
              // Navigator.pushAndRemoveUntil(
              //   context,
              //   MaterialPageRoute(builder: (context) => MainScreen()),
              //   (Route<dynamic> route) => false,
              // );
              // });
              // },
              ),
          GestureDetector(
            child: RichText(
                text: TextSpan(
                    text: 'Create an account?!',
                    style:
                        GoogleFonts.openSans(color: maincolour, fontSize: 16),
                    children: [
                  TextSpan(
                    text: "signUp",
                    style: GoogleFonts.openSans(color: darkPink, fontSize: 16),
                  )
                ])),
            onTap: (() {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Verify()));
            }),
          ),
          GestureDetector(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: h / 100),
                child: Text(
                  "forgot password!",
                  style: GoogleFonts.openSans(color: darkPink, fontSize: 16),
                )),
            onTap: (() {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ForgotPassword()));
            }),
          )
        ],
      ),
    );
  }

  // Future signIn() async {
  //   try {
  //     await FirebaseAuth.instance
  //         .signInWithEmailAndPassword(
  //           email: emailController.text,
  //           password: passwordController.text,
  //         )
  //         .catchError((error) => print(error));
  //     ;
  //   } on FirebaseAuthException catch (e) {
  //     print(e);
  //   }
  // }
}
