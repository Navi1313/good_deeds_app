import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_deeds_app/app/app.dart';
import 'package:good_deeds_app/auth/signup/signup.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  @override
  Widget build(BuildContext context) {
    
    return BlocListener<SignUpCubit, SignupState>(
      listener: (context, state) {
        if (state.submissionStatus.isError) {
          openSnackBar(
            SnackbarMessage.error(
              title:
                  signupSubmissionStatusMessage[state.submissionStatus]!.title,
              description: signupSubmissionStatusMessage[state.submissionStatus]
                  ?.description,
            ),
            clearIfQueue: true,
          );
        }
      },
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           SizedBox(
            height: AppSpacing.xxxlg,
          ),
           EmailTextFields(),
           SizedBox(
            height: AppSpacing.md,
          ),
           FullNameTextField() ,
           SizedBox(
            height: AppSpacing.md,
          ),
           OrgId(),
           SizedBox(
            height: AppSpacing.md,
          ),
           PasswordTextField(),
        ],
      ),
    );
  }
}
