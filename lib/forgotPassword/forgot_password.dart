import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:kindercare/forgotPassword/forgot_pwd_bloc.dart';
import 'package:kindercare/forgotPassword/forgot_pwd_event.dart';
import 'package:kindercare/forgotPassword/forgot_pwd_state.dart';

class ForgotPwd extends StatefulWidget {
  const ForgotPwd({super.key});

  @override
  State<ForgotPwd> createState() => _ForgotPwdState();
}

class _ForgotPwdState extends State<ForgotPwd> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#FFD1DC"),
        bottomOpacity: 0.0,
        elevation: 0.0,
        title: const Text(
          "Reset Password",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocListener<ForgotPwdBloc, ForgotPwdState>(
        listener: (context, state) {
          if (state is SentEmailFail) {
            final snackBar = SnackBar(
              content: const Text('Email is invalid. Please try again'),
              backgroundColor: Colors.red,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/forgot_password.png', // Add an appropriate image in your assets
                    height: 150,
                  ),
                  const SizedBox(height: 20.0),
                  _forgotText(),
                  const SizedBox(height: 20.0),
                  _instructionText(),
                  const SizedBox(height: 20.0),
                  _emailField(),
                  const SizedBox(height: 30.0),
                  BlocBuilder<ForgotPwdBloc, ForgotPwdState>(
                    builder: (context, state) {
                      if (state is SendingLoadingState) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: HexColor("#A7C7E7"),
                          ),
                        );
                      } else if (state is SentEmailSuccess) {
                        return const Text(
                          'A verification email has been sent, please check your email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        );
                      }
                      return Container();
                    },
                  ),
                  const SizedBox(height: 20.0),
                  _submitButton(),
                  const SizedBox(height: 20.0),
                  _backToLogin(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _forgotText() {
    return const Text(
      "Forgot your password?",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3C1E08),
      ),
    );
  }

  Widget _instructionText() {
    return const Text(
      "Don't worry! Just fill in your email and we'll send you a link to reset your password.",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.normal,
        color: Color(0xFF3C1E08),
      ),
    );
  }

  Widget _emailField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!value.trim().contains('@')) {
            return 'Email is not complete';
          }
          return null;
        },
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.email_rounded,
            color: HexColor("#A7C7E7"),
          ),
          labelText: 'Email Address',
          labelStyle: TextStyle(color: HexColor("#3C1E08")),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: HexColor("#FFD1DC")),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: HexColor("#A7C7E7")),
          ),
        ),
      ),
    );
  }

  Widget _submitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: SizedBox(
        width: double.infinity,
        height: 50.0,
        child: ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              BlocProvider.of<ForgotPwdBloc>(context).add(
                SendButtonPressed(email: emailController.text.trim()),
              );
            }
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(HexColor("#FFD1DC")),
          ),
          child: const Text(
            'SEND RESET LINK',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _backToLogin() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: const Text(
        "Back to Login",
        style: TextStyle(
          color: Color(0xFF3C1E08),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
