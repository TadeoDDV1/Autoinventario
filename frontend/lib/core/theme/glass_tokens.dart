import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);

  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);

  static const SizedBox gapXS = SizedBox(width: xs, height: xs);
  static const SizedBox gapSM = SizedBox(width: sm, height: sm);
  static const SizedBox gapMD = SizedBox(width: md, height: md);
  static const SizedBox gapLG = SizedBox(width: lg, height: lg);
  static const SizedBox gapXL = SizedBox(width: xl, height: xl);
}

class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double pill = 999;

  static const BorderRadius brXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius brSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius brXXXL = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
}

class AppShadows {
  static const double blurSmall = 8;
  static const double blurMedium = 16;
  static const double blurLarge = 24;

  static const Offset offsetSmall = Offset(0, 2);
  static const Offset offsetMedium = Offset(0, 4);
  static const Offset offsetLarge = Offset(0, 8);

  static List<BoxShadow> get small => [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: blurSmall,
          offset: offsetSmall,
        ),
      ];

  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: blurMedium,
          offset: offsetMedium,
        ),
      ];

  static List<BoxShadow> get large => [
        BoxShadow(
          color: AppColors.shadowLarge,
          blurRadius: blurLarge,
          offset: offsetLarge,
        ),
      ];

  static List<BoxShadow> get none => const [];

  static List<BoxShadow> card(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }

  static List<BoxShadow> elevated(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];
    }
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.12),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: AppColors.shadowMedium,
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }
}

class GlassTokens {
  static const double blurSmall = 0;
  static const double blurMedium = 0;
  static const double blurLarge = 0;

  static const double borderRadiusSmall = AppRadius.md;
  static const double borderRadiusMedium = AppRadius.lg;
  static const double borderRadiusLarge = AppRadius.xxl;

  static const double borderWidth = 0.5;
  static const double borderOpacity = 0.15;

  static const double shadowBlur = 12;

  static const List<Color> backgroundGradient = [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];
  static const List<Color> altGradient = [
    Color(0xFF1A1B41),
    Color(0xFF2D2A54),
    Color(0xFF3D3A6A),
  ];

  static Color glassColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.35);
  }

  static Color glassBorder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.5);
  }
}