import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Logo aplikasi SINI-GAN (aset vektor `assets/images/logo.svg`).
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo.svg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      semanticsLabel: 'SINI-GAN',
    );
  }
}
