import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindercare/parentScreen/parent_login.dart';
import 'package:kindercare/request_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'caregiver_homepage.dart';
import 'forgot_password.dart';

class CaregiverLogin extends StatefulWidget {
  const CaregiverLogin({Key? key}) : super(key: key);

  @override
  State<CaregiverLogin> createState() => _CaregiverLoginState();
}

class _CaregiverLoginState extends State<CaregiverLogin> {
  final caregiverEmailEditingController = TextEditingController();
  final caregiverPasswordEditingController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> login() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    String caregiverEmail = caregiverEmailEditingController.text.trim();
    String caregiverPassword = caregiverPasswordEditingController.text.trim();

    RequestController req = RequestController(path: 'caregiver-login');

    req.setBody({
      "email": caregiverEmail,
      "password": caregiverPassword,
    });
    try {
      await req.postNoToken();

      var result = req.result();
      print('result = $result');
      if (result != null && result['token'] != null) {
        String token = result['token'];
        print('token = $token');

        // store token in shared preferences
        sharedPreferences.setString("token", token);
        sharedPreferences.setString("email", caregiverEmail);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CaregiverHomepage()),
        );
      } else {
        // Handle invalid login response
        _showLoginErrorDialog();
      }
    } catch (e) {
      print('Login error: $e');
      // Handle network or other errors
      _showLoginErrorDialog();
    }
  }

  void _showLoginErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Login Failed"),
          content: Text("Invalid email or password. Please try again."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                'Caregiver Login',
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
                      borderSide:
                          const BorderSide(width: 2, color: Colors.pinkAccent),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 2, color: Colors.pinkAccent),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined,
                        color: Colors.pinkAccent),
                    hintText: "Email",
                  ),
                  controller: caregiverEmailEditingController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: TextField(
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 2, color: Colors.pinkAccent),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 2, color: Colors.pinkAccent),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    prefixIcon: const Icon(Icons.lock_outlined,
                        color: Colors.pinkAccent),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: _obscurePassword
                          ? const Icon(Icons.visibility_off_outlined,
                              color: Colors.pinkAccent)
                          : const Icon(Icons.visibility_outlined,
                              color: Colors.pinkAccent),
                    ),
                    hintText: "Password",
                  ),
                  controller: caregiverPasswordEditingController,
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
                    child: const Text("Forgot Password?",
                        style: TextStyle(color: Colors.pinkAccent)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  login();
                },
                child: const Text("Sign In",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 255, 254, 255),
                    )),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Are you a parent?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ParentLogin()));
                    },
                    child: const Text("Click here!",
                        style: TextStyle(color: Colors.pinkAccent)),
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
