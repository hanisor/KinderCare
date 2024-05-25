import 'package:flutter/material.dart';
import 'package:kindercare/caregiverScreen/caregiver_login.dart';
import 'package:kindercare/parentScreen/parent_login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Role extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    Future<void> saveUserRole(String role) async {
      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString('role', role);
    }

    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent, // Changing font color to pink
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  child: Column(
                    children: [
                      OutlinedButton(
                        onPressed: () async {
                          await saveUserRole('parent');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ParentLogin(),
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
                            const SizedBox(height: 8),
                            const Text(
                              'Parent',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pinkAccent, // Changing font color to pink
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: () async {
                          await saveUserRole('caregiver');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CaregiverLogin(),
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
                            const SizedBox(height: 8),
                            const Text(
                              'Caregiver',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.pink, // Changing font color to pink
                              ),
                            ),
                            const SizedBox(height: 10),
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
