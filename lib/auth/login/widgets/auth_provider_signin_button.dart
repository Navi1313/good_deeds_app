import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/auth/login/cubit/login_cubit.dart';
import 'package:provider/provider.dart';
import 'package:shared/shared.dart';

class AuthProviderSignInButton extends StatelessWidget {
  const AuthProviderSignInButton({
    required this.provider,
    required this.onPressed,
    super.key,
  });

  final AuthProvider provider;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isInProgress = context.select(
      (LoginCubit cubit) => switch (provider) {
        AuthProvider.google => cubit.state.status.isGoogleAuthInProgress,
        AuthProvider.github => cubit.state.status.isGithubAuthInProgress,
      },
    );
    final effectiveIcon = switch (provider) {
      AuthProvider.github => Assets.icons.github.svg(),
      AuthProvider.google => Assets.icons.google.svg(),
    };
    final icon = SizedBox.square(
      dimension: 24,
      child: effectiveIcon,
    );
    return Container(
      constraints: BoxConstraints(
        minWidth: switch (context.screenWidth) {
          > 600 => context.screenWidth * .6,
          _ => context.screenWidth,
        },
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.xxxlg),
      child: Tappable.faded(
        throttle: true,
        throttleDuration: 650.ms,
        backgroundColor: context.theme.focusColor,
        borderRadius: BorderRadius.circular(10),
        onTap: isInProgress ? null : onPressed,
        child: isInProgress
            ? Center(child: AppCircularProgress(context.adaptiveColor))
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(child: icon),
                    Flexible(
                      child:  Text(
                        provider == AuthProvider.github ? ' Github': ' Google',
                        style: context.labelLarge?.copyWith(
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

enum AuthProvider {
  github('Github'),
  google('Google');

  const AuthProvider(this.value);

  final String value;
}
