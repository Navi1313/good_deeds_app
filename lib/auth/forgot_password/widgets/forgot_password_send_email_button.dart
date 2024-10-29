import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/auth/cubit/manage_password_cubit.dart';
import 'package:good_deeds_app/auth/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:shared/shared.dart';

class ForgotButtonSendEmailButton extends StatelessWidget {
  const ForgotButtonSendEmailButton({super.key});

  void _onPressed(BuildContext context) =>
      context.read<ForgotPasswordCubit>().onSubmit(
            onSuccess: () => context
                .read<ManagePasswordCubit>()
                .changeScreen(showForgotPassword: false),
          );

  @override
  Widget build(BuildContext context) {
    final isLoading = context
        .select((ForgotPasswordCubit bloc) => bloc.state.status.isLoading);
    final child = Tappable.faded(
      throttle: true,
      throttleDuration: 650.ms,
      backgroundColor: AppColors.ourColor,
      borderRadius: BorderRadius.circular(4),
      onTap: isLoading ? null : () => _onPressed(context),
      child: isLoading
          ? Center(child: AppCircularProgress(context.adaptiveColor))
          : Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.sm + AppSpacing.sm,
              ),
              child: Align(
                child: Text(
                  'Send Confirmation ',
                  style: context.labelLarge?.copyWith(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
    );
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