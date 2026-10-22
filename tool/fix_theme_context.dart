import 'dart:io';
import 'dart:convert';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class Edit {
  Edit(this.start, this.end, this.text);
  final int start, end;
  final String text;
}

class Fix extends RecursiveAstVisitor<void> {
  Fix(this.path, this.source, this.aliases);
  final String path, source;
  final Map<String, String> aliases;
  final edits = <Edit>[];
  final changes = <Map<String, dynamic>>[];
  bool state(ClassDeclaration n) =>
      (n.extendsClause?.superclass.toSource().startsWith('State<') ?? false);
  @override
  void visitSimpleIdentifier(SimpleIdentifier n) {
    final replacement = aliases[n.name];
    if (replacement != null &&
        !n.inDeclarationContext() &&
        n.parent is! Label &&
        n.parent is! PrefixedIdentifier &&
        n.parent is! PropertyAccess)
      edits.add(Edit(n.offset, n.end, replacement));
  }

  @override
  void visitFieldDeclaration(FieldDeclaration n) {
    if (!n.toSource().contains('context.colors')) {
      super.visitFieldDeclaration(n);
      return;
    }
    final cls = n.parent!.parent! as ClassDeclaration;
    if (n.fields.variables.length != 1)
      throw StateError('Review multi-field declaration');
    final v = n.fields.variables.single;
    if (v.initializer == null) return;
    final type = n.fields.type?.toSource() ?? 'dynamic', name = v.name.lexeme;
    final method = n.isStatic || !state(cls);
    final header = method
        ? '${n.isStatic ? 'static ' : ''}$type $name(BuildContext context)'
        : '$type get $name';
    edits.add(
      Edit(
        n.offset,
        n.end,
        '$header => ${source.substring(v.initializer!.offset, v.initializer!.end)};',
      ),
    );
    if (method)
      changes.add({
        'file': path,
        'class': cls.name.lexeme,
        'name': name,
        'kind': 'field',
      });
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration n) {
    if (n.parent is! CompilationUnit ||
        !n.functionExpression.body.toSource().contains('context.colors')) {
      super.visitFunctionDeclaration(n);
      return;
    }
    final p = n.functionExpression.parameters!;
    if (p.toSource().contains('BuildContext context')) return;
    edits.add(
      Edit(
        p.leftParenthesis.end,
        p.leftParenthesis.end,
        'BuildContext context${p.parameters.isNotEmpty ? ', ' : ''}',
      ),
    );
    changes.add({'file': path, 'name': n.name.lexeme, 'kind': 'function'});
  }

  @override
  void visitMethodDeclaration(MethodDeclaration n) {
    if (!RegExp(r'\bcontext\b').hasMatch(n.body.toSource())) {
      super.visitMethodDeclaration(n);
      return;
    }
    final cls = n.parent?.parent;
    if (n.isGetter && n.body.toSource().contains('context')) {
      final isState = cls is ClassDeclaration && state(cls) && !n.isStatic;
      if (!isState) {
        var replacement = source
            .substring(n.offset, n.end)
            .replaceFirst(RegExp(r'\bget\s+'), '');
        replacement = replacement.replaceFirst(
          n.name.lexeme,
          '${n.name.lexeme}(BuildContext context)',
        );
        edits.add(Edit(n.offset, n.end, replacement));
        changes.add({'file': path, 'name': n.name.lexeme, 'kind': 'field'});
        return;
      }
    }
    if (cls is! ClassDeclaration ||
        (state(cls) && !n.isStatic) ||
        cls.extendsClause?.superclass.toSource() == 'CustomPainter') {
      super.visitMethodDeclaration(n);
      return;
    }
    final p = n.parameters;
    if (p == null || p.toSource().contains('BuildContext context')) return;
    edits.add(
      Edit(
        p.leftParenthesis.end,
        p.leftParenthesis.end,
        'BuildContext context${p.parameters.isNotEmpty ? ', ' : ''}',
      ),
    );
    changes.add({
      'file': path,
      'class': cls.name.lexeme,
      'name': n.name.lexeme,
      'kind': 'function',
    });
  }
}

class References extends RecursiveAstVisitor<void> {
  References(this.changes, this.path);
  final List<dynamic> changes;
  final String path;
  final edits = <Edit>[];
  @override
  void visitMethodInvocation(MethodInvocation n) {
    if (changes.any(
      (c) =>
          c['kind'] == 'function' &&
          c['name'] == n.methodName.name &&
          (c['file'] == path || !c['name'].startsWith('_')),
    )) {
      final p = n.argumentList;
      if (p.arguments.isEmpty || p.arguments.first.toSource() != 'context')
        edits.add(
          Edit(
            p.leftParenthesis.end,
            p.leftParenthesis.end,
            'context${p.arguments.isNotEmpty ? ', ' : ''}',
          ),
        );
    }
    super.visitMethodInvocation(n);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier n) {
    if (n.inDeclarationContext() || n.parent is Label) return;
    if (changes.any(
      (c) => c['kind'] == 'field' && c['name'] == n.name && c['file'] == path,
    )) {
      if (n.parent is MethodInvocation) return;
      edits.add(Edit(n.end, n.end, '(context)'));
    }
  }
}

String apply(String s, List<Edit> edits) {
  edits.sort((a, b) => b.start.compareTo(a.start));
  var previous = s.length + 1;
  for (final e in edits) {
    if (e.end > previous) throw StateError('Overlapping changes');
    s = s.replaceRange(e.start, e.end, e.text);
    previous = e.start;
  }
  return s;
}

class ConstFix extends RecursiveAstVisitor<void> {
  final edits = <Edit>[];
  bool dynamicNode(AstNode n) =>
      n.toSource().contains('context.colors') ||
      n.toSource().contains('(context)');
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression n) {
    if (n.keyword?.lexeme == 'const' && dynamicNode(n))
      edits.add(Edit(n.keyword!.offset, n.keyword!.end, ''));
    super.visitInstanceCreationExpression(n);
  }

  @override
  void visitListLiteral(ListLiteral n) {
    if (n.constKeyword != null && dynamicNode(n))
      edits.add(Edit(n.constKeyword!.offset, n.constKeyword!.end, ''));
    super.visitListLiteral(n);
  }

  @override
  void visitSetOrMapLiteral(SetOrMapLiteral n) {
    if (n.constKeyword != null && dynamicNode(n))
      edits.add(Edit(n.constKeyword!.offset, n.constKeyword!.end, ''));
    super.visitSetOrMapLiteral(n);
  }

  @override
  void visitVariableDeclarationList(VariableDeclarationList n) {
    if (n.isConst && dynamicNode(n))
      edits.add(Edit(n.keyword!.offset, n.keyword!.end, 'final'));
    super.visitVariableDeclarationList(n);
  }
}

void main(List<String> args) {
  final write = args.contains('--write');
  final paths = args.where((s) => !s.startsWith('--')).toList();
  if (paths.isEmpty)
    throw ArgumentError('Pass explicit Dart file paths. Dry run by default.');
  final mapping =
      (jsonDecode(
                File('reports/colors/migration_roles.json').readAsStringSync(),
              )
              as Map)
          .cast<String, String>();
  final metaFile = File('tool/theme_context_changes.json');
  final metadata = metaFile.existsSync()
      ? jsonDecode(metaFile.readAsStringSync()) as List
      : [];
  for (final path in paths) {
    if (!path.startsWith('lib/') || !path.endsWith('.dart'))
      throw ArgumentError('Expected lib Dart file');
    final file = File(path), original = file.readAsStringSync();
    var s = original;
    final old = Process.runSync('git', ['show', 'HEAD:$path']);
    final aliases = <String, String>{};
    if (old.exitCode == 0) {
      for (final m in RegExp(
        r'(?:static\s+)?const\s+(?:Color\s+)?(\w+)\s*=\s*AppColors\.(\w+);',
      ).allMatches(old.stdout as String)) {
        aliases[m[1]!] = 'context.colors.${mapping[m[2]]}';
      }
    }
    if (old.exitCode == 0) {
      for (final m in RegExp(
        r'(?:static\s+)?const\s+(?:Color\s+)?(\w+)\s*=\s*Color\(0x[\da-fA-F]+\);',
      ).allMatches(old.stdout as String)) {
        final name = m[1]!;
        final lower = name.toLowerCase();
        final role = lower.contains('red')
            ? 'error'
            : lower.contains('orange') || lower.contains('yellow')
            ? 'warning'
            : lower.contains('border')
            ? 'border'
            : lower.contains('muted')
            ? 'textSecondary'
            : lower.contains('pending')
            ? 'surfaceVariant'
            : lower.contains('violet') || lower.contains('purple')
            ? 'accent'
            : 'primary';
        aliases[name] = 'context.colors.$role';
      }
    }
    var v = Fix(path, s, aliases);
    parseString(content: s, throwIfDiagnostics: false).unit.accept(v);
    s = apply(s, v.edits);
    metadata.addAll(v.changes);
    final r = References(metadata, path);
    parseString(content: s, throwIfDiagnostics: false).unit.accept(r);
    s = apply(s, r.edits);
    final consts = ConstFix();
    parseString(content: s, throwIfDiagnostics: false).unit.accept(consts);
    s = apply(s, consts.edits);
    final errors = parseString(
      content: s,
      throwIfDiagnostics: false,
    ).errors.where((e) => e.errorCode.errorSeverity.name == 'ERROR');
    if (errors.isNotEmpty)
      throw StateError('$path has parse errors after edits: $errors');
    stdout.writeln(
      '$path: ${v.edits.length} declaration/alias edits, ${r.edits.length} reference edits${write ? ' (applied)' : ' (dry run)'}',
    );
    if (write) file.writeAsStringSync(s);
  }
  if (write) metaFile.writeAsStringSync(jsonEncode(metadata));
}
