import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'providers/api_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import 'services/api_service.dart';
import 'screens/role_home_screen.dart';

class CrmSaasApp extends StatefulWidget {
  const CrmSaasApp({super.key});

  @override
  State<CrmSaasApp> createState() => _CrmSaasAppState();
}

class _CrmSaasAppState extends State<CrmSaasApp> {
  late final ApiProvider _apiProvider;

  static const double _baseMobileWidth = 375;
  static const double _minTextScale = 0.9;
  static const double _maxTextScale = 1.2;
  static const double _maxWidthTextScale = 1.15;

  @override
  void initState() {
    super.initState();
    _apiProvider = ApiProvider();
  }

  @override
  void dispose() {
    _apiProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasSession = (ApiService.accessToken ?? '').trim().isNotEmpty;
    final savedRole = ApiService.savedRole;

    return ApiProviderScope(
      notifier: _apiProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CRM SaaS',
        theme: AppTheme.lightTheme,
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final textScaler = _responsiveTextScaler(mediaQuery);

          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: textScaler),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: hasSession
            ? RoleHomeScreen.forRole(savedRole)
            : const LoginScreen(),
        routes: AppRouter.routes,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }

  TextScaler _responsiveTextScaler(MediaQueryData mediaQuery) {
    final width = mediaQuery.size.width;
    final widthScale = (width / _baseMobileWidth).clamp(
      _minTextScale,
      _maxWidthTextScale,
    ).toDouble();
    final platformScale = mediaQuery.textScaler.scale(14) / 14;
    final combinedScale = (platformScale * widthScale).clamp(
      _minTextScale,
      _maxTextScale,
    ).toDouble();

    return TextScaler.linear(combinedScale);
  }
}
