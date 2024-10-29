import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/auth/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:shared/shared.dart';

class ForgotpasswordEmailFormField extends StatefulWidget {
  const ForgotpasswordEmailFormField({super.key});
  @override
  State<ForgotpasswordEmailFormField> createState() =>
   _ForgotpasswordEmailFormField();
}

class _ForgotpasswordEmailFormField extends 
State<ForgotpasswordEmailFormField> {
  late Debouncer _debouncer;
  
  late FocusNode _focusNode;
  @override
  void initState() {
    _focusNode = FocusNode()..addListener(_focusNodeListner);
    _debouncer = Debouncer();
    super.initState();
  }

  void _focusNodeListner() {
    if (_focusNode.hasFocus) {
      context.read<ForgotPasswordCubit>().onEmailUnfocused();
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_focusNodeListner)
      ..dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: lines_longer_than_80_chars
    final emailError = context.select((ForgotPasswordCubit cubit) => cubit.state.email.errorMessage);
    return AppTextField(
      errorText:   emailError ,
      filled: true,
      hintText: 'Email',
      prefixIcon: const Icon(Icons.email_sharp),
      focusNode: _focusNode,
      textInputAction: TextInputAction.next,
      textInputType: TextInputType.emailAddress,
      onChanged: (value) => _debouncer.run(() {
        context.read<ForgotPasswordCubit>().onEmailChanged(value);
      }),
    );
  }
}
