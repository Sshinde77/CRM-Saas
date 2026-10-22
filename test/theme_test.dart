import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crm_saas/theme/app_colors_ext.dart';
import 'package:crm_saas/theme/app_theme.dart';
import 'package:crm_saas/theme/theme_controller.dart';
import 'package:crm_saas/widgets/soft_action_button.dart';
import 'package:crm_saas/screens/theme_settings_page.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('all requested primaries keep readable surfaces in both modes', () {
    for (final primary in AppColorsExt.presets) {
      for (final dark in [false, true]) {
        final c = AppColorsExt.fromPrimary(primary, dark: dark);
        for (final surface in [
          c.background,
          c.surface,
          c.surfaceVariant,
          c.inputFill,
        ]) {
          expect(contrast(c.text, surface), greaterThanOrEqualTo(4.5));
          expect(contrast(c.primaryInk, surface), greaterThanOrEqualTo(4.5));
        }
        expect(contrast(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
        expect(
          contrast(c.onGradient, c.gradientStart),
          greaterThanOrEqualTo(4.5),
        );
        final theme = AppTheme.build(primary, dark: dark);
        expect(theme.extension<AppColorsExt>()!.primary, primary);
        expect(theme.colorScheme.surfaceTint, Colors.transparent);
        expect(c.chartColors.toSet().length, 6);
      }
    }
  });
  test('copyWith and lerp preserve and interpolate every role', () {
    final a = AppColorsExt.fromPrimary(AppColorsExt.presets[0], dark: false);
    final b = AppColorsExt.fromPrimary(AppColorsExt.presets[1], dark: true);
    expect(a.copyWith().roles, a.roles);
    expect(a.copyWith(primary: b.primary).primary, b.primary);
    for (final role in a.roles.keys) {
      expect(
        a.lerp(b, .5).roles[role],
        Color.lerp(a.roles[role], b.roles[role], .5),
      );
    }
  });
  test(
    'selection persists, reloads, and resets; corrupt values fall back',
    () async {
      SharedPreferences.setMockInitialValues({});
      final c = ThemeController();
      await c.load();
      expect(c.primary, AppColorsExt.defaultPrimary);
      c.setPrimary(AppColorsExt.presets[1]);
      c.setDark(true);
      await c.flush();
      final restart = ThemeController();
      await restart.load();
      expect(restart.primary, c.primary);
      expect(restart.isDark, true);
      restart.reset();
      await restart.flush();
      final resetRestart = ThemeController();
      await resetRestart.load();
      expect(resetRestart.primary, AppColorsExt.defaultPrimary);
      expect(resetRestart.isDark, false);
      c.dispose();
      restart.dispose();
      resetRestart.dispose();
      SharedPreferences.setMockInitialValues({
        'theme_primary': 'invalid',
        'theme_dark': 27,
      });
      final corrupt = ThemeController();
      await corrupt.load();
      expect(corrupt.primary, AppColorsExt.defaultPrimary);
      expect(corrupt.isDark, false);
      corrupt.dispose();
    },
  );
  testWidgets(
    'mounted shared widgets retheme immediately for all presets and modes',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final c = ThemeController();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: c,
          child: Consumer<ThemeController>(
            builder: (_, controller, _) => MaterialApp(
              theme: controller.theme,
              home: Scaffold(
                body: SoftActionButton(
                  label: 'Test',
                  icon: Icons.palette,
                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
      );
      for (final primary in AppColorsExt.presets) {
        for (final dark in [false, true]) {
          c.setPrimary(primary);
          c.setDark(dark);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
          final context = tester.element(find.byType(SoftActionButton));
          expect(context.colors.primary, primary);
          expect(
            Theme.of(context).brightness,
            dark ? Brightness.dark : Brightness.light,
          );
          expect(tester.takeException(), isNull);
        }
      }
      await c.flush();
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
    },
  );
  testWidgets(
    'appearance controls and live preview render for every preset and mode',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final c = ThemeController();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: c,
          child: Consumer<ThemeController>(
            builder: (_, controller, _) => MaterialApp(
              theme: controller.theme,
              home: const ThemeSettingsPage(),
            ),
          ),
        ),
      );
      for (final primary in AppColorsExt.presets) {
        for (final dark in [false, true]) {
          c.setPrimary(primary);
          c.setDark(dark);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
          expect(find.text('Appearance'), findsOneWidget);
          expect(find.text('Dark mode'), findsWidgets);
          expect(tester.takeException(), isNull);
        }
      }
      await c.flush();
      await tester.pumpWidget(const SizedBox.shrink());
      c.dispose();
    },
  );
}
