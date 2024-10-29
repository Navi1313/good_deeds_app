import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/app/view/app.dart';
import 'package:good_deeds_app/auth/login/login.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  @override
  void initState() {
    super.initState();
    context.read<LoginCubit>().resetState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit , LoginState>(
      listener: (context, state) {
        if (state.status.isError) {
          openSnackBar(
            SnackbarMessage.error(
              title: loginSubmissionStatusMessage[state.status]!.title
              ,
              description:
                  loginSubmissionStatusMessage[state.status]?.description,
            ),
            clearIfQueue: true,
          );
        }
      },
      listenWhen: (previous , current) => previous.status != current.status,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EmailFormField(),
          SizedBox(height: AppSpacing.md),
          PasswordFormField(),
        ],
      ),
    );
  }
}
