// lib/services/forgot_password_service.dart

import 'package:kindercare/request_controller.dart';

class ForgotPasswordService {
  Future<bool> sendResetLink(String email) async {
    RequestController req = RequestController(path: 'forgot-password');

    req.setBody({
      "email": email,
    });

    try {
      await req.postNoToken();
      var result = req.result();
      print('result = $result');
      if (result != null &&
          result['message'] == 'We have emailed your password reset link.') {
        // Handle success
        return true;
      } else {
        // Handle failure
        return false;
      }
    } catch (e) {
      print('Request error: $e');
      // Handle network or other errors
      return false;
    }
  }

  // Add this method to handle the password reset
  Future<bool> resetPassword(String email, String token, String password,
      String confirmPassword) async {
    RequestController req = RequestController(path: 'password/reset');

    req.setBody({
      "email": email,
      "token": token,
      "password": password,
      "password_confirmation": confirmPassword,
    });

    try {
      await req.postNoToken();
      var result = req.result();
      print('result = $result');
      if (result != null &&
          result['message'] == 'Password reset successfully.') {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Request error: $e');
      return false;
    }
  }
}
