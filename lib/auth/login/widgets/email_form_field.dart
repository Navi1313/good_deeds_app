import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/auth/login/cubit/login_cubit.dart';
import 'package:shared/shared.dart';

class EmailFormField extends StatefulWidget {
  const EmailFormField({super.key});

  @override
  State<EmailFormField> createState() => _EmailFormFieldState();
}

class _EmailFormFieldState extends State<EmailFormField> {
  late Debouncer _debouncer;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  @override
  void initState() {
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_focusNodeListner);
    _debouncer = Debouncer();
    super.initState();
  }

  void _focusNodeListner() {
    if (_focusNode.hasFocus) {
      context.read<LoginCubit>().onEmailUnfocused();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_focusNodeListner)
      ..dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: lines_longer_than_80_chars
    final emailError = context.select((LoginCubit cubit) => cubit.state.email.errorMessage);
    return AppTextField(
      errorText:   emailError ,
      filled: true,
      hintText: 'Email',
      prefixIcon: const Icon(Icons.email_sharp),
      focusNode: _focusNode,
      textInputAction: TextInputAction.next,
      textInputType: TextInputType.emailAddress,
      onChanged: (value) => _debouncer.run(() {
        context.read<LoginCubit>().onEmailChanged(value);
      }),
    );
  }
}
