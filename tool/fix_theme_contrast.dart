import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class ContrastFix extends RecursiveAstVisitor<void> {
  final edits = <(int, int, String)>[];
  @override
  void visitNamedExpression(NamedExpression node) {
    final name = node.name.label.name;
    final owner = node.parent?.parent;
    final type = owner is InstanceCreationExpression
        ? owner.constructorName.type.toSource()
        : '';
    final foreground =
        [
          'foregroundColor',
          'iconColor',
          'textColor',
          'labelColor',
          'unselectedLabelColor',
        ].contains(name) ||
        name == 'color' &&
            ['TextStyle', 'Icon', 'IconThemeData'].contains(type);
    final value = node.expression.toSource();
    var replacement = value;
    if (foreground)
      replacement = replacement.replaceAll(
        RegExp(r'context\.colors\.primary\b'),
        'context.colors.primaryInk',
      );
    if (['backgroundColor', 'fillColor'].contains(name) ||
        name == 'color' &&
            [
              'BoxDecoration',
              'Container',
              'Material',
              'ColoredBox',
              'Card',
            ].contains(type)) {
      replacement = replacement.replaceAll(
        'context.colors.onPrimary',
        'context.colors.surface',
      );
    }
    if (name == 'color' && type == 'BorderSide')
      replacement = replacement.replaceAll(
        'context.colors.onPrimary',
        'context.colors.border',
      );
    if (foreground || name == 'color' && ['TextStyle', 'Icon'].contains(type)) {
      AstNode? parent = node.parent;
      while (parent != null) {
        if (parent is InstanceCreationExpression &&
            parent.constructorName.type.toSource() == 'Container') {
          final decorations = parent.argumentList.arguments
              .whereType<NamedExpression>()
              .where((a) => a.name.label.name == 'decoration')
              .map((a) => a.expression.toSource())
              .join();
          if (decorations.contains('Gradient'))
            replacement = replacement.replaceAll(
              'context.colors.onPrimary',
              'context.colors.onGradient',
            );
          if (decorations.isNotEmpty) break;
        }
        parent = parent.parent;
      }
    }
    if (replacement != value)
      edits.add((node.expression.offset, node.expression.end, replacement));
    super.visitNamedExpression(node);
  }
}

void main(List<String> paths) {
  for (final path in paths) {
    if (!path.startsWith('lib/') || !path.endsWith('.dart'))
      throw ArgumentError(path);
    final file = File(path);
    var source = file.readAsStringSync();
    final visitor = ContrastFix();
    parseString(
      content: source,
      throwIfDiagnostics: false,
    ).unit.accept(visitor);
    for (final (start, end, replacement)
        in visitor.edits..sort((a, b) => b.$1.compareTo(a.$1))) {
      source = source.replaceRange(start, end, replacement);
    }
    if (parseString(
      content: source,
      throwIfDiagnostics: false,
    ).errors.isNotEmpty)
      throw StateError('Invalid Dart: $path');
    if (visitor.edits.isNotEmpty) file.writeAsStringSync(source);
    stdout.writeln('$path: ${visitor.edits.length} foreground contrast fixes');
  }
}
