const fs=require('fs'),path=require('path');
const walk=d=>fs.readdirSync(d,{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(path.join(d,e.name)):[path.join(d,e.name)]);
let files=walk('lib').filter(p=>p.endsWith('.dart')&&!p.startsWith('lib'+path.sep+'theme')&&!p.endsWith('app_colors.dart'));
const old=fs.readFileSync('lib/constants/app_colors.dart','utf8');
const names=[...old.matchAll(/static const (?:Color|LinearGradient) (\w+)/g)].map(x=>x[1]);
const exact={primary:'primary',secondary:'primaryDark',primary900:'gradientStart',primary950:'gradientEnd',adminSidebarBg:'drawer',activeMenuBg:'surfaceVariant',primaryGradient:'primaryGradient',background:'background',surface:'surface',surfaceSoft:'surfaceVariant',surfaceOverlay:'surfaceVariant',accentGrey:'textSecondary',borderLight:'divider',border:'border',borderStrong:'outline',textPrimary:'text',textSecondary:'textSecondary',textMuted:'textSecondary',textLightMuted:'textDisabled',statusActiveBg:'surfaceVariant',statusActiveText:'primary',statusActiveIcon:'primary',statusInactiveBg:'error.withValues(alpha: .12)',statusInactiveText:'error',statusInactiveBorder:'error.withValues(alpha: .3)',teal:'primary',green:'primary',purple:'accent',blue:'primary',amber:'warning',orange:'warning',red:'error'};
function role(n){if(exact[n])return exact[n];if(/Shadow/.test(n))return 'shadow';if(/HeroStart|HeaderStart|NavStart/.test(n))return 'gradientStart';if(/HeroEnd|HeaderEnd|HeaderMid|NavEnd/.test(n))return 'gradientEnd';if(/Background/.test(n))return 'background';if(/Ink|DashboardText/.test(n))return 'text';if(/Border/.test(n))return 'border';if(/Soft|Badge|Bg|Active/.test(n))return 'surfaceVariant';if(/Card/.test(n))return 'card';if(/Red/.test(n))return 'error';if(/Orange|Yellow|Pending/.test(n))return 'warning';if(/Violet/.test(n))return 'accent';if(/HeroIcon/.test(n))return 'primaryLight';return 'primary';}
const map=Object.fromEntries(names.map(n=>[n,role(n)]));
fs.writeFileSync('reports/colors/MIGRATION_MAP.md','# Theme colour migration\n\n| Old constant | Theme role |\n| --- | --- |\n'+names.map(n=>'| AppColors.'+n+' | context.colors.'+map[n]+' |').join('\n')+'\n\nAppColors is removed after migration. Status errors and warnings retain their meaning through the extension.\n');
let data=files.map(p=>({p,s:fs.readFileSync(p,'utf8')}));
// Inline the old static colour aliases at their use sites, including qualified uses.
let qualified=[];
for(const f of data){
 f.s=f.s.replace(/(?:static\s+)?const\s+(?:Color\s+)?(\w+)\s*=\s*(AppColors\.\w+|Color\(0x[\da-fA-F]+\)|Colors\.\w+|AppDrawer\.\w+);/g,(m,n,v,offset)=>{
  if(!/static/.test(m))return m;
  const classes=[...f.s.slice(0,offset).matchAll(/class (\w+)/g)];
  qualified.push([classes.at(-1)?.[1]+'.'+n,v]);return m;
 });
}
for(let repeat=0;repeat<3;repeat++) for(const f of data) for(const [n,v] of qualified)f.s=f.s.replaceAll(n,v);
for(const f of data){
 let aliases=[];
 f.s=f.s.replace(/(?:static\s+)?const\s+(?:Color\s+)?(\w+)\s*=\s*(AppColors\.\w+|Color\(0x[\da-fA-F]+\)|Colors\.\w+);/g,(m,n,v)=>{aliases.push([n,v]);return '';});
 for(const [n,v]of aliases) f.s=f.s.replace(new RegExp('(?<![\\w.])'+n+'(?![\\w:]|\\s*:)','g'),v);
 f.s=f.s.replace(/AppColors\.(\w+)/g,(m,n)=>'context.colors.'+map[n]);
 // Fixed literals are assigned by usage and original lightness; saturated decorative colours follow primary/accent.
 f.s=f.s.replace(/(?:const\s+)?Color\(0x([\da-fA-F]{8})\)/g,(m,hex,offset)=>{
  const val=parseInt(hex,16),a=(val>>>24)/255,r=(val>>>16)&255,g=(val>>>8)&255,b=val&255,max=Math.max(r,g,b),min=Math.min(r,g,b),l=(max+min)/510,sat=max-min;
  const near=f.s.slice(Math.max(0,offset-130),offset).split('\n').slice(-3).join(' ');
  let role;
  if(a<1)role='shadow';
  else if(/border|Border|divider|axisColor/i.test(near))role='border';
  else if(/shadow/i.test(near))role='shadow';
  else if(l>.92)role=/backgroundColor/.test(near)?'background':'surface';
  else if(l>.78)role='surfaceVariant';
  else if(sat<65)role=l<.23?'text':'textSecondary';
  else if(r>g*1.65&&r>b*1.4&&l<.73)role='error';
  else if(r>g&&g>b*1.5&&l<.76)role='warning';
  else role='primary';
  return 'context.colors.'+role+(a<1?'.withValues(alpha: '+a.toFixed(4)+')':'');
 });
 f.s=f.s.replace(/Colors\.(?!transparent\b)(\w+)(?:\.shade(\d+)|\[(\d+)\])?/g,(m,n,shade,index,offset)=>{
  const near=f.s.slice(Math.max(0,offset-130),offset);
  let role=n.startsWith('white')?(/(?:backgroundColor|fillColor|color:\s*)\s*$/.test(near)&&/BoxDecoration|Container|Material|backgroundColor|fillColor/.test(near)?'surface':'onPrimary'):n.startsWith('black')?(/Shadow|shadow/.test(near)?'shadow':'text'):n==='grey'||n==='blueGrey'?'textSecondary':/red/.test(n)?'error':/orange|amber|yellow/.test(n)?'warning':'primary';
  const alpha=n.match(/(?:white|black)(\d+)$/)?.[1];
  return 'context.colors.'+role+(alpha?'.withValues(alpha: '+(Number(alpha)/100)+')':'');
 });
 if(/context.colors/.test(f.s)){
   f.s=f.s.replace(/import ['"][^'"]*constants\/app_colors.dart['"];\s*/g,'');
   if(!f.s.includes("import 'package:crm_saas/theme/app_colors_ext.dart';"))f.s="import 'package:crm_saas/theme/app_colors_ext.dart';\n"+f.s;
 }
 // Shared text styles now receive the palette explicitly.
 if(!f.p.endsWith('app_text_styles.dart'))f.s=f.s.replace(/AppTextStyles\.(\w+)(?!\w)/g,(m,n)=>['fontFamily','headingFontFamily'].includes(n)?m:m+'(context.colors)');
 fs.writeFileSync(f.p,f.s);
}
fs.writeFileSync('reports/colors/migration_roles.json',JSON.stringify(map,null,2));
