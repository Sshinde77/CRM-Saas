import 'package:crm_saas/theme/app_colors_ext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import '../theme/theme_controller.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ThemeController>();
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text('Dark mode'),
            value: controller.isDark,
            onChanged: controller.setDark,
          ),
          const SizedBox(height: 16),
          Text('Primary colour', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppColorsExt.presets
                .map(
                  (color) => Semantics(
                    label:
                        'Colour #${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    selected: controller.primary == color,
                    child: InkWell(
                      onTap: () => controller.setPrimary(color),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.outline),
                        ),
                        child: controller.primary == color
                            ? Icon(
                                Icons.check,
                                color: AppColorsExt.foreground(color),
                              )
                            : null,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: ColorPicker(
                pickerColor: controller.primary,
                onColorChanged: controller.setPrimary,
                enableAlpha: false,
                hexInputBar: true,
                displayThumbColor: true,
                labelTypes: const [ColorLabelType.rgb, ColorLabelType.hsl],
              ),
            ),
          ),
          if (controller.persistenceError != null)
            Text(
              'Unable to save appearance: ${controller.persistenceError}',
              style: TextStyle(color: c.error),
            ),
          OutlinedButton.icon(
            onPressed: controller.reset,
            icon: const Icon(Icons.restore),
            label: const Text('Reset to default'),
          ),
          const SizedBox(height: 24),
          Text('Live preview', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: c.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Your workspace, your colour',
              style: TextStyle(
                color: AppColorsExt.foreground(c.gradientStart),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preview card',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'Text, surfaces and controls update instantly.',
                    style: TextStyle(color: c.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(labelText: 'Example input'),
                  ),
                  const SizedBox(height: 12),
                  const Chip(label: Text('Example chip')),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Example button'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Example switch'),
                    value: controller.isDark,
                    onChanged: controller.setDark,
                  ),
                ],
              ),
            ),
          ),
          if (kDebugMode)
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ThemeDebugPage()),
              ),
              child: const Text('Theme Debug'),
            ),
        ],
      ),
    );
  }
}

class ThemeDebugPage extends StatelessWidget {
  const ThemeDebugPage({super.key});
  static double contrast(Color a, Color b) {
    final x = a.computeLuminance(), y = b.computeLuminance();
    return ((x > y ? x : y) + .05) / ((x > y ? y : x) + .05);
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Debug')),
      body: ListView(
        children: c.roles.entries
            .map(
              (entry) => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: entry.value,
                    border: Border.all(color: c.outline),
                  ),
                ),
                title: Text(entry.key),
                subtitle: Text(
                  '#${entry.value.toARGB32().toRadixString(16).toUpperCase()} � text contrast ${contrast(c.text, Color.alphaBlend(entry.value, c.surface)).toStringAsFixed(2)}:1',
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
