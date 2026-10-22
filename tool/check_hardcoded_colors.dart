import 'dart:io';

// Run from the repository root: dart run tool/check_hardcoded_colors.dart
// Theme construction and colour-picker internals are the only source exceptions.
void main() {
  final patterns = <String, RegExp>{
    'hex constructor': RegExp(r'Color\s*\(\s*0x'),
    'ARGB/RGBO constructor': RegExp(r'Color\.from(?:ARGB|RGBO)\s*\('),
    'Material constant': RegExp(r'\bColors\.(?!transparent\b)\w+'),
    'legacy AppColors': RegExp(r'\bAppColors\.'),
    'Material shade': RegExp(r'\.shade\d+|\bColors\.\w+\[\d+\]'),
    'runtime hex parser': RegExp(r'hexToColor|HexColor|fromHex'),
    'ARGB literal': RegExp(r'0x[0-9a-fA-F]{8}'),
  };
  final matches = <String>[];
  final approved = <String>[];
  for (final file in Directory('lib').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'))) {
    final path = file.path.replaceAll('\\', '/');
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      for (final pattern in patterns.entries) {
        if (!pattern.value.hasMatch(lines[i])) continue;
        final entry = '$path:${i + 1}: ${pattern.key}: ${lines[i].trim()}';
        if (path.startsWith('lib/theme/')) {
          approved.add('$entry — palette construction, presets, persistence bounds or transparent Material tint.');
        } else {
          matches.add(entry);
        }
      }
    }
  }
  final report = '# Hardcoded colour search\n\nUnjustified matches: ${matches.length}\n\n## Allowed theme infrastructure matches\n\n${approved.map((s) => '- $s').join('\n')}\n\n## Unjustified matches\n\n${matches.isEmpty ? 'None.' : matches.map((s) => '- $s').join('\n')}\n\nPatterns include multiline constructors (the constructor and ARGB literal are checked independently), ARGB/RGBO, Material constants/shades, legacy AppColors and runtime hex helpers. Transparent colours are allowed. Markdown examples and test fixtures are not executable app widgets.\n';
  File('reports/colors/REMAINING_MATCHES.md').writeAsStringSync(report);
  if (matches.isNotEmpty) {
    stderr.writeln(matches.join('\n'));
    exitCode = 1;
  } else {
    stdout.writeln('PASS: no hardcoded colours outside lib/theme/. ${approved.length} justified infrastructure matches recorded.');
  }
}
