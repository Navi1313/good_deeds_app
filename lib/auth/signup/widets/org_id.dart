import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_deeds_app/app/onboarding/donor_status_provider.dart';

import 'package:good_deeds_app/auth/signup/cubit/signup_cubit.dart';
import 'package:shared/shared.dart';

class OrgId extends ConsumerStatefulWidget {
  const OrgId({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _OrgIdState();
}

class _OrgIdState extends ConsumerState<OrgId> {
  final _debouncer = Debouncer();
  final _focusNode = FocusNode();
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final cubit = context.read<SignUpCubit>();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        cubit.onUsernameUnfocused();
      }
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context
        .select((SignUpCubit cubit) => cubit.state.submissionStatus.isLoading);
    final usernameError = context
        .select((SignUpCubit cubit) => cubit.state.username.errorMessage);
    final isDonor = ref.watch(donorStatusProvider);

    return AppTextField(
      filled: true,
      focusNode: _focusNode,
      hintText: isDonor ? 'Write Yes , If Donor' : 'Write Yes , If NGO',
      textInputAction: TextInputAction.next,
      enabled: !isLoading,
      onChanged: (v) => _debouncer.run(() {
        final transformedText = isDonor ? 'TRUE' : 'FALSE'; 
        _textController.value = _textController.value.copyWith(
          text: transformedText,
          selection: TextSelection.collapsed(offset: transformedText.length),
        );
        context.read<SignUpCubit>().onUsernameChanged(transformedText);
      }),
      errorMaxLines: 3,
      errorText: usernameError,
    );
  }
}
