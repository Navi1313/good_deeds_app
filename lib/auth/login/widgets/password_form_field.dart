import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/auth/login/cubit/login_cubit.dart';
import 'package:shared/shared.dart';

class PasswordFormField extends StatefulWidget {
  const PasswordFormField({super.key});

  @override
  State<PasswordFormField> createState() => _PasswordFormFieldState();
}

class _PasswordFormFieldState extends State<PasswordFormField> {
  late Debouncer _debouncer;
  late TextEditingController _controller;
  late FocusNode _focusNode;
  // Changed isPasswordVisible from final to a mutable variable
  bool _isPasswordVisible = false;

  @override
  void initState() {
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(_focusNodeListener);
    _debouncer = Debouncer();
    super.initState();
  }

  void _focusNodeListener() {
    if (_focusNode.hasFocus) {
      context.read<LoginCubit>().onPasswordUnfocused();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_focusNodeListener)
      ..dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final passwordError =
        context.select((LoginCubit cubit) => cubit.state.password.errorMessage);

    return AppTextField(
      errorText: passwordError,
      filled: true,
      hintText: 'Password',
      obscureText: !_isPasswordVisible,  // Made sure obscureText toggles with 
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible
              ? Icons.visibility
              : Icons.visibility_off, // Show/hide icon based on state
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible; // Toggle visibility
          });
        },
      ),
      prefixIcon: const Icon(Icons.lock),
      focusNode: _focusNode,
      textInputAction: TextInputAction.done,
      textInputType: TextInputType.visiblePassword,
      onChanged: (value) => _debouncer.run(() {
        context.read<LoginCubit>().onPasswordChanged(value);
      }),
    );
  }
}
