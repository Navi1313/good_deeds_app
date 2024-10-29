import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:good_deeds_app/app/onboarding/donor_status_provider.dart';
import 'package:good_deeds_app/auth/cubit/auth_cubit.dart';
import 'package:good_deeds_app/auth/login/login.dart';
import 'package:good_deeds_app/auth/login/widgets/sign_in_button.dart';
import 'package:user_repository/user_repository.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        userRepository: context.read<UserRepository>(),
      ),
      child: const LoginView(),
    );
  }
}

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDonor = ref.watch(donorStatusProvider);
    return AppScaffold(
      releaseFocus: true,
      resizeToAvoidBottomInset: true,
      body: AppConstrainedScrollView(
        child: Column(
          children: [
            Text(
              isDonor ? 'Donor Login Page' : 'NGO Login Page',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.ourColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xxlg * 2),
            const AppLogo(
              fit: BoxFit.fitHeight,
              width: double.infinity,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 30,
                  horizontal: 22,
                ),
                child: Column(
                  children: [
                    const LoginForm(),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    const Align(
                      alignment: Alignment.topRight,
                      child: ForgotPasswordButton(),
                    ),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    const SignInButton(),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),

                    if (isDonor)
                      const Padding(
                        padding: EdgeInsets.only(top: AppSpacing.xxlg),
                        child: AppDivider(),
                      )
                    else
                      const Padding(padding: EdgeInsets.zero),
                    const SizedBox(
                      height: AppSpacing.md,
                    ),
                    // Row for AuthProviderSignInButton, aligned properly
                    if (isDonor)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: AuthProviderSignInButton(
                              provider: AuthProvider.google,
                              onPressed: () =>
                                  context.read<LoginCubit>().loginWithGoogle(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AuthProviderSignInButton(
                              provider: AuthProvider.github,
                              onPressed: () =>
                                  context.read<LoginCubit>().loginWithGithub(),
                            ),
                          ),
                        ],
                      )
                    else
                      const SizedBox(),

                    if (isDonor)
                      const NgoLoginExtraButton()
                    else
                      const DonorLoginExtraButton(),
                  ],
                ),
              ),
            ),
            const SignUpNewAccountButton(),
          ],
        ),
      ),
    );
  }
}

class DonorLoginExtraButton extends ConsumerWidget {
  const DonorLoginExtraButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cubit = context.read<AuthCubit>();
    return Tappable.faded(
      onTap: () async {
        await ref.read(donorStatusProvider.notifier).setDonorStatus(true);
        cubit.changeAuth(showLogin: true);
      },
      child: Text.rich(
        overflow: TextOverflow.visible,
        style: context.bodyMedium,
        TextSpan(
          children: [
            TextSpan(
              text: 'Login As Donor ? ',
              style: context.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            TextSpan(
              text: ' Log in.',
              style: context.bodyLarge?.copyWith(
                color: AppColors.ourColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NgoLoginExtraButton extends ConsumerWidget {
  const NgoLoginExtraButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cubit = context.read<AuthCubit>();
    return Tappable.faded(
      onTap: () async {
        await ref.read(donorStatusProvider.notifier).setDonorStatus(false);
        cubit.changeAuth(showLogin: true);
      },
      child: Text.rich(
        overflow: TextOverflow.visible,
        style: context.bodyMedium,
        TextSpan(
          children: [
            TextSpan(
              text: 'Login As NGO ? ',
              style: context.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            TextSpan(
              text: ' Log in.',
              style: context.bodyLarge?.copyWith(
                color: AppColors.ourColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
