import 'package:flutter/material.dart';

@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  const AppColorsExt({
    required this.primary,
    required this.primaryInk,
    required this.onGradient,
    required this.onPrimary,
    required this.primaryLight,
    required this.primaryDark,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.card,
    required this.dialog,
    required this.bottomSheet,
    required this.appBar,
    required this.bottomNav,
    required this.drawer,
    required this.inputFill,
    required this.accent,
    required this.onAccent,
    required this.text,
    required this.textSecondary,
    required this.textDisabled,
    required this.textOnPrimary,
    required this.icon,
    required this.iconSecondary,
    required this.border,
    required this.divider,
    required this.outline,
    required this.shadow,
    required this.overlay,
    required this.scrim,
    required this.gradientStart,
    required this.gradientEnd,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.chartColors,
  });
  final Color primary;
  final Color primaryInk;
  final Color onGradient;
  final Color onPrimary;
  final Color primaryLight;
  final Color primaryDark;
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color card;
  final Color dialog;
  final Color bottomSheet;
  final Color appBar;
  final Color bottomNav;
  final Color drawer;
  final Color inputFill;
  final Color accent;
  final Color onAccent;
  final Color text;
  final Color textSecondary;
  final Color textDisabled;
  final Color textOnPrimary;
  final Color icon;
  final Color iconSecondary;
  final Color border;
  final Color divider;
  final Color outline;
  final Color shadow;
  final Color overlay;
  final Color scrim;
  final Color gradientStart;
  final Color gradientEnd;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final List<Color> chartColors;
  static const defaultPrimary = Color(0xFF0D1F42);
  static const presets = <Color>[
    defaultPrimary,
    Color(0xFFE53935),
    Color(0xFF2E7D32),
    Color(0xFF7E57C2),
    Color(0xFF00838F),
    Color(0xFFFDD835),
    Color(0xFFF5F5F5),
    Color(0xFF101010),
  ];
  static Color foreground(Color color) => color.computeLuminance() > .179
      ? const Color(0xFF080B10)
      : const Color(0xFFFFFFFF);
  factory AppColorsExt.fromPrimary(Color primary, {required bool dark}) {
    final hsl = HSLColor.fromColor(primary);
    Color tone(double lightness, double saturation) =>
        HSLColor.fromAHSL(1, hsl.hue, saturation, lightness).toColor();
    final onPrimary = foreground(primary);
    final accent = HSLColor.fromAHSL(
      1,
      (hsl.hue + 35) % 360,
      .75,
      dark ? .64 : .40,
    ).toColor();
    return AppColorsExt(
      primary: primary,
      primaryInk: tone(dark ? .74 : .28, .62),
      onGradient: tone(.99, .1),
      onPrimary: onPrimary,
      primaryLight: tone(.65, .65),
      primaryDark: tone(.2, .65),
      background: tone(dark ? .08 : .975, .22),
      surface: tone(dark ? .14 : .995, .18),
      surfaceVariant: tone(dark ? .19 : .94, .25),
      card: tone(dark ? .14 : .995, .18),
      dialog: tone(dark ? .14 : .995, .18),
      bottomSheet: tone(dark ? .14 : .995, .18),
      appBar: primary,
      bottomNav: tone(dark ? .12 : .98, .22),
      drawer: tone(dark ? .12 : .96, .25),
      inputFill: tone(dark ? .18 : .98, .2),
      accent: accent,
      onAccent: foreground(accent),
      text: tone(dark ? .95 : .10, .22),
      textSecondary: tone(dark ? .76 : .34, .17),
      textDisabled: tone(dark ? .52 : .49, .12),
      textOnPrimary: onPrimary,
      icon: tone(dark ? .9 : .19, .25),
      iconSecondary: tone(dark ? .72 : .37, .18),
      border: tone(dark ? .32 : .80, .20),
      divider: tone(dark ? .27 : .87, .2),
      outline: tone(dark ? .48 : .56, .18),
      shadow: tone(.035, .3).withValues(alpha: .18),
      overlay: tone(.07, .25).withValues(alpha: .12),
      scrim: tone(.03, .25).withValues(alpha: .6),
      gradientStart: tone(.20, .62),
      gradientEnd: tone(.095, .74),
      shimmerBase: tone(dark ? .19 : .9, .2),
      shimmerHighlight: tone(dark ? .28 : .98, .2),
      success: const Color(0xFF2E7D32),
      warning: const Color(0xFFAC6500),
      error: const Color(0xFFDC2626),
      info: const Color(0xFF1479E8),
      chartColors: List.unmodifiable(
        List.generate(
          6,
          (i) => HSLColor.fromAHSL(
            1,
            (hsl.hue + i * 47) % 360,
            .65,
            dark ? .65 : .40,
          ).toColor(),
        ),
      ),
    );
  }
  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientStart, gradientEnd],
  );
  Map<String, Color> get roles => {
    'primary': primary,
    'primaryInk': primaryInk,
    'onGradient': onGradient,
    'onPrimary': onPrimary,
    'primaryLight': primaryLight,
    'primaryDark': primaryDark,
    'background': background,
    'surface': surface,
    'surfaceVariant': surfaceVariant,
    'card': card,
    'dialog': dialog,
    'bottomSheet': bottomSheet,
    'appBar': appBar,
    'bottomNav': bottomNav,
    'drawer': drawer,
    'inputFill': inputFill,
    'accent': accent,
    'onAccent': onAccent,
    'text': text,
    'textSecondary': textSecondary,
    'textDisabled': textDisabled,
    'textOnPrimary': textOnPrimary,
    'icon': icon,
    'iconSecondary': iconSecondary,
    'border': border,
    'divider': divider,
    'outline': outline,
    'shadow': shadow,
    'overlay': overlay,
    'scrim': scrim,
    'gradientStart': gradientStart,
    'gradientEnd': gradientEnd,
    'shimmerBase': shimmerBase,
    'shimmerHighlight': shimmerHighlight,
    'success': success,
    'warning': warning,
    'error': error,
    'info': info,
    for (var i = 0; i < chartColors.length; i++) 'chart$i': chartColors[i],
  };
  @override
  AppColorsExt copyWith({
    Color? primary,
    Color? primaryInk,
    Color? onGradient,
    Color? onPrimary,
    Color? primaryLight,
    Color? primaryDark,
    Color? background,
    Color? surface,
    Color? surfaceVariant,
    Color? card,
    Color? dialog,
    Color? bottomSheet,
    Color? appBar,
    Color? bottomNav,
    Color? drawer,
    Color? inputFill,
    Color? accent,
    Color? onAccent,
    Color? text,
    Color? textSecondary,
    Color? textDisabled,
    Color? textOnPrimary,
    Color? icon,
    Color? iconSecondary,
    Color? border,
    Color? divider,
    Color? outline,
    Color? shadow,
    Color? overlay,
    Color? scrim,
    Color? gradientStart,
    Color? gradientEnd,
    Color? shimmerBase,
    Color? shimmerHighlight,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    List<Color>? chartColors,
  }) => AppColorsExt(
    primary: primary ?? this.primary,
    primaryInk: primaryInk ?? this.primaryInk,
    onGradient: onGradient ?? this.onGradient,
    onPrimary: onPrimary ?? this.onPrimary,
    primaryLight: primaryLight ?? this.primaryLight,
    primaryDark: primaryDark ?? this.primaryDark,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceVariant: surfaceVariant ?? this.surfaceVariant,
    card: card ?? this.card,
    dialog: dialog ?? this.dialog,
    bottomSheet: bottomSheet ?? this.bottomSheet,
    appBar: appBar ?? this.appBar,
    bottomNav: bottomNav ?? this.bottomNav,
    drawer: drawer ?? this.drawer,
    inputFill: inputFill ?? this.inputFill,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    text: text ?? this.text,
    textSecondary: textSecondary ?? this.textSecondary,
    textDisabled: textDisabled ?? this.textDisabled,
    textOnPrimary: textOnPrimary ?? this.textOnPrimary,
    icon: icon ?? this.icon,
    iconSecondary: iconSecondary ?? this.iconSecondary,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    outline: outline ?? this.outline,
    shadow: shadow ?? this.shadow,
    overlay: overlay ?? this.overlay,
    scrim: scrim ?? this.scrim,
    gradientStart: gradientStart ?? this.gradientStart,
    gradientEnd: gradientEnd ?? this.gradientEnd,
    shimmerBase: shimmerBase ?? this.shimmerBase,
    shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    info: info ?? this.info,
    chartColors: chartColors ?? this.chartColors,
  );
  @override
  AppColorsExt lerp(covariant AppColorsExt? other, double t) {
    if (other == null) return this;
    return AppColorsExt(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryInk: Color.lerp(primaryInk, other.primaryInk, t)!,
      onGradient: Color.lerp(onGradient, other.onGradient, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      card: Color.lerp(card, other.card, t)!,
      dialog: Color.lerp(dialog, other.dialog, t)!,
      bottomSheet: Color.lerp(bottomSheet, other.bottomSheet, t)!,
      appBar: Color.lerp(appBar, other.appBar, t)!,
      bottomNav: Color.lerp(bottomNav, other.bottomNav, t)!,
      drawer: Color.lerp(drawer, other.drawer, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      text: Color.lerp(text, other.text, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      iconSecondary: Color.lerp(iconSecondary, other.iconSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      scrim: Color.lerp(scrim, other.scrim, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      shimmerBase: Color.lerp(shimmerBase, other.shimmerBase, t)!,
      shimmerHighlight: Color.lerp(
        shimmerHighlight,
        other.shimmerHighlight,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      chartColors: List.generate(
        chartColors.length,
        (i) => Color.lerp(
          chartColors[i],
          other.chartColors[i % other.chartColors.length],
          t,
        )!,
      ),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>()!;
}
