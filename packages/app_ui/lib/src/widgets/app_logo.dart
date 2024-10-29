import 'package:app_ui/src/generated/assets.gen.dart';
import 'package:flutter/material.dart';

// ignore: public_member_api_docs
class AppLogo extends StatelessWidget {
  // ignore: public_member_api_docs
  const AppLogo({
    required this.fit,
    this.color,
    super.key,
    this.height,
    this.width,
  });

  /// This is height of the logo
  final double? width;

  /// This is width of the logo
  final double? height;

  ///   Box fit
  final BoxFit fit;

  /// Color of the logo
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // ignore: lines_longer_than_80_chars

    final theme = Theme.of(context) ;
    final isDarkTheme = theme.brightness == Brightness.dark;
    
    return isDarkTheme ? Assets.icons.logo.svg(
      width: width ?? 130,
      height: height ?? 130,
      fit:  fit,
      // ignore: lines_longer_than_80_chars
      //colorFilter: ColorFilter.mode(color ?? context.adaptiveColor, BlendMode.srcIn),
    ) : Assets.icons.lighticon.svg(
      width: width ?? 130,
      height: height ?? 130,
      fit:  fit,
      // ignore: lines_longer_than_80_chars
      //colorFilter: ColorFilter.mode(color ?? context.adaptiveColor, BlendMode.srcIn),
    ) ;
  }
}
