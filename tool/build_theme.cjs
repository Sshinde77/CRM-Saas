const fs = require('fs');
const fields = 'primary primaryInk onGradient onPrimary primaryLight primaryDark background surface surfaceVariant card dialog bottomSheet appBar bottomNav drawer inputFill accent onAccent text textSecondary textDisabled textOnPrimary icon iconSecondary border divider outline shadow overlay scrim gradientStart gradientEnd shimmerBase shimmerHighlight success warning error info'.split(' ');
const values = {primary:'primary',primaryInk:'tone(dark ? .74 : .28, .62)',onGradient:'tone(.99, .1)',onPrimary:'onPrimary', primaryLight:'tone(.65, .65)',primaryDark:'tone(.2, .65)',background:'tone(dark ? .08 : .975, .22)',surface:'tone(dark ? .14 : .995, .18)',surfaceVariant:'tone(dark ? .19 : .94, .25)',card:'tone(dark ? .14 : .995, .18)',dialog:'tone(dark ? .14 : .995, .18)',bottomSheet:'tone(dark ? .14 : .995, .18)',appBar:'primary', bottomNav:'tone(dark ? .12 : .98, .22)',drawer:'tone(dark ? .12 : .96, .25)',inputFill:'tone(dark ? .18 : .98, .2)',accent:'accent',onAccent:'foreground(accent)',text:'tone(dark ? .95 : .10, .22)',textSecondary:'tone(dark ? .76 : .34, .17)',textDisabled:'tone(dark ? .52 : .49, .12)',textOnPrimary:'onPrimary',icon:'tone(dark ? .9 : .19, .25)',iconSecondary:'tone(dark ? .72 : .37, .18)',border:'tone(dark ? .32 : .80, .20)',divider:'tone(dark ? .27 : .87, .2)',outline:'tone(dark ? .48 : .56, .18)',shadow:'tone(.035, .3).withValues(alpha: .18)',overlay:'tone(.07, .25).withValues(alpha: .12)',scrim:'tone(.03, .25).withValues(alpha: .6)',gradientStart:'tone(.20, .62)',gradientEnd:'tone(.095, .74)',shimmerBase:'tone(dark ? .19 : .9, .2)',shimmerHighlight:'tone(dark ? .28 : .98, .2)',success:'const Color(0xFF2E7D32)',warning:'const Color(0xFFAC6500)',error:'const Color(0xFFDC2626)',info:'const Color(0xFF1479E8)'};
fs.mkdirSync('lib/theme',{recursive:true});
fs.writeFileSync('lib/theme/app_colors_ext.dart',`import 'package:flutter/material.dart';

@immutable
class AppColorsExt extends ThemeExtension<AppColorsExt> {
  const AppColorsExt({${fields.map(f=>'required this.'+f).join(', ')}, required this.chartColors});
  ${fields.map(f=>'final Color '+f+';').join('\n  ')}
  final List<Color> chartColors;
  static const defaultPrimary = Color(0xFF0D1F42);
  static const presets = <Color>[defaultPrimary, Color(0xFFE53935), Color(0xFF2E7D32), Color(0xFF7E57C2), Color(0xFF00838F), Color(0xFFFDD835), Color(0xFFF5F5F5), Color(0xFF101010)];
  static Color foreground(Color color) => color.computeLuminance() > .179 ? const Color(0xFF080B10) : const Color(0xFFFFFFFF);
  factory AppColorsExt.fromPrimary(Color primary, {required bool dark}) {
    final hsl = HSLColor.fromColor(primary);
    Color tone(double lightness, double saturation) => HSLColor.fromAHSL(1, hsl.hue, saturation, lightness).toColor();
    final onPrimary = foreground(primary);
    final accent = HSLColor.fromAHSL(1, (hsl.hue + 35) % 360, .75, dark ? .64 : .40).toColor();
    return AppColorsExt(
      ${fields.map(f=>f+': '+values[f]).join(',\n      ')},
      chartColors: List.unmodifiable(List.generate(6, (i) => HSLColor.fromAHSL(1, (hsl.hue + i * 47) % 360, .65, dark ? .65 : .40).toColor())),
    );
  }
  LinearGradient get primaryGradient => LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [gradientStart, gradientEnd]);
  Map<String, Color> get roles => {${fields.map(f=>"'"+f+"': "+f).join(', ')}, for (var i = 0; i < chartColors.length; i++) 'chart$i': chartColors[i]};
  @override
  AppColorsExt copyWith({${fields.map(f=>'Color? '+f).join(', ')}, List<Color>? chartColors}) => AppColorsExt(${fields.map(f=>f+': '+f+' ?? this.'+f).join(', ')}, chartColors: chartColors ?? this.chartColors);
  @override
  AppColorsExt lerp(covariant AppColorsExt? other, double t) {
    if (other == null) return this;
    return AppColorsExt(${fields.map(f=>f+': Color.lerp('+f+', other.'+f+', t)!').join(', ')}, chartColors: List.generate(chartColors.length, (i) => Color.lerp(chartColors[i], other.chartColors[i % other.chartColors.length], t)!));
  }
}
extension AppColorsContext on BuildContext {
  AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>()!;
}
`);
