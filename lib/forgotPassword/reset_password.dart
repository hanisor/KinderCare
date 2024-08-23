import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kindercare/forgotPassword/forgot_pwd_state.dart';
import 'forgot_pwd_bloc.dart';
import 'forgot_pwd_event.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  ResetPasswordScreen({required this.email, required this.token});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reset Password')),
      body: BlocListener<ForgotPwdBloc, ForgotPwdState>(
        listener: (context, state) {
          if (state is SentEmailFail) {
            final snackBar = SnackBar(
              content: const Text('Failed to reset password.'),
              backgroundColor: Colors.red,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _passwordField(),
                _confirmPasswordField(),
                const SizedBox(height: 30.0),
                _submitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: passwordController,
      decoration: InputDecoration(labelText: 'New Password'),
      obscureText: true,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your new password';
        }
        return null;
      },
    );
  }

  Widget _confirmPasswordField() {
    return TextFormField(
      controller: confirmPasswordController,
      decoration: InputDecoration(labelText: 'Confirm New Password'),
      obscureText: true,
      validator: (value) {
        if (value != passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          BlocProvider.of<ForgotPwdBloc>(context).add(
            ResetPasswordButtonPressed(
              email: widget.email,
              token: widget.token,
              password: passwordController.text,
              confirmPassword: confirmPasswordController.text,
            ),
          );
        }
      },
      child: Text('Reset Password'),
    );
  }
}
