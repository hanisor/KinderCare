import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kindercare/parentScreen/parent_login.dart';
import 'package:kindercare/request_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'caregiver_homepage.dart';
import 'caregiver_registration.dart';
import 'forgot_password.dart';


class CaregiverLogin extends StatefulWidget {
  const CaregiverLogin({Key? key}) : super(key: key);

  @override
  State<CaregiverLogin> createState() => _CaregiverLoginState();
}

class _CaregiverLoginState extends State<CaregiverLogin> {
  var caregiverEmailEditingController = TextEditingController();
  var caregiverUsernameEditingController = TextEditingController();
  var caregiverPasswordEditingController = TextEditingController();
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

    await req.post();

    var result = req.result();
    print('result = $result');
    if (result['token'] != null) {
      String token = result['token'];
      print('token = $token');

      // store token in shared preferences
      sharedPreferences.setString("token", token);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CaregiverHomepage()),
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
                  'Sign in as caregiver',
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
                    controller: caregiverEmailEditingController,
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
                                builder: (context) => CaregiverRegistration()));
                      },
                      child: const Text("Register"),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor:
                    MaterialStateProperty.all(Colors.white),
                    backgroundColor:
                    MaterialStateProperty.all(Colors.orange[900]),
                  ),
                  onPressed: () async {
                    final SharedPreferences sharedPreferences =
                    await SharedPreferences.getInstance();
                    sharedPreferences.setString(
                        'email', caregiverEmailEditingController.text);
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
