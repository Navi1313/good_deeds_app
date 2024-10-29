import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/app/view/app.dart';
import 'package:good_deeds_app/auth/forgot_password/cubit/forgot_password_cubit.dart';
import 'package:good_deeds_app/auth/forgot_password/forgot_password.dart';

class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state.status.isSuccess) {
          openSnackBar(
            const SnackbarMessage.success(
              title: 'OTP Sucessfully Sended to Email',
            ),
          );
        }
        if (state.status.isError) {
          openSnackBar(
            SnackbarMessage.error(
              title: forgotPasswordStatusMessage[state.status]!.title,
              description:
                  forgotPasswordStatusMessage[state.status]?.description,
            ),
            clearIfQueue: true,
          );
        }
      },
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ForgotpasswordEmailFormField(),
        ],
      ),
    );
  }
}
