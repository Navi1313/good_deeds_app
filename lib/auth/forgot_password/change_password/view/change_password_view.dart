import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:good_deeds_app/auth/cubit/manage_password_cubit.dart';
import 'package:good_deeds_app/auth/forgot_password/change_password/widgets.dart';

class ChangePasswordView extends StatelessWidget {
  const ChangePasswordView({super.key});

  void _confirmGoBack(BuildContext context) => context.confirmAction(
        fn: () => context
            .read<ManagePasswordCubit>()
            .changeScreen(showForgotPassword: true),
        title: 'Are You sure tou want to go back',
        content: 'if you go back then you loose all the edits',
        noText: 'Cancel',
        yesText: 'Go Back',
        yesTextStyle: context.labelLarge?.apply(color: AppColors.ourColor),
      );
  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () {
        _confirmGoBack(context);
        return Future.value(false);
      },
      child: AppScaffold(
        releaseFocus: true,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text('Change Password'),
          centerTitle: false,
          leading: IconButton(
            onPressed: () => _confirmGoBack(context),
            icon: Icon(Icons.adaptive.arrow_back),
          ),
        ),
        body: const AppConstrainedScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xlg,
          ),
          child: Column(
            children: [
              Gap.v(AppSpacing.xxxlg*3),
              Expanded(
                child: Column(
                  children: [
                    ChangePasswordForm(),
                    Gap.v(AppSpacing.xlg),
                    ChangePasswordButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
