const fs=require('fs');
let p='lib/screens/admin/dashboard/admin_dashboard_screen.dart',s=fs.readFileSync(p,'utf8');
for(const [name,field]of [['_BarChartPainter','points'],['_LineChartPainter','points'],['_SparklinePainter','values']]){
 s=s.replace('const '+name+'(this.'+field+');','final AppColorsExt colors;\n  const '+name+'(this.'+field+', this.colors);');
}
s=s.replace('_BarChartPainter(data.cashflow)','_BarChartPainter(data.cashflow, context.colors)').replace('_LineChartPainter(data.salesTrend)','_LineChartPainter(data.salesTrend, context.colors)').replace('data.salesTrend.map((e) => e.sales).toList(),','data.salesTrend.map((e) => e.sales).toList(), context.colors,');
const i=s.indexOf('class _BarChartPainter'); s=s.slice(0,i)+s.slice(i).replaceAll('context.colors','colors');
s=s.replace('oldDelegate.points != points;', 'oldDelegate.points != points || oldDelegate.colors != colors;').replace('oldDelegate.values != values;', 'oldDelegate.values != values || oldDelegate.colors != colors;');
// Use distinct, hue-derived chart series instead of identical brand colours.
s=s.replaceAll('Paint()..color = colors.primary,','Paint()..color = colors.chartColors[0],');
fs.writeFileSync(p,s);
p='lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart';s=fs.readFileSync(p,'utf8');
s=s.replace('painter: _GrowthChartPainter(\n','painter: _GrowthChartPainter(\n          colors: context.colors,\n');
s=s.replace('class _GrowthChartPainter extends CustomPainter {','class _GrowthChartPainter extends CustomPainter {\n  final AppColorsExt colors;');
s=s.replace('const _GrowthChartPainter({','const _GrowthChartPainter({\n    required this.colors,');
const start=s.indexOf('class _GrowthChartPainter'),end=s.indexOf('class _DonutPainter');
s=s.slice(0,start)+s.slice(start,end).replaceAll('context.colors','colors').replace('return oldDelegate.points != points;','return oldDelegate.points != points || oldDelegate.colors != colors || oldDelegate.lineColor != lineColor || oldDelegate.fillColor != fillColor || oldDelegate.axisColor != axisColor || oldDelegate.textColor != textColor;')+s.slice(end);
fs.writeFileSync(p,s);
