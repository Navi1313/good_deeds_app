import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_deeds_app/app/onboarding/donor_status_provider.dart';
import 'package:good_deeds_app/auth/signup/signup.dart';

import 'package:shared/shared.dart';

class FullNameTextField extends ConsumerStatefulWidget {
  const FullNameTextField({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FullNameTextFieldState();
}

class _FullNameTextFieldState extends ConsumerState<FullNameTextField> {
  final _debouncer = Debouncer();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SignUpCubit>();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        cubit.onFullNameUnfocused();
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
    final fullNameError = context
        .select((SignUpCubit cubit) => cubit.state.fullName.errorMessage);
    final isDonor = ref.watch(donorStatusProvider);
    return AppTextField(
      filled: true,
      focusNode: _focusNode,
      hintText: isDonor ? 'Full Name' : 'Organisation Name',
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      autofillHints: const [AutofillHints.givenName],
      enabled: !isLoading,
      onChanged: (v) => _debouncer.run(
        () => context.read<SignUpCubit>().onFullNameChanged(v),
      ),
      errorText: fullNameError,
      errorMaxLines: 3,
    );
  }
}
