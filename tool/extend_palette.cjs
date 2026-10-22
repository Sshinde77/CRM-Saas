const fs=require('fs');
let s=fs.readFileSync('tool/build_theme.cjs','utf8');
s=s.slice(0,s.indexOf('let pub='));
s=s.replace("'primary onPrimary ","'primary primaryInk onGradient onPrimary ");
s=s.replace("primary:'primary',","primary:'primary',primaryInk:'tone(dark ? .74 : .28, .62)',onGradient:'tone(.99, .1)',");
fs.writeFileSync('tool/build_theme.cjs',s);
