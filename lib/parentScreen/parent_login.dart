import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindercare/caregiverScreen/caregiver_login.dart';
import 'package:kindercare/parentScreen/parent_homepage.dart';
import 'package:kindercare/request_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../caregiverScreen/forgot_password.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class ParentLogin extends StatefulWidget {
  const ParentLogin({Key? key}) : super(key: key);

  @override
  State<ParentLogin> createState() => _ParentLoginState();
}

class _ParentLoginState extends State<ParentLogin> {
  var parentEmailEditingController = TextEditingController();
  var parentPasswordEditingController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> login() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    String parentEmail = parentEmailEditingController.text.trim();
    String parentPassword = parentPasswordEditingController.text.trim();

    RequestController req = RequestController(path: 'guardian-login');

    req.setBody({
      "email": parentEmail,
      "password": parentPassword,
    });

    await req.postNoToken();

    var result = req.result();
    print('result = $result');
    if (result['token'] != null) {
      String token = result['token'];
      print('token = $token');

      // store token in shared preferences
      sharedPreferences.setString("token", token);
      sharedPreferences.setString("email", parentEmail);
      //print('OneSignal.login = $parentEmail');
      //OneSignal.login(parentEmail);


      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ParentHomepage()),
      );  
    } else {
      // Handle invalid login response
      Fluttertoast.showToast(
        msg: "Login Failed. Please check your credentials.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Sign in as Parent',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Please enter your credentials to continue',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 2, color: Colors.pinkAccent),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 2, color: Colors.pinkAccent),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.pinkAccent),
                    hintText: "Email",
                  ),
                  controller: parentEmailEditingController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 2, color: Colors.pinkAccent),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                          width: 2, color: Colors.pinkAccent),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.lock_outlined, color: Colors.pinkAccent),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: _obscurePassword
                          ? const Icon(Icons.visibility_off_outlined, color: Colors.pinkAccent)
                          : const Icon(Icons.visibility_outlined, color: Colors.pinkAccent),
                    ),
                    hintText: "Password",
                  ),
                  controller: parentPasswordEditingController,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ForgotPassword()));
                    },
                    child: const Text("Forgot Password?", style: TextStyle(color: Colors.pinkAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  login();
                },
                child: const Text(
                  "Sign In",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Are you a caregiver?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CaregiverLogin()));
                    },
                    child: const Text("Click here!", style: TextStyle(color: Colors.pinkAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
