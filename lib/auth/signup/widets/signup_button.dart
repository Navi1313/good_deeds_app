import 'dart:io';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/auth/signup/cubit/signup_cubit.dart';

class SignUpButton extends StatelessWidget {
  const SignUpButton({
    super.key,
    this.avatarFile,
  });

  final File? avatarFile;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),),
      ),
    );
    final isLoading = context
        .select((SignUpCubit bloc) => bloc.state.submissionStatus.isLoading);
    final child = switch (isLoading) {
      true => AppButton.inProgress(style: style, scale: 0.5),
      _ => AppButton.auth(
          'Sign Up',
          () => context.read<SignUpCubit>().onSubmit(avatarFile),
          style: style,
          outlined: true,
        ),
    };
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: switch (context.screenWidth) {
          > 600 => context.screenWidth * .6,
          _ => context.screenWidth,
        },
      ),
      child: child,
    );
  }
}
