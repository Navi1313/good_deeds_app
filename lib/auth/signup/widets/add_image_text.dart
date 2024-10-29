import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class AddImageText extends StatelessWidget {
  const AddImageText({super.key});

  @override
  Widget build(BuildContext context) {
    return Tappable.faded(
      throttle: true,
      throttleDuration: 650.ms,
      child: Text(
        'Add Profile Image',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.titleSmall?.copyWith(color: AppColors.ourColor),
      ),
    );
  }
}
