import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:good_deeds_app/auth/forgot_password/forgot_password.dart';
import 'package:shared/shared.dart';


class ForgotPasswordButton extends StatelessWidget {
  const ForgotPasswordButton({super.key});
  

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      throttle: true,
      throttleDuration: 650.ms,
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          ManageForgotPasswordPage.route(),
          (_) => true,
        );
      },
      child: Text(
        'Forgot Password',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.titleSmall?.copyWith(color: AppColors.ourColor),
      ),
    );
  }
}
