import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:good_deeds_app/auth/signup/cubit/signup_cubit.dart';
import 'package:shared/shared.dart';

class EmailTextFields extends ConsumerStatefulWidget {
  const EmailTextFields({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends ConsumerState<EmailTextFields> {
  final _debouncer = Debouncer();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SignUpCubit>();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        cubit.onEmailUnfocused();
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context
        .select((SignUpCubit cubit) => cubit.state.submissionStatus.isLoading);
    final emailError =
        context.select((SignUpCubit cubit) => cubit.state.email.errorMessage);
    return AppTextField(
      filled: true,
      focusNode: _focusNode,
      hintText: 'Email',
      enabled: !isLoading,
      textInputType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      onChanged: (v) => _debouncer.run(
        () => context.read<SignUpCubit>().onEmailChanged(v),
      ),
      errorText: emailError,
    );
  }
}

