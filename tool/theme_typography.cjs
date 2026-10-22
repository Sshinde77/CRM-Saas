const fs=require('fs');
let p='lib/core/theme/app_text_styles.dart',s=fs.readFileSync(p,'utf8');
s=s.replace("import '../../constants/app_colors.dart';","import '../../theme/app_colors_ext.dart';");
s=s.replace(/static const TextStyle (\w+) =/g,'static TextStyle $1(AppColorsExt colors) =>').replace(/AppColors.textPrimary/g,'colors.text').replace(/AppColors.textMuted/g,'colors.textSecondary').replace(/AppColors.textSecondary/g,'colors.textSecondary');
const names=[...s.matchAll(/static TextStyle (\w+)\(/g)].map(m=>m[1]);
s=s.replace('static const TextTheme textTheme =','static TextTheme textTheme(AppColorsExt colors) =>');
s=s.replace(/(: )(\w+)(,)/g,(m,a,b,c)=>names.includes(b)?a+b+'(colors)'+c:m);
fs.writeFileSync(p,s);
