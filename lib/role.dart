import 'package:flutter/material.dart';
import 'package:kindercare/caregiverScreen/caregiver_login.dart';
import 'package:kindercare/parentScreen/parent_login.dart';

class Role extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent, // Changing font color to pink
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Container(
                  child: Column(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParentLogin(),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/parent.png',
                              width: 150,
                              height: 150,
                            ),
                            SizedBox(height: 8),
                            const Text(
                              'Parent',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pinkAccent, // Changing font color to pink
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CaregiverLogin(),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/caregiver.png',
                              width: 150,
                              height: 150,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Caregiver',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink, // Changing font color to pink
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

