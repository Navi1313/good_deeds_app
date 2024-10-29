import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/auth/forgot_password/change_password/cubit/change_password_cubit.dart';
import 'package:good_deeds_app/auth/forgot_password/cubit/forgot_password_cubit.dart';

class ChangePasswordButton extends StatelessWidget {
  const ChangePasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      backgroundColor: const WidgetStatePropertyAll(AppColors.ourColor),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );
    final isLoading = context
        .select((ChangePasswordCubit cubit) => cubit.state.status.isLoading);
    final child = switch (isLoading) {
      true => AppButton.inProgress(style: style, scale: 0.5),
      _ => AppButton.auth(
          'Change Password',
          () => context.read<ChangePasswordCubit>().onSubmit(
                email: context.read<ForgotPasswordCubit>().state.email.value,
              ),
          style: style,
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