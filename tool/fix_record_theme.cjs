const fs=require('fs');
let p='lib/screens/admin/orders/admin_orders_screen.dart',s=fs.readFileSync(p,'utf8');
for(const name of ['paymentColor','paymentBackground','statusColor','statusBackground']){
 s=s.replace(new RegExp('^\\s*final Color '+name+';\\r?\\n','gm'),'').replace(new RegExp('^\\s*required this\\.'+name+',\\r?\\n','gm'),'').replace(new RegExp('^\\s*'+name+': [^\\n]+\\r?\\n','gm'),'');
 const fn=name.startsWith('payment')?'_paymentColors':'_statusColors',prop=name.endsWith('Background')?'background':'foreground',status=name.startsWith('payment')?'payment':'status';
 s=s.replace(new RegExp('record\\.'+name+'\\b','g'),fn+'(context, record.'+status+').'+prop);
}
s=s.replace(/^\s*final (?:statusColors|paymentColors) = [^\n]+\r?\n/gm,''); fs.writeFileSync(p,s);
p='lib/screens/admin/quotations/admin_quotations_screen.dart';s=fs.readFileSync(p,'utf8');
for(const name of ['statusColor','statusBackground']){
 s=s.replace(new RegExp('^\\s*final Color '+name+';\\r?\\n','gm'),'').replace(new RegExp('^\\s*required this\\.'+name+',\\r?\\n','gm'),'').replace(new RegExp('^\\s*'+name+': [^\\n]+\\r?\\n','gm'),'');
 s=s.replace(new RegExp('record\\.'+name+'\\b','g'),(name==='statusColor'?'_quotationStatusColor':'_quotationStatusBackground')+'(context, record.status)');
}
s=s.replace('List<_QuotationRecord> get _quotations => [','List<_QuotationRecord> _quotations = [');
s=s.replace('Color iconColor = context.colors.text,','Color? iconColor,').replace('Icon(icon, size: 15, color: iconColor)','Icon(icon, size: 15, color: iconColor ?? context.colors.icon)');fs.writeFileSync(p,s);
p='lib/screens/admin/quotations/quotation_detail_screen.dart';s=fs.readFileSync(p,'utf8').replace('Color get statusColor => _statusColor(context, status);','Color statusColor(BuildContext context) => _statusColor(context, status);').replace('quotation.statusColor,','quotation.statusColor(context),');fs.writeFileSync(p,s);
p='lib/screens/admin/settings/company_settings_screen.dart';s=fs.readFileSync(p,'utf8').replace('..._sections.map','..._sections(context).map');fs.writeFileSync(p,s);
