// lib/bloc/forgot_password/forgot_pwd_event.dart
abstract class ForgotPwdEvent {}

class SendButtonPressed extends ForgotPwdEvent {
  final String email;
  SendButtonPressed({required this.email});
}
