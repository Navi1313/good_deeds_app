import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/auth/cubit/auth_cubit.dart';


/// {@template sign_up_account_button}
/// Sign up widget that contains sign up button.
/// {@endtemplate}
class SignUpNewAccountButton extends StatelessWidget {
  /// {@macro sign_up_account_button}
  const SignUpNewAccountButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AuthCubit>();
    return Tappable.faded(
      onTap: () => cubit.changeAuth(showLogin: false),
      child: Text.rich(
        overflow: TextOverflow.visible,
        style: context.bodyMedium,
        TextSpan(
          children: [
            const TextSpan(text: 'New to Good Deeds? '),
            TextSpan(
              text: ' Sign up.',
              style: context.bodyMedium?.copyWith(color: AppColors.ourColor),
            ),
          ],
        ),
      ),
    );
  }
}
