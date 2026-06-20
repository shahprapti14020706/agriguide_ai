import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const fontFamily = 'Roboto';

  static const title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  static const body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}
