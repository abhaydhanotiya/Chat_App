import 'package:chat/authenticate.dart';
import 'package:chat/chat_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerifyLogin extends StatefulWidget {
  const VerifyLogin({super.key});

  @override
  State<VerifyLogin> createState() => _VerifyLoginState();
}

class _VerifyLoginState extends State<VerifyLogin> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _login(BuildContext context, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      // Redirect to chat screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatList(currentUserId: userId),
        ),
      );
    } catch (e) {
      // Handle login errors
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Scaffold(
        backgroundColor: Color.fromRGBO(239, 76, 157, 1),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(237, 43, 140, 1),
                Color.fromRGBO(239, 76, 157, 1)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SignIn',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: size.height * 0.05),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      )),
                  cursorColor: Colors.black,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: size.height * 0.02),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.password,
                        color: Colors.white,
                      ),
                      hintText: 'Password',
                      hintStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(15)),
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      )),
                  cursorColor: Colors.black,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: size.height * 0.05),
                InkWell(
                  onTap: () async {
                    if (emailController.text == '' ||
                        passwordController.text == '') {
                      Fluttertoast.showToast(
                        msg: "Please Fill All Fields",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                    } else {
                      _login(
                        context,
                        emailController.text,
                        passwordController.text,
                      );
                    }
                  },
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.05),
                //don't have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthenticationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        ' Register',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
