import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors_ext.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  ThemeController() {
    WidgetsBinding.instance.addObserver(this);
  }
  Color _primary = AppColorsExt.defaultPrimary;
  bool _isDark = false;
  Timer? _saveTimer;
  Future<void> _pending = Future.value();
  bool _disposed = false;
  String? persistenceError;
  Color get primary => _primary;
  bool get isDark => _isDark;
  ThemeData get theme => AppTheme.build(primary, dark: isDark);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.get('theme_primary');
      final mode = prefs.get('theme_dark');
      _primary = value is int && value >= 0 && value <= 0xffffffff
          ? Color(value).withValues(alpha: 1) : AppColorsExt.defaultPrimary;
      _isDark = mode is bool ? mode : false;
    } catch (error) {
      _primary = AppColorsExt.defaultPrimary;
      _isDark = false;
      persistenceError = error.toString();
    }
  }

  void setPrimary(Color value) {
    _primary = value.withValues(alpha: 1);
    _changed();
  }
  void setDark(bool value) { _isDark = value; _changed(); }
  void reset() { _primary = AppColorsExt.defaultPrimary; _isDark = false; _changed(); }
  void _changed() {
    notifyListeners();
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 350), () { unawaited(flush()); });
  }
  Future<void> flush() {
    _saveTimer?.cancel();
    final color = primary.toARGB32();
    final dark = isDark;
    _pending = _pending.then((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final savedColor = await prefs.setInt('theme_primary', color);
        final savedMode = await prefs.setBool('theme_dark', dark);
        persistenceError = savedColor && savedMode ? null : 'Could not save theme.';
      } catch (error) { persistenceError = error.toString(); }
      if (!_disposed) notifyListeners();
    });
    return _pending;
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) unawaited(flush());
  }
  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    super.dispose();
  }
}
