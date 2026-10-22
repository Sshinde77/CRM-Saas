import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class Edit { Edit(this.start,this.end,this.text); final int start,end; final String text; }
class Migration extends RecursiveAstVisitor<void> {
  Migration(this.source);
  final String source;
  final edits=<Edit>[];
  bool dynamicNode(AstNode node) => node.toSource().contains('context.colors');
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if(node.keyword?.lexeme=='const' && dynamicNode(node)) edits.add(Edit(node.keyword!.offset,node.keyword!.end,''));
    super.visitInstanceCreationExpression(node);
  }
  @override
  void visitListLiteral(ListLiteral node) { if(node.constKeyword!=null&&dynamicNode(node)) edits.add(Edit(node.constKeyword!.offset,node.constKeyword!.end,'')); super.visitListLiteral(node); }
  @override
  void visitSetOrMapLiteral(SetOrMapLiteral node) { if(node.constKeyword!=null&&dynamicNode(node)) edits.add(Edit(node.constKeyword!.offset,node.constKeyword!.end,'')); super.visitSetOrMapLiteral(node); }
  @override
  void visitVariableDeclarationList(VariableDeclarationList node) {
    if (node.isConst && dynamicNode(node)) edits.add(Edit(node.keyword!.offset,node.keyword!.end,'final'));
    super.visitVariableDeclarationList(node);
  }
}
void main() {
  for(final f in Directory('lib').listSync(recursive:true).whereType<File>().where((f)=>f.path.endsWith('.dart')&&!f.path.contains('lib${Platform.pathSeparator}theme${Platform.pathSeparator}'))) {
    final s=f.readAsStringSync();
    final unit=parseString(content:s,throwIfDiagnostics:false).unit;
    final visitor=Migration(s);unit.accept(visitor);
    var result=s;
    for(final e in visitor.edits..sort((a,b)=>b.start.compareTo(a.start))) { result=result.replaceRange(e.start,e.end,e.text); }
    f.writeAsStringSync(result);
  }
}
