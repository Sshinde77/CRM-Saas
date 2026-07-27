import 'package:flutter/material.dart';

import 'providers/api_provider.dart';
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class CrmSaasApp extends StatefulWidget {
  const CrmSaasApp({super.key});

  @override
  State<CrmSaasApp> createState() => _CrmSaasAppState();
}

class _CrmSaasAppState extends State<CrmSaasApp> {
  late final ApiProvider _apiProvider;

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
    return ApiProviderScope(
      notifier: _apiProvider,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CRM SaaS',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        routes: AppRouter.routes,
      ),
    );
  }
}
