import 'package:http/http.dart' as http;

class AuthApi {
  Future<LoginResult> login(String email, String password) async {
    // Replace this with your actual API endpoint for user authentication
    final response = await http.post(
      Uri.parse('https://your-api.com/login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      // If the login was successful, parse the response and return the token
      final token = response.body; // Assuming the token is returned directly as the response
      return LoginResult(success: true, token: token);
    } else {
      // If the login failed, return an error message or handle it as needed
      return LoginResult(success: false, errorMessage: 'Login failed');
    }
  }
}

class LoginResult {
  final bool success;
  final String? token;
  final String? errorMessage;

  LoginResult({required this.success, this.token, this.errorMessage});
}
