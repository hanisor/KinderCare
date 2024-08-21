// lib/bloc/forgot_password/forgot_pwd_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kindercare/forgotPassword/forgot_password_service.dart';
import 'forgot_pwd_event.dart';
import 'forgot_pwd_state.dart';

class ForgotPwdBloc extends Bloc<ForgotPwdEvent, ForgotPwdState> {
  final ForgotPasswordService service;

  ForgotPwdBloc(this.service) : super(ForgotPwdInitial()) {
    // Register the event handler for SendButtonPressed
    on<SendButtonPressed>(_onSendButtonPressed);
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
}
