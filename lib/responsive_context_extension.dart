import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'main.dart';

enum ResponsiveDeviceType { WEAR, MOBILE, TABLET, DESKTOP }

extension ResponsiveContextExtension on BuildContext {
  double get screenWidth => ResponsiveBreakpoints.of(this).screenWidth;

  bool get isMobile =>
      screenWidth >= 0 && screenWidth <= 600 ||
      ResponsiveBreakpoints.of(this).isMobile;

  bool get isTablet =>
      screenWidth >= 601 && screenWidth <= 1000 ||
      ResponsiveBreakpoints.of(this).isTablet;

  bool get isDesktop =>
      screenWidth >= 1001 || ResponsiveBreakpoints.of(this).isDesktop;

  ResponsiveDeviceType getResponsiveDeviceType() {
    if (screenWidth >= 0 && screenWidth <= 390) {
      return ResponsiveDeviceType.WEAR;
    } else if (screenWidth >= 391 && screenWidth <= 600 ||
        ResponsiveBreakpoints.of(this).isMobile) {
      return ResponsiveDeviceType.MOBILE;
    } else if (screenWidth >= 601 && screenWidth <= 1000 ||
        ResponsiveBreakpoints.of(this).isTablet) {
      return ResponsiveDeviceType.TABLET;
    } else if (screenWidth >= 1001 ||
        ResponsiveBreakpoints.of(this).isDesktop) {
      return ResponsiveDeviceType.DESKTOP;
    } else {
      return ResponsiveDeviceType.MOBILE;
    }
  }
}
