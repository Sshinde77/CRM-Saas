import 'package:flutter/material.dart';

class AppearanceButton extends StatelessWidget {
  const AppearanceButton({super.key});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.palette_outlined),
    title: const Text('Appearance'),
    onTap: () {
      final navigator = Navigator.of(context);
      if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) navigator.pop();
      navigator.pushNamed('/appearance');
    },
  );
}
