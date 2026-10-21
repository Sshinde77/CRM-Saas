# TASK: Add a dynamic "single primary color" theme system to this Flutter app

## Goal
The user picks ONE primary color in a settings screen. The ENTIRE app re-themes instantly and the choice persists across restarts. Every other color (backgrounds, surfaces, cards, gradients, borders, shadows, icons, text, chips, dialogs, etc.) must be derived automatically from that primary color.

CRITICAL REQUIREMENT: No visible color may remain hardcoded, including colors defined manually in individual widgets, not just those in `AppColors`. If a color is not in the constants file, it still has to change. Treat any leftover hardcoded color as a bug.

## Inputs you must use
- `lib/constants/app_colors.dart` (existing `AppColors` constants and `primaryGradient`)
- `reports/colors/COLOURS_IN_CONSTANTS.md`
- `reports/colors/COLOURS_OUTSIDE_CONSTANTS.md` (every `Colors.*`, `Color(0x...)`, local `const Color` outside AppColors, with file and line)
- `reports/colors/ALL_COLOURS.md` and `platform_colors` section (web/native colors)
- The CSV files in `reports/colors/` if you need exact locations

Do NOT trust the reports as complete. They may miss `Color.fromRGBO`, `Color.fromARGB`, `Colors.xxx.shadeNNN`, `Colors.xxx[NNN]`, `.withOpacity()`, `.withAlpha()`, `.withValues()`, hex strings parsed at runtime, colors inside `CustomPainter`, `BoxShadow`, `Gradient`, `ShaderMask`, `TextStyle`, `Icon`, `Divider`, `Chip`, `SnackBar`, `ThemeData` copies, and third-party widget parameters. Re-scan the code yourself (see Phase 6).

## Phase 1: Dependencies
Add to `pubspec.yaml` (use latest compatible versions) and run `flutter pub get`:
- `provider`
- `shared_preferences`
- `flutter_colorpicker`
Do not add anything else unless required. If the app already uses Riverpod/Bloc/GetX, use that instead of provider and keep the same architecture.

## Phase 2: Semantic color roles (`lib/theme/app_colors_ext.dart`)
Create `class AppColorsExt extends ThemeExtension<AppColorsExt>` with these fields at minimum. Add more if the audit shows the app needs them:

- `primary`, `onPrimary`
- `primaryLight`, `primaryDark` (lighter and darker shades of primary)
- `background` (scaffold)
- `surface` (cards, sheets)
- `surfaceVariant` (nested cards, inputs, chips)
- `card`, `dialog`, `bottomSheet`, `appBar`, `bottomNav`, `drawer`, `inputFill`
- `accent`, `onAccent`
- `text`, `textSecondary`, `textDisabled`, `textOnPrimary`
- `icon`, `iconSecondary`
- `border`, `divider`, `outline`
- `shadow`
- `overlay`, `scrim`
- `gradientStart`, `gradientEnd` plus a `LinearGradient get primaryGradient`
- `shimmerBase`, `shimmerHighlight` (if the app uses shimmers)
- `chartColors` (List<Color>, derived from primary hue shifts, only if charts exist)

Fixed-meaning colors that do NOT derive from primary (keep constant, but inside the extension so they are accessed consistently): `success`, `warning`, `error`, `info`. Optionally slightly adapt their lightness for dark or light mode, but not their hue.

Implement:
- `factory AppColorsExt.fromPrimary(Color primary, {required bool dark})` using `HSLColor`. Keep the same hue as primary for neutrals (backgrounds, surfaces, borders), vary lightness and saturation. Example rules for dark mode: background L≈0.07-0.09, surface L≈0.13-0.15, surfaceVariant L≈0.18, border L≈0.25, gradientStart L≈0.16, gradientEnd L≈0.07. For light mode: background L≈0.97, surface L≈1.0, surfaceVariant L≈0.93, border L≈0.85. Accent = hue shifted about +30° to +40°, saturation ≥ 0.7, lightness ≈ 0.6. Tune these so the DEFAULT primary (the current app navy from `AppColors`) reproduces the app's current look as closely as possible.
- Contrast safety: compute `onPrimary` and `textOnPrimary` from `primary.computeLuminance()` (white if dark primary, near-black if light primary). Clamp primary's usable lightness for derived surfaces so text always stays readable (aim for WCAG contrast ≥ 4.5 for `text` on `background` and `surface`). If the picked primary is almost white or almost black, adjust derived surfaces rather than letting contrast break.
- `copyWith` (fully implemented, not a stub) and `lerp` (interpolate every field with `Color.lerp`, so theme changes animate).
- `extension AppColorsContext on BuildContext { AppColorsExt get colors => Theme.of(this).extension<AppColorsExt>()!; }`

## Phase 3: ThemeData builder (`lib/theme/app_theme.dart`)
`static ThemeData build(Color primary, {required bool dark})` must build the AppColorsExt and then configure ThemeData so that built-in widgets pick up the colors automatically. Set ALL of these explicitly from the extension, not left to Material defaults:
- `colorScheme` (use `ColorScheme.fromSeed` then `.copyWith` to override primary, onPrimary, secondary, surface, onSurface, background, error, outline, shadow, scrim, surfaceTint: Colors.transparent to prevent Material 3 tinting from changing card colors)
- `scaffoldBackgroundColor`, `canvasColor`, `cardColor`, `dividerColor`, `shadowColor`, `splashColor`, `highlightColor`, `hoverColor`, `disabledColor`, `hintColor`
- `textTheme` and `primaryTextTheme` (apply `.apply(bodyColor: text, displayColor: text)`)
- `iconTheme`, `primaryIconTheme`
- `appBarTheme`, `bottomNavigationBarTheme`, `navigationBarTheme`, `navigationRailTheme`, `tabBarTheme`, `drawerTheme`
- `cardTheme`, `dialogTheme`, `bottomSheetTheme`, `popupMenuTheme`, `snackBarTheme`, `tooltipTheme`, `bannerTheme`
- `elevatedButtonTheme`, `filledButtonTheme`, `outlinedButtonTheme`, `textButtonTheme`, `iconButtonTheme`, `floatingActionButtonTheme`, `segmentedButtonTheme`, `toggleButtonsTheme`
- `inputDecorationTheme` (fill, border, enabledBorder, focusedBorder, hint, label, prefix and suffix icon colors, error colors)
- `checkboxTheme`, `radioTheme`, `switchTheme`, `sliderTheme`, `progressIndicatorTheme`, `chipTheme`, `listTileTheme`, `expansionTileTheme`, `dividerTheme`, `datePickerTheme`, `timePickerTheme`, `dropdownMenuTheme`, `menuTheme`, `searchBarTheme`, `badgeTheme`, `textSelectionTheme`
- `extensions: [appColorsExt]`
Also set `SystemChrome` / `AnnotatedRegion<SystemUiOverlayStyle>` so the status bar and navigation bar colors and icon brightness follow the theme (wrap the app's root, rebuild when theme changes).

## Phase 4: State, persistence and wiring
Create `ThemeController extends ChangeNotifier`:
- Stores `primary` (Color) and `isDark` (bool). Default primary = the current brand color from `AppColors`. Default dark = whatever the app currently uses.
- `load()` reads from `SharedPreferences` (key `theme_primary` as int ARGB32, `theme_dark` as bool). Handle missing or corrupt values by falling back to defaults.
- `setPrimary(Color)`, `setDark(bool)`, `reset()`. Each calls `notifyListeners()` first and persists after.
- `ThemeData get theme`.
In `main()`: `WidgetsFlutterBinding.ensureInitialized()`, `await controller.load()`, then run the app with the provider at the very root, above `MaterialApp`. `MaterialApp` must use `theme: controller.theme` (and if `darkTheme` or `themeMode` exist currently, remove or unify them so there is a single source of truth). Add `themeAnimationDuration` of ~300ms.
Make sure no part of the app caches ThemeData or colors in `initState`, a static field, or a top-level `final`. Everything must read from `context.colors` or `Theme.of(context)` inside `build`.

## Phase 5: Settings screen (`lib/screens/theme_settings_page.dart`)
- Dark mode switch.
- A row of preset swatches (include the current default navy, plus about 6 others) with a check on the selected one.
- A full `ColorPicker` (no alpha) with a hex input, calling `setPrimary`. Throttle or debounce persistence so dragging doesn't write to disk every frame (update UI immediately, persist after a short delay).
- "Reset to default" button.
- A live preview section showing a card, button, text field, chip, switch, and gradient banner using the current theme.
Add a navigation entry to it from the app's existing settings or profile screen.

## Phase 6: Migrate EVERY hardcoded color (most important phase)
Work through the code file by file. For each file:

1. Replace `AppColors.xxx` with the matching `context.colors.xxx` role. Map by meaning, not by hex value. Create a mapping table first (old constant, new role) and write it to `reports/colors/MIGRATION_MAP.md`.
2. Replace each entry listed in `COLOURS_OUTSIDE_CONSTANTS.md`:
   - `Colors.white` / `Colors.black` / `Colors.grey[...]` → choose by role: `context.colors.text`, `textSecondary`, `surface`, `border`, `icon`, `onPrimary`, etc.
   - `Colors.transparent` → keep as is.
   - `Color(0xFF...)`, `Color.fromARGB`, `Color.fromRGBO`, local `const Color` declarations → map to the nearest role; delete the local definition if it becomes unused.
   - `.withOpacity(x)` / `.withAlpha` / `.withValues(alpha:)` → apply them to the theme color (e.g. `context.colors.primary.withValues(alpha: 0.2)`). If the project's Flutter version is older and doesn't support `withValues`, use `withOpacity`.
3. Also fix colors NOT in the reports: BoxShadow, Border, BorderSide, Gradient (LinearGradient, RadialGradient, SweepGradient), ShaderMask, Icon, TextStyle, Divider, Card, Material, InkWell splash and highlight colors, Chip, Badge, SnackBar, Dialog, BottomSheet, Switch and Checkbox parts, Slider, ProgressIndicator, Hero and placeholder containers, shimmer, tab indicators, `ColorFiltered`, `Image.color`, `SvgPicture` `colorFilter` / `color`, Lottie color filters, `flutter_svg` hardcoded fills.
4. Places WITHOUT a BuildContext (the usual reason colors "don't change"):
   - `static const TextStyle` / `static const BoxDecoration` / top-level `const` decorations → convert to methods or getters that take `BuildContext` (or `AppColorsExt`), and update every call site.
   - `CustomPainter` → pass the colors in via the constructor from the widget's `build`, and make `shouldRepaint` return true when colors change.
   - Services, utils, helpers, enums or models that return colors (for example status to color) → make them return a semantic role or accept `AppColorsExt`, and resolve it at the widget level.
   - Widgets that capture colors in `initState`, `late final`, controllers, or `StatefulWidget` fields → read them in `build` or `didChangeDependencies` instead.
   - Packages with a color parameter (charts, calendars, carousels, loaders, toasts, etc.) → pass theme-derived colors, and ensure those widgets are rebuilt when the theme changes (use the primary color as part of a `ValueKey` if the package caches colors internally).
5. Remove `const` from any widget or constructor that now depends on a theme color. Fix all resulting analyzer errors.
6. Do not leave dead imports of `app_colors.dart`. After migration, delete `AppColors` entirely, or reduce it to only the truly fixed, non-theme colors, and say which remain and why.

Exceptions allowed to stay hardcoded (list each in `MIGRATION_MAP.md` with a reason):
- `Colors.transparent`
- Semantic fixed colors (error, success, warning, info), brand colors of third parties (e.g. Google, Facebook logos), and colors inside images or illustrations.
- Colors in native splash or launch assets (handle in Phase 7).

## Phase 7: Platform and web colors
Review the `platform_colors` list in the reports. For `web/index.html`, `manifest.json` (`theme_color`, `background_color`), Android `colors.xml` / `styles.xml` / launch background, and iOS `LaunchScreen`: these cannot change at runtime. Keep them matching the default primary and note this limitation. On web, optionally update `<meta name="theme-color">` at runtime when the theme changes.

## Phase 8: Verification (do not skip)
1. Run `flutter analyze` and fix all issues. Run `dart format`.
2. Run a repo-wide search and report every remaining match, with file and line, for each pattern:
   `Color\(0x`, `Color\.from(ARGB|RGBO)`, `Colors\.(?!transparent)`, `AppColors\.`, `\.shade[0-9]+`, `Colors\.[a-zA-Z]+\[[0-9]+\]`, `hexToColor|HexColor|fromHex`, and `0x[0-9A-Fa-f]{8}` inside widget files.
   Each remaining match must either be fixed or explicitly justified as an allowed exception. Aim for zero unjustified matches outside `lib/theme/`.
3. Add a lightweight test or script (`tool/check_hardcoded_colors.dart` or a shell script) that fails if hardcoded colors appear outside `lib/theme/` and the allowed-exceptions list, so future code doesn't reintroduce them.
4. Add a hidden or debug-only "Theme Debug" screen that lists every role in AppColorsExt as a labeled swatch, with its contrast ratio against `text` where relevant.
5. Manually verify with at least these primaries, in both dark and light mode: the default navy, a bright red `#E53935`, a green `#2E7D32`, a yellow `#FDD835`, near-white `#F5F5F5`, near-black `#101010`. Check every screen for unreadable text, invisible borders, cards that did not change, wrong icon colors, and gradients that did not change.
6. Confirm persistence: change color, fully restart the app, color is retained. Confirm reset works.

## Output expected from you
- A summary of files created and changed
- `reports/colors/MIGRATION_MAP.md` (old to new mapping and the list of justified exceptions)
- The output of the Phase 8 search, with remaining matches justified
- A list of anything you could not make dynamic and why
Do the work in small, compilable steps: theme system first (Phases 1-5), confirm the app runs, then migrate screens one folder at a time, running `flutter analyze` after each folder. Do not stop at "the major screens"; finish every file.