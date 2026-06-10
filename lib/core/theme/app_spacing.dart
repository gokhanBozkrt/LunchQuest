import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xs2 = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double massive = 48;

  // Semantic
  static const double pagePad = lg;
  static const double sectionGap = xxl;
  static const double cardPad = lg;
  static const double safeTop = 56;
  static const double navH = 86;

  // Helpers
  static Widget h(double v) => SizedBox(width: v);
  static Widget v(double v) => SizedBox(height: v);
  static const Widget hXS = SizedBox(width: xs);
  static const Widget hSM = SizedBox(width: sm);
  static const Widget hMD = SizedBox(width: md);
  static const Widget hLG = SizedBox(width: lg);
  static const Widget vXS = SizedBox(height: xs);
  static const Widget vSM = SizedBox(height: sm);
  static const Widget vMD = SizedBox(height: md);
  static const Widget vLG = SizedBox(height: lg);
  static const Widget vXL = SizedBox(height: xl);
  static const Widget vXXL = SizedBox(height: xxl);
  static const Widget vXXXL = SizedBox(height: xxxl);
}

abstract final class AppRadius {
  static const double xs = 10;
  static const double sm = 14;
  static const double md = 18;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 999;

  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

abstract final class AppDimensions {
  // Screen (iPhone 14 Pro)
  static const double screenW = 393;
  static const double screenH = 852;

  // Avatar
  static const double avatarSM = 28;
  static const double avatarMD = 36;
  static const double avatarLG = 46;
  static const double avatarXL = 82;

  // Buttons
  static const double btnHeight = 52;
  static const double btnHeightSM = 40;

  // Cards
  static const double eventCardW = 270;
  static const double restaurantTileSize = 48;

  // Icons
  static const double iconSM = 16;
  static const double iconMD = 20;
  static const double iconLG = 24;
  static const double iconXL = 30;

  // Web breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
}
