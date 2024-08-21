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
}
