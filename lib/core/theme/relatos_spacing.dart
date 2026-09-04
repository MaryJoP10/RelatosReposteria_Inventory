import 'package:flutter/material.dart';

/// Shared spacing scale. Prefer these over magic numbers in screens.
abstract final class RelatosSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double page = 20;
  static const double cardPadding = 16;
  static const double touchTarget = 48;
}

abstract final class RelatosRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;

  static const BorderRadius card = BorderRadius.all(Radius.circular(md));
  static const BorderRadius button = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius chip = BorderRadius.all(Radius.circular(20));
}

abstract final class RelatosElevation {
  static const double none = 0;
  static const double card = 0.4;
  static const double raised = 1.5;
}

abstract final class RelatosBreakpoints {
  static const double wide = 800;
}
