import 'dart:io';
import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_deeds_app/app/onboarding/donor_status_provider.dart';
import 'package:good_deeds_app/auth/signup/signup.dart';
import 'package:good_deeds_app/auth/signup/widets/signup_form.dart';
import 'package:good_deeds_block_ui/good_deeds_blockui.dart';
import 'package:user_repository/user_repository.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(
        userRepository: context.read<UserRepository>(),
      ),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  //Uint8List? _imageBytes;
  File? _avatarFile;

  @override
  Widget build(BuildContext context) {
    //final isDonor = context.select((SignUpCubit cubit) => cubit.state.isDonor);
    final isDonor = ref.read<bool>(donorStatusProvider);
    print(isDonor);
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xlg),
        child: Column(
          children: [
            // const Gap.v(AppSpacing.xxxlg + AppSpacing.xlg),
            const Text(
              'Good Deeds',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.ourColor,
              ),
            ),
            const SizedBox(
              height: AppSpacing.xxxlg,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    child: isDonor
                        ? AvatarImagePicker(
                            onUpload: (_, avatarFile) {
                              setState(() {
                                _avatarFile = avatarFile;
                              });
                            },
                          )
                        : BgImage(
                            onUpload: (_, avatarFile) {
                              setState(() {
                                _avatarFile = avatarFile;
                            
                              });
                            },
                          ),
                  ),
                  Align(
                    alignment:
                        isDonor ? Alignment.topCenter : Alignment.topRight,
                    child: const AddImageText(),
                  ),
                  const SignupForm(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xlg,
                    ),
                    child: Align(
                      child: SignUpButton(
                           avatarFile:  _avatarFile, 
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SignInIntoAccountButton(),
          ],
        ),
      ),
    );
  }
}
