// lib/forgotPassword/forgot_pwd_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kindercare/forgotPassword/forgot_password_service.dart';
import 'forgot_pwd_event.dart';
import 'forgot_pwd_state.dart';

class ForgotPwdBloc extends Bloc<ForgotPwdEvent, ForgotPwdState> {
  final ForgotPasswordService service;

  ForgotPwdBloc(this.service) : super(ForgotPwdInitial()) {
    // Existing event handler for SendButtonPressed
    on<SendButtonPressed>(_onSendButtonPressed);

    // Add this new event handler for ResetPasswordButtonPressed
    on<ResetPasswordButtonPressed>(_onResetPasswordButtonPressed);
  }

  void _onSendButtonPressed(
    SendButtonPressed event,
    Emitter<ForgotPwdState> emit,
  ) async {
    emit(SendingLoadingState());
    bool success = await service.sendResetLink(event.email);
    if (success) {
      emit(SentEmailSuccess());
    } else {
      emit(SentEmailFail());
    }
  }

  // Add the reset password handler here
  void _onResetPasswordButtonPressed(
    ResetPasswordButtonPressed event,
    Emitter<ForgotPwdState> emit,
  ) async {
    emit(SendingLoadingState());
    bool success = await service.resetPassword(
      event.email,
      event.token,
      event.password,
      event.confirmPassword,
    );
    if (success) {
      emit(SentEmailSuccess());
    } else {
      emit(SentEmailFail());
    }
  }
}
