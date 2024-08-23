abstract class ForgotPwdEvent {}

// Event for sending the reset link
class SendButtonPressed extends ForgotPwdEvent {
  final String email;
  SendButtonPressed({required this.email});
}

// Event for resetting the password
class ResetPasswordButtonPressed extends ForgotPwdEvent {
  final String email;
  final String token;
  final String password;
  final String confirmPassword;

  ResetPasswordButtonPressed({
    required this.email,
    required this.token,
    required this.password,
    required this.confirmPassword,
  });
}
