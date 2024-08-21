// lib/ui/forgot_pwd.dart
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
        backgroundColor: HexColor("#ecd9c9"),
        bottomOpacity: 0.0,
        elevation: 0.0,
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
          padding: const EdgeInsets.all(18.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _forgotText(),
                  const SizedBox(height: 10.0),
                  _instructionText(),
                  const SizedBox(height: 5.0),
                  _emailField(),
                  const SizedBox(height: 10.0),
                  BlocBuilder<ForgotPwdBloc, ForgotPwdState>(
                    builder: (context, state) {
                      if (state is SendingLoadingState) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: HexColor("#3c1e08"),
                          ),
                        );
                      } else if (state is SentEmailSuccess) {
                        return const Text(
                          'A verification email has been sent, please check your email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        );
                      }
                      return Container();
                    },
                  ),
                  _submitButton(),
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
      "Forgot password",
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _instructionText() {
    return const Text(
      "Enter email address",
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.normal),
    );
  }

  Widget _emailField() {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: TextFormField(
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter email';
          }
          if (!value.trim().contains('@')) {
            return 'Email is not completed';
          }
          return null;
        },
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.email_rounded,
            color: HexColor("#3c1e08"),
          ),
          labelText: 'Email',
          labelStyle: TextStyle(color: HexColor("#3c1e08")),
          focusColor: HexColor("#3c1e08"),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: HexColor("#a4a4a4")),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: HexColor("#3c1e08")),
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
        height: 55.0,
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
                borderRadius: BorderRadius.circular(24.0),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(HexColor("#3c1e08")),
          ),
          child: const Text('SEND', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
