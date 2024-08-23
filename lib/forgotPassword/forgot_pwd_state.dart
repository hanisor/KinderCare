abstract class ForgotPwdState {}

class ForgotPwdInitial extends ForgotPwdState {}

class SendingLoadingState extends ForgotPwdState {}

class SentEmailSuccess extends ForgotPwdState {}

class SentEmailFail extends ForgotPwdState {}
