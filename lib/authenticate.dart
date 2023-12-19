import 'package:chat/verify.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'chat_list.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _createAccount(
      BuildContext context, String name, String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user details in Firestore
      String userId = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'userId': userId,
        'userName': name,
        'email': email,
      });

      // Redirect to chat screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatList(currentUserId: userId),
        ),
      );
    } catch (e) {
      // Handle account creation errors
      print(e.toString());
    }
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
      backgroundColor: Color.fromRGBO(239, 76, 157, 1),
      body: Container(
        width: size.width,
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
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'SignUp',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: size.height * 0.05),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.white),
                  hintText: 'Name',
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    borderSide: BorderSide(
                      color: Colors.white,
                    ),
                  ),
                ),
                cursorColor: Colors.black,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: size.height * 0.02),
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: size.height * 0.05),
              InkWell(
                onTap: () {
                  // Call create account function
                  _createAccount(
                    context,
                    nameController.text,
                    emailController.text,
                    passwordController.text,
                  );
                },
                child: InkWell(
                  onTap: () async {
                    if (nameController.text == '' ||
                        emailController.text == '' ||
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
                      // Call create account function
                      _createAccount(
                        context,
                        nameController.text,
                        emailController.text,
                        passwordController.text,
                      );
                    }
                  },
                  child: Container(
                      width: 150,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Center(
                            child: Text('Sign Up',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ))),
                      ),
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(25)))),
                ),
              ),
              SizedBox(height: size.height * 0.05),
              //already have an account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.white),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VerifyLogin(),
                        ),
                      );
                    },
                    child: const Text(
                      " Sign In",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
