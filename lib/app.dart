import 'package:flutter/material.dart';

import 'routes/app_router.dart';
import 'theme/app_theme.dart';

class CrmSaasApp extends StatelessWidget {
  const CrmSaasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRM SaaS',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: AppRouter.routes,
    );
  }
}
