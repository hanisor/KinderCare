import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindercare/parentScreen/parent_homepage.dart';
import 'package:kindercare/request_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../caregiverScreen/forgot_password.dart';
import '../caregiverScreen/parent_registration.dart';

String? finalUsername;

class ParentLogin extends StatefulWidget {
  const ParentLogin({Key? key}) : super(key: key);

  @override
  State<ParentLogin> createState() => _ParentLoginState();
}

class _ParentLoginState extends State<ParentLogin> {
  var parentEmailEditingController = TextEditingController();
  var parentUsernameEditingController = TextEditingController();
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
      backgroundColor: Colors.yellow[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Sign in as parent',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Enter correct email and password',
                  style: TextStyle(color: Colors.black87, fontSize: 18),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 3, color: Colors.deepOrangeAccent),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),
                      hintText: "Enter your email",
                    ),
                    controller: parentEmailEditingController,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: TextFormField(
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            width: 3, color: Colors.deepOrangeAccent),
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      prefixIcon: const Icon(Icons.password_outlined),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: _obscurePassword
                            ? const Icon(Icons.visibility_off_outlined)
                            : const Icon(Icons.visibility_outlined),
                      ),
                      hintText: "Enter your password",
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
                      child: const Text("Forgot password?"),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    // REGISTER
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ParentRegistration()));
                      },
                      child: const Text("Register"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.orange[900]),
                  ),
                  onPressed: () async {
                    final SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    sharedPreferences.setString(
                        'email', parentEmailEditingController.text);
                    //Get.to(CaregiverHomepage());
                    login();
                  },
                  child: Text("Sign in"),
                ),
                const SizedBox(height: 10),
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
                      child: const Text("Click here!"),
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
