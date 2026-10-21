# App color audit

Source snapshot: 21 October 2026. Regenerate with `node tool/audit_colors.cjs C:/flutter`.

## Scope and counting

Scans every Dart file under `lib/`, plus explicit hex/resource colors in Android resources, iOS storyboards, web files and text assets. Excludes third-party source, tests, generated/build files, and colors inside bitmap images. Comments in Dart are masked. This is a static source inventory, not a list of pixels rendered at runtime: generated Material theme shades, inherited colors, remote data, gradients/blending and image pixels can introduce additional visible colors.

Hex values in the Dart tables use **#AARRGGBB** (alpha first). Opaque colors start with FF; 00 means fully transparent. For CSS, opaque #FF112548 corresponds to #112548. Opacity/color channel changes are listed separately; the direct-color table reports the base value, not the post-modification result.

`Colors.white`, `Colors.red`, etc. are Flutter constants, but they bypass the app’s shared `AppColors`. Local `const Color` declarations are constants too; the report distinguishes them from inline literals. Local declarations can also refer to AppColors, so local-definition totals overlap other tables. Occurrence counts count expressions, including multiple expressions on one line. AppColors reference totals are lexical references, not transitive uses through aliases. Local declaration detection is heuristic; class/scope references are not resolved.

## Summary

| Measure | Count |
| --- | ---: |
| dartFiles | 150 |
| constants | 85 |
| constantValues | 30 |
| centralReferences | 2938 |
| directOccurrences | 1697 |
| directFiles | 90 |
| directValues | 283 |
| matchingOccurrences | 664 |
| localDefinitions | 130 |
| modifiers | 507 |
| platformOccurrences | 5 |

## Downloads

- [All distinct explicit Dart color codes](all_color_values.csv): combined shared/direct palette, with RGB, alpha and matching constant names.
- [Shared constants](app_color_constants.csv): every AppColors Color member, resolved hex, alias, definition line and reference count.
- [All shared-constant usages](app_color_usages.csv): file, line and source context for every AppColors reference.
- [Colors bypassing AppColors](direct_colors.csv): every inline Color(...) and Colors.* occurrence outside the shared palette, with exact locations and matching shared constants.
- [Local definitions](local_color_definitions.csv): screen/widget definitions, including aliases to AppColors.
- [Opacity/channel modifications](color_modifiers.csv): explicit withValues/withOpacity/withAlpha and channel changes.
- [Dynamic/theme construction](dynamic_colors.csv): expressions whose exact result needs runtime/theme evaluation.
- [Platform/web colors](platform_colors.csv): explicit colors outside Dart.

## Shared AppColors palette

| Constant | ARGB | Declared expression | Definition | References | Files |
| --- | --- | --- | --- | ---: | ---: |
| primary | `#FF0D1F42` | `Color(0xFF0D1F42)` | [lib/constants/app_colors.dart:6](../../lib/constants/app_colors.dart#L6) | 287 | 52 |
| secondary | `#FF112548` | `Color(0xFF112548)` | [lib/constants/app_colors.dart:7](../../lib/constants/app_colors.dart#L7) | 54 | 22 |
| primary900 | `#FF112548` | `Color(0xFF112548)` | [lib/constants/app_colors.dart:8](../../lib/constants/app_colors.dart#L8) | 12 | 11 |
| primary950 | `#FF061431` | `Color(0xFF061431)` | [lib/constants/app_colors.dart:9](../../lib/constants/app_colors.dart#L9) | 0 | 0 |
| adminSidebarBg | `#FFF2F5FA` | `Color(0xFFF2F5FA)` | [lib/constants/app_colors.dart:10](../../lib/constants/app_colors.dart#L10) | 11 | 7 |
| activeMenuBg | `#FFDDE6F5` | `Color(0xFFDDE6F5)` | [lib/constants/app_colors.dart:11](../../lib/constants/app_colors.dart#L11) | 17 | 8 |
| background | `#FFFFFFFF` | `Color(0xFFFFFFFF)` | [lib/constants/app_colors.dart:19](../../lib/constants/app_colors.dart#L19) | 92 | 43 |
| surface | `#FFFFFFFF` | `Color(0xFFFFFFFF)` | [lib/constants/app_colors.dart:20](../../lib/constants/app_colors.dart#L20) | 154 | 35 |
| surfaceSoft | `#FFF2F5FA` | `adminSidebarBg` | [lib/constants/app_colors.dart:21](../../lib/constants/app_colors.dart#L21) | 85 | 37 |
| surfaceOverlay | `#FFFFFFF2` | `Color(0xFFFFFFF2)` | [lib/constants/app_colors.dart:22](../../lib/constants/app_colors.dart#L22) | 2 | 2 |
| accentGrey | `#FF6B7280` | `Color(0xFF6B7280)` | [lib/constants/app_colors.dart:23](../../lib/constants/app_colors.dart#L23) | 5 | 2 |
| borderLight | `#FFF1F2F4` | `Color(0xFFF1F2F4)` | [lib/constants/app_colors.dart:24](../../lib/constants/app_colors.dart#L24) | 33 | 15 |
| border | `#FFE4E6E9` | `Color(0xFFE4E6E9)` | [lib/constants/app_colors.dart:25](../../lib/constants/app_colors.dart#L25) | 132 | 23 |
| borderStrong | `#FFD1D5DB` | `Color(0xFFD1D5DB)` | [lib/constants/app_colors.dart:26](../../lib/constants/app_colors.dart#L26) | 75 | 12 |
| textPrimary | `#FF111827` | `Color(0xFF111827)` | [lib/constants/app_colors.dart:28](../../lib/constants/app_colors.dart#L28) | 308 | 47 |
| textSecondary | `#FF4B5563` | `Color(0xFF4B5563)` | [lib/constants/app_colors.dart:29](../../lib/constants/app_colors.dart#L29) | 239 | 56 |
| textMuted | `#FF6B7280` | `Color(0xFF6B7280)` | [lib/constants/app_colors.dart:30](../../lib/constants/app_colors.dart#L30) | 191 | 34 |
| textLightMuted | `#FF9AA1AC` | `Color(0xFF9AA1AC)` | [lib/constants/app_colors.dart:31](../../lib/constants/app_colors.dart#L31) | 63 | 26 |
| statusActiveBg | `#FFDDE6F5` | `activeMenuBg` | [lib/constants/app_colors.dart:33](../../lib/constants/app_colors.dart#L33) | 3 | 2 |
| statusActiveText | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:34](../../lib/constants/app_colors.dart#L34) | 10 | 4 |
| statusActiveIcon | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:35](../../lib/constants/app_colors.dart#L35) | 2 | 1 |
| statusInactiveBg | `#FFFEF2F2` | `Color(0xFFFEF2F2)` | [lib/constants/app_colors.dart:36](../../lib/constants/app_colors.dart#L36) | 3 | 3 |
| statusInactiveText | `#FFDC2626` | `Color(0xFFDC2626)` | [lib/constants/app_colors.dart:37](../../lib/constants/app_colors.dart#L37) | 13 | 7 |
| statusInactiveBorder | `#FFFECACA` | `Color(0xFFFECACA)` | [lib/constants/app_colors.dart:38](../../lib/constants/app_colors.dart#L38) | 3 | 3 |
| teal | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:40](../../lib/constants/app_colors.dart#L40) | 2 | 1 |
| green | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:41](../../lib/constants/app_colors.dart#L41) | 35 | 16 |
| purple | `#FF112548` | `primary900` | [lib/constants/app_colors.dart:42](../../lib/constants/app_colors.dart#L42) | 44 | 11 |
| blue | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:43](../../lib/constants/app_colors.dart#L43) | 31 | 13 |
| amber | `#FFF59E0B` | `Color(0xFFF59E0B)` | [lib/constants/app_colors.dart:44](../../lib/constants/app_colors.dart#L44) | 4 | 3 |
| orange | `#FFF97316` | `Color(0xFFF97316)` | [lib/constants/app_colors.dart:45](../../lib/constants/app_colors.dart#L45) | 13 | 5 |
| red | `#FFDC2626` | `statusInactiveText` | [lib/constants/app_colors.dart:46](../../lib/constants/app_colors.dart#L46) | 48 | 17 |
| deliveryBackground | `#FFF2F5FA` | `surfaceSoft` | [lib/constants/app_colors.dart:48](../../lib/constants/app_colors.dart#L48) | 25 | 21 |
| deliveryInk | `#FF111827` | `textPrimary` | [lib/constants/app_colors.dart:49](../../lib/constants/app_colors.dart#L49) | 174 | 26 |
| deliveryBlue | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:50](../../lib/constants/app_colors.dart#L50) | 41 | 15 |
| deliveryGreen | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:51](../../lib/constants/app_colors.dart#L51) | 240 | 31 |
| deliveryOrange | `#FFF97316` | `orange` | [lib/constants/app_colors.dart:52](../../lib/constants/app_colors.dart#L52) | 30 | 13 |
| deliveryRed | `#FFDC2626` | `statusInactiveText` | [lib/constants/app_colors.dart:53](../../lib/constants/app_colors.dart#L53) | 92 | 25 |
| deliveryViolet | `#FF112548` | `primary900` | [lib/constants/app_colors.dart:54](../../lib/constants/app_colors.dart#L54) | 11 | 5 |
| deliveryYellow | `#FFF59E0B` | `amber` | [lib/constants/app_colors.dart:55](../../lib/constants/app_colors.dart#L55) | 1 | 1 |
| deliveryHeroStart | `#FF112548` | `primary900` | [lib/constants/app_colors.dart:56](../../lib/constants/app_colors.dart#L56) | 3 | 1 |
| deliveryHeroEnd | `#FF061431` | `primary950` | [lib/constants/app_colors.dart:57](../../lib/constants/app_colors.dart#L57) | 3 | 1 |
| deliveryHeroShadow | `#FF061431` | `primary950` | [lib/constants/app_colors.dart:58](../../lib/constants/app_colors.dart#L58) | 10 | 7 |
| deliveryHeroIcon | `#FFDDE6F5` | `activeMenuBg` | [lib/constants/app_colors.dart:59](../../lib/constants/app_colors.dart#L59) | 1 | 1 |
| deliveryCardSoft | `#FFFBFCFF` | `Color(0xFFFBFCFF)` | [lib/constants/app_colors.dart:60](../../lib/constants/app_colors.dart#L60) | 24 | 7 |
| deliveryCardBorder | `#FFE9EDF5` | `Color(0xFFE9EDF5)` | [lib/constants/app_colors.dart:61](../../lib/constants/app_colors.dart#L61) | 25 | 8 |
| deliverySurfaceBorder | `#FFE7EBF3` | `Color(0xFFE7EBF3)` | [lib/constants/app_colors.dart:62](../../lib/constants/app_colors.dart#L62) | 114 | 25 |
| deliveryBlueSoft | `#FFF2F5FA` | `adminSidebarBg` | [lib/constants/app_colors.dart:63](../../lib/constants/app_colors.dart#L63) | 13 | 11 |
| deliveryGreenSoft | `#FFDDE6F5` | `activeMenuBg` | [lib/constants/app_colors.dart:64](../../lib/constants/app_colors.dart#L64) | 52 | 21 |
| deliveryOrangeSoft | `#FFFFFFF2` | `surfaceOverlay` | [lib/constants/app_colors.dart:65](../../lib/constants/app_colors.dart#L65) | 11 | 8 |
| deliveryVioletSoft | `#FFF2F5FA` | `adminSidebarBg` | [lib/constants/app_colors.dart:66](../../lib/constants/app_colors.dart#L66) | 2 | 2 |
| deliveryRedSoft | `#FFFEF2F2` | `statusInactiveBg` | [lib/constants/app_colors.dart:67](../../lib/constants/app_colors.dart#L67) | 10 | 8 |
| deliveryOrangeBadge | `#FFFFFFF2` | `surfaceOverlay` | [lib/constants/app_colors.dart:68](../../lib/constants/app_colors.dart#L68) | 1 | 1 |
| deliveryYellowSoft | `#FFFFFFF2` | `surfaceOverlay` | [lib/constants/app_colors.dart:69](../../lib/constants/app_colors.dart#L69) | 1 | 1 |
| deliveryVioletBadge | `#FFF2F5FA` | `adminSidebarBg` | [lib/constants/app_colors.dart:70](../../lib/constants/app_colors.dart#L70) | 1 | 1 |
| deliveryBlueBadge | `#FFF2F5FA` | `adminSidebarBg` | [lib/constants/app_colors.dart:71](../../lib/constants/app_colors.dart#L71) | 1 | 1 |
| deliveryDashboardHeaderStart | `#FF112548` | `primary900` | [lib/constants/app_colors.dart:72](../../lib/constants/app_colors.dart#L72) | 2 | 2 |
| deliveryDashboardHeaderMid | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:73](../../lib/constants/app_colors.dart#L73) | 2 | 2 |
| deliveryDashboardHeaderEnd | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:74](../../lib/constants/app_colors.dart#L74) | 13 | 5 |
| deliveryDashboardNavStart | `#FF112548` | `primary900` | [lib/constants/app_colors.dart:75](../../lib/constants/app_colors.dart#L75) | 2 | 2 |
| deliveryDashboardNavEnd | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:76](../../lib/constants/app_colors.dart#L76) | 2 | 2 |
| deliveryDashboardNavActive | `#FFDDE6F5` | `activeMenuBg` | [lib/constants/app_colors.dart:77](../../lib/constants/app_colors.dart#L77) | 2 | 2 |
| deliveryDashboardOnlineDot | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:78](../../lib/constants/app_colors.dart#L78) | 0 | 0 |
| deliveryDashboardText | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:79](../../lib/constants/app_colors.dart#L79) | 8 | 2 |
| deliveryKpiMintIcon | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:80](../../lib/constants/app_colors.dart#L80) | 3 | 3 |
| deliveryKpiMintBg | `#FFDDE6F5` | `activeMenuBg` | [lib/constants/app_colors.dart:81](../../lib/constants/app_colors.dart#L81) | 4 | 4 |
| deliveryKpiYellowIcon | `#FF8A8F00` | `Color(0xFF8A8F00)` | [lib/constants/app_colors.dart:82](../../lib/constants/app_colors.dart#L82) | 3 | 3 |
| deliveryKpiYellowBg | `#FFFFF3A8` | `Color(0xFFFFF3A8)` | [lib/constants/app_colors.dart:83](../../lib/constants/app_colors.dart#L83) | 4 | 4 |
| deliveryKpiGreenIcon | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:84](../../lib/constants/app_colors.dart#L84) | 1 | 1 |
| deliveryKpiGreenBg | `#FFDDE6F5` | `activeMenuBg` | [lib/constants/app_colors.dart:85](../../lib/constants/app_colors.dart#L85) | 4 | 3 |
| deliveryKpiAquaIcon | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:86](../../lib/constants/app_colors.dart#L86) | 3 | 3 |
| deliveryKpiAquaBg | `#FFDDE6F5` | `activeMenuBg` | [lib/constants/app_colors.dart:87](../../lib/constants/app_colors.dart#L87) | 4 | 4 |
| deliveryKpiRedIcon | `#FFE11D35` | `Color(0xFFE11D35)` | [lib/constants/app_colors.dart:88](../../lib/constants/app_colors.dart#L88) | 2 | 1 |
| deliveryKpiRedBg | `#FFFFE2E6` | `Color(0xFFFFE2E6)` | [lib/constants/app_colors.dart:89](../../lib/constants/app_colors.dart#L89) | 3 | 2 |
| deliveryProfileAvatarBg | `#FFDDE6F5` | `activeMenuBg` | [lib/constants/app_colors.dart:90](../../lib/constants/app_colors.dart#L90) | 2 | 2 |
| deliveryProfileAvatarBorder | `#FFFFFFFF` | `Color(0xFFFFFFFF)` | [lib/constants/app_colors.dart:91](../../lib/constants/app_colors.dart#L91) | 2 | 2 |
| deliveryCheckInButton | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:92](../../lib/constants/app_colors.dart#L92) | 1 | 1 |
| deliveryCheckInButtonShadow | `#FF061431` | `primary950` | [lib/constants/app_colors.dart:93](../../lib/constants/app_colors.dart#L93) | 0 | 0 |
| deliveryCustomerLocation | `#FF1479E8` | `Color(0xFF1479E8)` | [lib/constants/app_colors.dart:94](../../lib/constants/app_colors.dart#L94) | 1 | 1 |
| deliveryCustomerLocationSoft | `#FFEDF6FF` | `Color(0xFFEDF6FF)` | [lib/constants/app_colors.dart:95](../../lib/constants/app_colors.dart#L95) | 1 | 1 |
| deliveryCustomerSales | `#FF0D1F42` | `primary` | [lib/constants/app_colors.dart:96](../../lib/constants/app_colors.dart#L96) | 1 | 1 |
| deliveryCustomerSalesSoft | `#FFDDE6F5` | `activeMenuBg` | [lib/constants/app_colors.dart:97](../../lib/constants/app_colors.dart#L97) | 1 | 1 |
| deliveryCustomerPending | `#FFF49326` | `Color(0xFFF49326)` | [lib/constants/app_colors.dart:98](../../lib/constants/app_colors.dart#L98) | 1 | 1 |
| deliveryCustomerPendingSoft | `#FFFFF7EC` | `Color(0xFFFFF7EC)` | [lib/constants/app_colors.dart:99](../../lib/constants/app_colors.dart#L99) | 1 | 1 |
| deliveryCustomerOrders | `#FF1479E8` | `Color(0xFF1479E8)` | [lib/constants/app_colors.dart:100](../../lib/constants/app_colors.dart#L100) | 5 | 3 |
| deliveryCustomerOrdersSoft | `#FFEDF6FF` | `Color(0xFFEDF6FF)` | [lib/constants/app_colors.dart:101](../../lib/constants/app_colors.dart#L101) | 2 | 2 |

Shared gradient: `AppColors.primaryGradient` uses `primary900` (#FF112548) → `primary950` (#FF061431), top to bottom.

## Distinct colors bypassing AppColors

| Base ARGB | Expressions | Occurrences | Matching AppColors members |
| --- | --- | ---: | --- |
| `#00000000` | `Colors.transparent` | 63 | No exact match |
| `#080F172A` | `Color(0x080F172A)` | 2 | No exact match |
| `#0D000000` | `Color(0x0D000000)` | 1 | No exact match |
| `#0F24352A` | `Color(0x0F24352A)` | 1 | No exact match |
| `#10000000` | `Color(0x10000000)` | 1 | No exact match |
| `#12063B00` | `Color(0x12063B00)` | 1 | No exact match |
| `#14063B00` | `Color(0x14063B00)` | 2 | No exact match |
| `#22000000` | `Color(0x22000000)` | 1 | No exact match |
| `#33005225` | `Color(0x33005225)` | 1 | No exact match |
| `#330B4A06` | `Color(0x330B4A06)` | 2 | No exact match |
| `#3DFFFFFF` | `Colors.white24` | 2 | No exact match |
| `#42000000` | `Colors.black26` | 1 | No exact match |
| `#8A000000` | `Colors.black54` | 2 | No exact match |
| `#B3FFFFFF` | `Colors.white70` | 15 | No exact match |
| `#FF000000` | `Colors.black` | 83 | No exact match |
| `#FF00451F` | `Color(0xFF00451F)` | 1 | No exact match |
| `#FF00662F` | `Color(0xFF00662F)` | 1 | No exact match |
| `#FF009688` | `Color(0xFF009688)` | 1 | No exact match |
| `#FF0284C7` | `Color(0xFF0284C7)` | 1 | No exact match |
| `#FF04844B` | `Color(0xFF04844B)` | 1 | No exact match |
| `#FF064B26` | `Color(0xFF064B26)` | 1 | No exact match |
| `#FF065F1B` | `Color(0xFF065F1B)` | 4 | No exact match |
| `#FF06783D` | `Color(0xFF06783D)` | 1 | No exact match |
| `#FF087333` | `Color(0xFF087333)` | 1 | No exact match |
| `#FF08733A` | `Color(0xFF08733A)` | 1 | No exact match |
| `#FF08763A` | `Color(0xFF08763A)` | 1 | No exact match |
| `#FF08783D` | `Color(0xFF08783D)` | 8 | No exact match |
| `#FF0A3C02` | `Color(0xFF0A3C02)` | 1 | No exact match |
| `#FF0A8F3D` | `Color(0xFF0A8F3D)` | 1 | No exact match |
| `#FF0D1F42` | `Color(0xFF0D1F42)` | 75 | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| `#FF0D7A24` | `Color(0xFF0D7A24)` | 5 | No exact match |
| `#FF0D8C28` | `Color(0xFF0D8C28)` | 3 | No exact match |
| `#FF0F172A` | `Color(0xFF0F172A)` | 24 | No exact match |
| `#FF0F5A00` | `Color(0xFF0F5A00)` | 1 | No exact match |
| `#FF0F766E` | `Color(0xFF0F766E)` | 1 | No exact match |
| `#FF107C41` | `Color(0xFF107C41)` | 1 | No exact match |
| `#FF111411` | `Color(0xFF111411)` | 2 | No exact match |
| `#FF111827` | `Color(0xFF111827)` | 36 | textPrimary, deliveryInk |
| `#FF1234D8` | `Color(0xFF1234D8)` | 1 | No exact match |
| `#FF123D28` | `Color(0xFF123D28)` | 1 | No exact match |
| `#FF1256F3` | `Color(0xFF1256F3)` | 1 | No exact match |
| `#FF15191F` | `Color(0xFF15191F)` | 1 | No exact match |
| `#FF155EC7` | `Color(0xFF155EC7)` | 3 | No exact match |
| `#FF15803D` | `Color(0xFF15803D)` | 6 | No exact match |
| `#FF16A34A` | `Color(0xFF16A34A)` | 20 | No exact match |
| `#FF172033` | `Color(0xFF172033)` | 1 | No exact match |
| `#FF174F28` | `Color(0xFF174F28)` | 1 | No exact match |
| `#FF19652D` | `Color(0xFF19652D)` | 1 | No exact match |
| `#FF1E9C90` | `Color(0xFF1E9C90)` | 3 | No exact match |
| `#FF1F6D2A` | `Color(0xFF1F6D2A)` | 5 | No exact match |
| `#FF213B50` | `Color(0xFF213B50)` | 1 | No exact match |
| `#FF21854A` | `Color(0xFF21854A)` | 1 | No exact match |
| `#FF22C55E` | `Color(0xFF22C55E)` | 4 | No exact match |
| `#FF246936` | `Color(0xFF246936)` | 2 | No exact match |
| `#FF24713A` | `Color(0xFF24713A)` | 1 | No exact match |
| `#FF2563EB` | `Color(0xFF2563EB)` | 17 | No exact match |
| `#FF25D366` | `Color(0xFF25D366)` | 1 | No exact match |
| `#FF284BFF` | `Color(0xFF284BFF)` | 10 | No exact match |
| `#FF30343B` | `Color(0xFF30343B)` | 1 | No exact match |
| `#FF303746` | `Color(0xFF303746)` | 1 | No exact match |
| `#FF313846` | `Color(0xFF313846)` | 1 | No exact match |
| `#FF31394D` | `Color(0xFF31394D)` | 3 | No exact match |
| `#FF31536B` | `Color(0xFF31536B)` | 1 | No exact match |
| `#FF3168FF` | `Color(0xFF3168FF)` | 1 | No exact match |
| `#FF334155` | `Color(0xFF334155)` | 7 | No exact match |
| `#FF35566B` | `Color(0xFF35566B)` | 1 | No exact match |
| `#FF356B4B` | `Color(0xFF356B4B)` | 1 | No exact match |
| `#FF357343` | `Color(0xFF357343)` | 1 | No exact match |
| `#FF3775D6` | `Color(0xFF3775D6)` | 1 | No exact match |
| `#FF39A04D` | `Color(0xFF39A04D)` | 1 | No exact match |
| `#FF40536A` | `Color(0xFF40536A)` | 2 | No exact match |
| `#FF475569` | `Color(0xFF475569)` | 3 | No exact match |
| `#FF4A546B` | `Color(0xFF4A546B)` | 1 | No exact match |
| `#FF4B515B` | `Color(0xFF4B515B)` | 1 | No exact match |
| `#FF4B5668` | `Color(0xFF4B5668)` | 2 | No exact match |
| `#FF4F46E5` | `Color(0xFF4F46E5)` | 1 | No exact match |
| `#FF4F5870` | `Color(0xFF4F5870)` | 7 | No exact match |
| `#FF536074` | `Color(0xFF536074)` | 1 | No exact match |
| `#FF5479E4` | `Color(0xFF5479E4)` | 1 | No exact match |
| `#FF567F19` | `Color(0xFF567F19)` | 2 | No exact match |
| `#FF56D36F` | `Color(0xFF56D36F)` | 1 | No exact match |
| `#FF586176` | `Color(0xFF586176)` | 7 | No exact match |
| `#FF64748B` | `Color(0xFF64748B)` | 40 | No exact match |
| `#FF667085` | `Color(0xFF667085)` | 2 | No exact match |
| `#FF6B7280` | `Color(0xFF6B7280)` | 5 | accentGrey, textMuted |
| `#FF6D35D7` | `Color(0xFF6D35D7)` | 1 | No exact match |
| `#FF6D6D6D` | `Color(0xFF6D6D6D)` | 1 | No exact match |
| `#FF718096` | `Color(0xFF718096)` | 1 | No exact match |
| `#FF7C3AED` | `Color(0xFF7C3AED)` | 6 | No exact match |
| `#FF7C3EFF` | `Color(0xFF7C3EFF)` | 1 | No exact match |
| `#FF7C8491` | `Color(0xFF7C8491)` | 2 | No exact match |
| `#FF8A50D1` | `Color(0xFF8A50D1)` | 2 | No exact match |
| `#FF8CAD84` | `Color(0xFF8CAD84)` | 5 | No exact match |
| `#FF94A3B8` | `Color(0xFF94A3B8)` | 56 | No exact match |
| `#FF98A2B3` | `Color(0xFF98A2B3)` | 11 | No exact match |
| `#FF991B1B` | `Color(0xFF991B1B)` | 1 | No exact match |
| `#FF9AA0B1` | `Color(0xFF9AA0B1)` | 1 | No exact match |
| `#FF9AB99B` | `Color(0xFF9AB99B)` | 1 | No exact match |
| `#FF9CA3AF` | `Color(0xFF9CA3AF)` | 5 | No exact match |
| `#FFA3B896` | `Color(0xFFA3B896)` | 2 | No exact match |
| `#FFB00000` | `Color(0xFFB00000)` | 2 | No exact match |
| `#FFB45309` | `Color(0xFFB45309)` | 4 | No exact match |
| `#FFB7791F` | `Color(0xFFB7791F)` | 3 | No exact match |
| `#FFBFE8CC` | `Color(0xFFBFE8CC)` | 1 | No exact match |
| `#FFC53030` | `Color(0xFFC53030)` | 2 | No exact match |
| `#FFC9CED6` | `Color(0xFFC9CED6)` | 1 | No exact match |
| `#FFCBD5E1` | `Color(0xFFCBD5E1)` | 2 | No exact match |
| `#FFCDD3DC` | `Color(0xFFCDD3DC)` | 1 | No exact match |
| `#FFCDECD7` | `Color(0xFFCDECD7)` | 1 | No exact match |
| `#FFD1D5DB` | `Color(0xFFD1D5DB)` | 23 | borderStrong |
| `#FFD38B16` | `Color(0xFFD38B16)` | 1 | No exact match |
| `#FFD44A4A` | `Color(0xFFD44A4A)` | 1 | No exact match |
| `#FFD4DAE2` | `Color(0xFFD4DAE2)` | 1 | No exact match |
| `#FFD4E8FF` | `Color(0xFFD4E8FF)` | 3 | No exact match |
| `#FFD4EFD3` | `Color(0xFFD4EFD3)` | 3 | No exact match |
| `#FFD6E6FF` | `Color(0xFFD6E6FF)` | 1 | No exact match |
| `#FFD7DCE4` | `Color(0xFFD7DCE4)` | 1 | No exact match |
| `#FFD7DEE8` | `Color(0xFFD7DEE8)` | 4 | No exact match |
| `#FFD8DFD8` | `Color(0xFFD8DFD8)` | 9 | No exact match |
| `#FFD8DFE6` | `Color(0xFFD8DFE6)` | 2 | No exact match |
| `#FFD8DFE8` | `Color(0xFFD8DFE8)` | 6 | No exact match |
| `#FFD8E4DC` | `Color(0xFFD8E4DC)` | 2 | No exact match |
| `#FFD8EEDD` | `Color(0xFFD8EEDD)` | 1 | No exact match |
| `#FFD93838` | `Color(0xFFD93838)` | 4 | No exact match |
| `#FFD9DEE8` | `Color(0xFFD9DEE8)` | 1 | No exact match |
| `#FFDB8A00` | `Color(0xFFDB8A00)` | 1 | No exact match |
| `#FFDC2626` | `Color(0xFFDC2626)` | 8 | statusInactiveText, red, deliveryRed |
| `#FFDCEEE1` | `Color(0xFFDCEEE1)` | 1 | No exact match |
| `#FFDCFCE7` | `Color(0xFFDCFCE7)` | 3 | No exact match |
| `#FFDDE3EA` | `Color(0xFFDDE3EA)` | 13 | No exact match |
| `#FFDDE8D8` | `Color(0xFFDDE8D8)` | 1 | No exact match |
| `#FFDDEFE4` | `Color(0xFFDDEFE4)` | 1 | No exact match |
| `#FFE0E7FF` | `Color(0xFFE0E7FF)` | 1 | No exact match |
| `#FFE0F2FE` | `Color(0xFFE0F2FE)` | 2 | No exact match |
| `#FFE1E4E8` | `Color(0xFFE1E4E8)` | 5 | No exact match |
| `#FFE1E5E8` | `Color(0xFFE1E5E8)` | 1 | No exact match |
| `#FFE1E6EE` | `Color(0xFFE1E6EE)` | 2 | No exact match |
| `#FFE1E6EF` | `Color(0xFFE1E6EF)` | 4 | No exact match |
| `#FFE1F6EA` | `Color(0xFFE1F6EA)` | 1 | No exact match |
| `#FFE2D2FF` | `Color(0xFFE2D2FF)` | 1 | No exact match |
| `#FFE2E6EA` | `Color(0xFFE2E6EA)` | 2 | No exact match |
| `#FFE2E7F0` | `Color(0xFFE2E7F0)` | 19 | No exact match |
| `#FFE2E8F0` | `Color(0xFFE2E8F0)` | 17 | No exact match |
| `#FFE2EDE6` | `Color(0xFFE2EDE6)` | 1 | No exact match |
| `#FFE2EFD8` | `Color(0xFFE2EFD8)` | 1 | No exact match |
| `#FFE3E7EC` | `Color(0xFFE3E7EC)` | 1 | No exact match |
| `#FFE4EAF3` | `Color(0xFFE4EAF3)` | 1 | No exact match |
| `#FFE4F7F4` | `Color(0xFFE4F7F4)` | 1 | No exact match |
| `#FFE5E7EB` | `Color(0xFFE5E7EB)` | 77 | No exact match |
| `#FFE5EAF1` | `Color(0xFFE5EAF1)` | 1 | No exact match |
| `#FFE5F6E7` | `Color(0xFFE5F6E7)` | 3 | No exact match |
| `#FFE6ECD9` | `Color(0xFFE6ECD9)` | 1 | No exact match |
| `#FFE6F1FF` | `Color(0xFFE6F1FF)` | 1 | No exact match |
| `#FFE6F7F1` | `Color(0xFFE6F7F1)` | 1 | No exact match |
| `#FFE7EAEF` | `Color(0xFFE7EAEF)` | 1 | No exact match |
| `#FFE7EBEE` | `Color(0xFFE7EBEE)` | 1 | No exact match |
| `#FFE7EBEF` | `Color(0xFFE7EBEF)` | 3 | No exact match |
| `#FFE7FFFB` | `Color(0xFFE7FFFB)` | 1 | No exact match |
| `#FFE8ECEF` | `Color(0xFFE8ECEF)` | 1 | No exact match |
| `#FFE8EDF2` | `Color(0xFFE8EDF2)` | 1 | No exact match |
| `#FFE8F1FF` | `Color(0xFFE8F1FF)` | 1 | No exact match |
| `#FFE8F6E5` | `Color(0xFFE8F6E5)` | 1 | No exact match |
| `#FFE8F7E8` | `Color(0xFFE8F7E8)` | 2 | No exact match |
| `#FFE8F8EE` | `Color(0xFFE8F8EE)` | 14 | No exact match |
| `#FFE91E63` | `Color(0xFFE91E63)` | 1 | No exact match |
| `#FFE9EDF0` | `Color(0xFFE9EDF0)` | 4 | No exact match |
| `#FFE9EDF2` | `Color(0xFFE9EDF2)` | 1 | No exact match |
| `#FFE9EDF5` | `Color(0xFFE9EDF5)` | 5 | deliveryCardBorder |
| `#FFE9F7EA` | `Color(0xFFE9F7EA)` | 2 | No exact match |
| `#FFE9F7F2` | `Color(0xFFE9F7F2)` | 1 | No exact match |
| `#FFE9F8EF` | `Color(0xFFE9F8EF)` | 2 | No exact match |
| `#FFEAF0FF` | `Color(0xFFEAF0FF)` | 2 | No exact match |
| `#FFEAF2FF` | `Color(0xFFEAF2FF)` | 2 | No exact match |
| `#FFEAF3FF` | `Color(0xFFEAF3FF)` | 4 | No exact match |
| `#FFEAF5D9` | `Color(0xFFEAF5D9)` | 2 | No exact match |
| `#FFEAF5E9` | `Color(0xFFEAF5E9)` | 2 | No exact match |
| `#FFEAF5EA` | `Color(0xFFEAF5EA)` | 1 | No exact match |
| `#FFEAF7EC` | `Color(0xFFEAF7EC)` | 1 | No exact match |
| `#FFEAF7ED` | `Color(0xFFEAF7ED)` | 3 | No exact match |
| `#FFEAF7EE` | `Color(0xFFEAF7EE)` | 1 | No exact match |
| `#FFECF3FF` | `Color(0xFFECF3FF)` | 1 | No exact match |
| `#FFECF8F2` | `Color(0xFFECF8F2)` | 1 | No exact match |
| `#FFEDFBF0` | `Color(0xFFEDFBF0)` | 1 | No exact match |
| `#FFEF4444` | `Color(0xFFEF4444)` | 9 | No exact match |
| `#FFEFF6EE` | `Color(0xFFEFF6EE)` | 1 | No exact match |
| `#FFEFF6FF` | `Color(0xFFEFF6FF)` | 3 | No exact match |
| `#FFEFF7EA` | `Color(0xFFEFF7EA)` | 4 | No exact match |
| `#FFEFF8F2` | `Color(0xFFEFF8F2)` | 1 | No exact match |
| `#FFF0C6C6` | `Color(0xFFF0C6C6)` | 1 | No exact match |
| `#FFF0E9FF` | `Color(0xFFF0E9FF)` | 1 | No exact match |
| `#FFF0F3F2` | `Color(0xFFF0F3F2)` | 1 | No exact match |
| `#FFF0F5F7` | `Color(0xFFF0F5F7)` | 1 | No exact match |
| `#FFF0F7E9` | `Color(0xFFF0F7E9)` | 1 | No exact match |
| `#FFF0F7EC` | `Color(0xFFF0F7EC)` | 1 | No exact match |
| `#FFF0F7ED` | `Color(0xFFF0F7ED)` | 2 | No exact match |
| `#FFF0FDF4` | `Color(0xFFF0FDF4)` | 2 | No exact match |
| `#FFF18A1A` | `Color(0xFFF18A1A)` | 1 | No exact match |
| `#FFF1F4F8` | `Color(0xFFF1F4F8)` | 2 | No exact match |
| `#FFF1F5F9` | `Color(0xFFF1F5F9)` | 6 | No exact match |
| `#FFF1F5FB` | `Color(0xFFF1F5FB)` | 1 | No exact match |
| `#FFF1F6EF` | `Color(0xFFF1F6EF)` | 1 | No exact match |
| `#FFF1F7EF` | `Color(0xFFF1F7EF)` | 4 | No exact match |
| `#FFF1F7F3` | `Color(0xFFF1F7F3)` | 1 | No exact match |
| `#FFF1F8EC` | `Color(0xFFF1F8EC)` | 1 | No exact match |
| `#FFF26B12` | `Color(0xFFF26B12)` | 1 | No exact match |
| `#FFF2E6FF` | `Color(0xFFF2E6FF)` | 1 | No exact match |
| `#FFF2F3F6` | `Color(0xFFF2F3F6)` | 1 | No exact match |
| `#FFF2F4F3` | `Color(0xFFF2F4F3)` | 3 | No exact match |
| `#FFF2F4F7` | `Color(0xFFF2F4F7)` | 1 | No exact match |
| `#FFF2F5FA` | `Color(0xFFF2F5FA)` | 1 | adminSidebarBg, surfaceSoft, deliveryBackground, deliveryBlueSoft, deliveryVioletSoft, deliveryVioletBadge, deliveryBlueBadge |
| `#FFF3E8FF` | `Color(0xFFF3E8FF)` | 5 | No exact match |
| `#FFF3F4F6` | `Color(0xFFF3F4F6)` | 22 | No exact match |
| `#FFF3F5F2` | `Color(0xFFF3F5F2)` | 1 | No exact match |
| `#FFF3F5F8` | `Color(0xFFF3F5F8)` | 6 | No exact match |
| `#FFF3FAF0` | `Color(0xFFF3FAF0)` | 1 | No exact match |
| `#FFF3FBF4` | `Color(0xFFF3FBF4)` | 1 | No exact match |
| `#FFF44336` | `Colors.red` | 1 | No exact match |
| `#FFF4F5F7` | `Color(0xFFF4F5F7)` | 1 | No exact match |
| `#FFF4F6F8` | `Color(0xFFF4F6F8)` | 2 | No exact match |
| `#FFF4F7F5` | `Color(0xFFF4F7F5)` | 4 | No exact match |
| `#FFF4FBF1` | `Color(0xFFF4FBF1)` | 1 | No exact match |
| `#FFF59E0B` | `Color(0xFFF59E0B)` | 10 | amber, deliveryYellow |
| `#FFF6C7C7` | `Color(0xFFF6C7C7)` | 1 | No exact match |
| `#FFF6F8F3` | `Color(0xFFF6F8F3)` | 1 | No exact match |
| `#FFF6F8FB` | `Color(0xFFF6F8FB)` | 1 | No exact match |
| `#FFF6F8FC` | `Color(0xFFF6F8FC)` | 1 | No exact match |
| `#FFF7F9FC` | `Color(0xFFF7F9FC)` | 15 | No exact match |
| `#FFF7FAF8` | `Color(0xFFF7FAF8)` | 3 | No exact match |
| `#FFF7FBF4` | `Color(0xFFF7FBF4)` | 1 | No exact match |
| `#FFF7FBF8` | `Color(0xFFF7FBF8)` | 1 | No exact match |
| `#FFF8FAF7` | `Color(0xFFF8FAF7)` | 1 | No exact match |
| `#FFF8FAF9` | `Color(0xFFF8FAF9)` | 6 | No exact match |
| `#FFF8FAFB` | `Color(0xFFF8FAFB)` | 1 | No exact match |
| `#FFF8FAFC` | `Color(0xFFF8FAFC)` | 34 | No exact match |
| `#FFF8FBF8` | `Color(0xFFF8FBF8)` | 11 | No exact match |
| `#FFF97316` | `Color(0xFFF97316)` | 7 | orange, deliveryOrange |
| `#FFF9FBFA` | `Color(0xFFF9FBFA)` | 2 | No exact match |
| `#FFFAFAFA` | `Color(0xFFFAFAFA)` | 2 | No exact match |
| `#FFFAFBFC` | `Color(0xFFFAFBFC)` | 1 | No exact match |
| `#FFFBFBFB` | `Color(0xFFFBFBFB)` | 5 | No exact match |
| `#FFFBFCFB` | `Color(0xFFFBFCFB)` | 1 | No exact match |
| `#FFFBFCFD` | `Color(0xFFFBFCFD)` | 1 | No exact match |
| `#FFFBFCFE` | `Color(0xFFFBFCFE)` | 2 | No exact match |
| `#FFFBFEFA` | `Color(0xFFFBFEFA)` | 1 | No exact match |
| `#FFFDECEC` | `Color(0xFFFDECEC)` | 1 | No exact match |
| `#FFFDFDFD` | `Color(0xFFFDFDFD)` | 2 | No exact match |
| `#FFFECACA` | `Color(0xFFFECACA)` | 1 | statusInactiveBorder |
| `#FFFEE2E2` | `Color(0xFFFEE2E2)` | 5 | No exact match |
| `#FFFEF2F2` | `Color(0xFFFEF2F2)` | 1 | statusInactiveBg, deliveryRedSoft |
| `#FFFEF3C7` | `Color(0xFFFEF3C7)` | 1 | No exact match |
| `#FFFF4358` | `Color(0xFFFF4358)` | 1 | No exact match |
| `#FFFF4B4B` | `Color(0xFFFF4B4B)` | 1 | No exact match |
| `#FFFF4D4F` | `Color(0xFFFF4D4F)` | 3 | No exact match |
| `#FFFF4D6D` | `Color(0xFFFF4D6D)` | 1 | No exact match |
| `#FFFF5722` | `Colors.deepOrange` | 2 | No exact match |
| `#FFFF6B6B` | `Color(0xFFFF6B6B)` | 1 | No exact match |
| `#FFFF9F1C` | `Color(0xFFFF9F1C)` | 1 | No exact match |
| `#FFFFB020` | `Color(0xFFFFB020)` | 2 | No exact match |
| `#FFFFB4B4` | `Color(0xFFFFB4B4)` | 1 | No exact match |
| `#FFFFD2D8` | `Color(0xFFFFD2D8)` | 1 | No exact match |
| `#FFFFDDB6` | `Color(0xFFFFDDB6)` | 1 | No exact match |
| `#FFFFE0A8` | `Color(0xFFFFE0A8)` | 1 | No exact match |
| `#FFFFE2A8` | `Color(0xFFFFE2A8)` | 1 | No exact match |
| `#FFFFE4E8` | `Color(0xFFFFE4E8)` | 1 | No exact match |
| `#FFFFE8EA` | `Color(0xFFFFE8EA)` | 1 | No exact match |
| `#FFFFEBEB` | `Color(0xFFFFEBEB)` | 2 | No exact match |
| `#FFFFECEE` | `Color(0xFFFFECEE)` | 2 | No exact match |
| `#FFFFECEF` | `Color(0xFFFFECEF)` | 1 | No exact match |
| `#FFFFEDD5` | `Color(0xFFFFEDD5)` | 3 | No exact match |
| `#FFFFEEF0` | `Color(0xFFFFEEF0)` | 1 | No exact match |
| `#FFFFF0D9` | `Color(0xFFFFF0D9)` | 1 | No exact match |
| `#FFFFF1DF` | `Color(0xFFFFF1DF)` | 1 | No exact match |
| `#FFFFF1F1` | `Color(0xFFFFF1F1)` | 4 | No exact match |
| `#FFFFF2E7` | `Color(0xFFFFF2E7)` | 1 | No exact match |
| `#FFFFF3E8` | `Color(0xFFFFF3E8)` | 1 | No exact match |
| `#FFFFF4E5` | `Color(0xFFFFF4E5)` | 3 | No exact match |
| `#FFFFF5F6` | `Color(0xFFFFF5F6)` | 1 | No exact match |
| `#FFFFF7E6` | `Color(0xFFFFF7E6)` | 5 | No exact match |
| `#FFFFF7ED` | `Color(0xFFFFF7ED)` | 1 | No exact match |
| `#FFFFF8E7` | `Color(0xFFFFF8E7)` | 1 | No exact match |
| `#FFFFF9E8` | `Color(0xFFFFF9E8)` | 1 | No exact match |
| `#FFFFFBFA` | `Color(0xFFFFFBFA)` | 1 | No exact match |
| `#FFFFFFFF` | `Colors.white`, `Color(0xFFFFFFFF)` | 492 | background, surface, deliveryProfileAvatarBorder |

## Files with the most direct color values

| File | Occurrences |
| --- | ---: |
| [lib/screens/admin/orders/admin_orders_screen.dart](../../lib/screens/admin/orders/admin_orders_screen.dart) | 109 |
| [lib/screens/admin/attendance/attendance_screen.dart](../../lib/screens/admin/attendance/attendance_screen.dart) | 73 |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart) | 68 |
| [lib/screens/admin/settings/account_screen.dart](../../lib/screens/admin/settings/account_screen.dart) | 64 |
| [lib/screens/admin/customers/customer_details_screen.dart](../../lib/screens/admin/customers/customer_details_screen.dart) | 57 |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart) | 55 |
| [lib/screens/admin/suppliers/suppliers_screen.dart](../../lib/screens/admin/suppliers/suppliers_screen.dart) | 51 |
| [lib/screens/admin/quotations/admin_quotations_screen.dart](../../lib/screens/admin/quotations/admin_quotations_screen.dart) | 50 |
| [lib/screens/admin/categories/add_category_screen.dart](../../lib/screens/admin/categories/add_category_screen.dart) | 49 |
| [lib/screens/admin/quotations/create_quotation_screen.dart](../../lib/screens/admin/quotations/create_quotation_screen.dart) | 48 |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart) | 48 |
| [lib/screens/sales_manager/leads/add_lead_screen.dart](../../lib/screens/sales_manager/leads/add_lead_screen.dart) | 48 |
| [lib/screens/admin/customers/add_customer_screen.dart](../../lib/screens/admin/customers/add_customer_screen.dart) | 47 |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart) | 45 |
| [lib/screens/shared/lead_detail_screen.dart](../../lib/screens/shared/lead_detail_screen.dart) | 45 |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart) | 41 |
| [lib/screens/admin/categories/categories_screen.dart](../../lib/screens/admin/categories/categories_screen.dart) | 38 |
| [lib/screens/admin/roles/new_role_screen.dart](../../lib/screens/admin/roles/new_role_screen.dart) | 36 |
| [lib/screens/admin/roles/roles_permissions_screen.dart](../../lib/screens/admin/roles/roles_permissions_screen.dart) | 36 |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart) | 34 |
| [lib/screens/payment_collection_screen.dart](../../lib/screens/payment_collection_screen.dart) | 31 |
| [lib/screens/admin/settings/company_settings_screen.dart](../../lib/screens/admin/settings/company_settings_screen.dart) | 26 |
| [lib/screens/admin/users/admin_user_list_screen.dart](../../lib/screens/admin/users/admin_user_list_screen.dart) | 26 |
| [lib/screens/admin/users/add_staff_screen.dart](../../lib/screens/admin/users/add_staff_screen.dart) | 25 |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart) | 25 |
| [lib/screens/admin/suppliers/add_supplier_screen.dart](../../lib/screens/admin/suppliers/add_supplier_screen.dart) | 24 |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart) | 23 |
| [lib/screens/admin/settings/general_information_screen.dart](../../lib/screens/admin/settings/general_information_screen.dart) | 23 |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart) | 22 |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart](../../lib/screens/admin/sales_returns/sales_returns_screen.dart) | 20 |
| [lib/screens/admin/settings/billing_screen.dart](../../lib/screens/admin/settings/billing_screen.dart) | 19 |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart) | 19 |
| [lib/screens/admin/leads/admin_leads_screen.dart](../../lib/screens/admin/leads/admin_leads_screen.dart) | 18 |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart) | 17 |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart) | 16 |
| [lib/screens/admin/quotations/quotation_detail_screen.dart](../../lib/screens/admin/quotations/quotation_detail_screen.dart) | 15 |
| [lib/screens/admin/settings/branding_identity_screen.dart](../../lib/screens/admin/settings/branding_identity_screen.dart) | 15 |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart) | 15 |
| [lib/screens/admin/settings/documents_screen.dart](../../lib/screens/admin/settings/documents_screen.dart) | 14 |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart) | 14 |
| [lib/widgets/delivery/delivery_top_bar.dart](../../lib/widgets/delivery/delivery_top_bar.dart) | 12 |
| [lib/screens/admin/settings/plans_screen.dart](../../lib/screens/admin/settings/plans_screen.dart) | 11 |
| [lib/widgets/admin/app_drawer.dart](../../lib/widgets/admin/app_drawer.dart) | 11 |
| [lib/screens/admin/customers/customers_screen.dart](../../lib/screens/admin/customers/customers_screen.dart) | 10 |
| [lib/screens/admin/settings/change_password_screen.dart](../../lib/screens/admin/settings/change_password_screen.dart) | 10 |
| [lib/screens/admin/settings/business_settings_screen.dart](../../lib/screens/admin/settings/business_settings_screen.dart) | 9 |
| [lib/screens/auth/login_screen.dart](../../lib/screens/auth/login_screen.dart) | 9 |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart](../../lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart) | 9 |
| [lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart](../../lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart) | 9 |
| [lib/screens/sales_manager/performance/sales_manager_performance_screen.dart](../../lib/screens/sales_manager/performance/sales_manager_performance_screen.dart) | 9 |
| [lib/theme/app_theme.dart](../../lib/theme/app_theme.dart) | 9 |
| [lib/widgets/delivery/delivery_partner_sidebar.dart](../../lib/widgets/delivery/delivery_partner_sidebar.dart) | 8 |
| [lib/screens/admin/settings/additional_information_screen.dart](../../lib/screens/admin/settings/additional_information_screen.dart) | 7 |
| [lib/screens/admin/settings/online_presence_screen.dart](../../lib/screens/admin/settings/online_presence_screen.dart) | 7 |
| [lib/screens/delivery/dashboard/delivery_company_orders_screen.dart](../../lib/screens/delivery/dashboard/delivery_company_orders_screen.dart) | 7 |
| [lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart](../../lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart) | 7 |
| [lib/widgets/delivery/order_progress_tracker.dart](../../lib/widgets/delivery/order_progress_tracker.dart) | 7 |
| [lib/screens/auth/register_screen.dart](../../lib/screens/auth/register_screen.dart) | 6 |
| [lib/screens/delivery/end_of_day/widgets/stock_return_form.dart](../../lib/screens/delivery/end_of_day/widgets/stock_return_form.dart) | 6 |
| [lib/screens/sales_manager/stock/sales_manager_stock_screen.dart](../../lib/screens/sales_manager/stock/sales_manager_stock_screen.dart) | 6 |
| [lib/widgets/app_calendar_date_picker.dart](../../lib/widgets/app_calendar_date_picker.dart) | 6 |
| [lib/widgets/delivery/delivery_image_upload_field.dart](../../lib/widgets/delivery/delivery_image_upload_field.dart) | 6 |
| [lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart](../../lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart) | 5 |
| [lib/screens/delivery/orders/create_delivery_order_screen.dart](../../lib/screens/delivery/orders/create_delivery_order_screen.dart) | 5 |
| [lib/widgets/super_admin/super_admin_sidebar.dart](../../lib/widgets/super_admin/super_admin_sidebar.dart) | 5 |
| [lib/screens/delivery/customers/customer_location_picker_screen.dart](../../lib/screens/delivery/customers/customer_location_picker_screen.dart) | 4 |
| [lib/widgets/sales_manager/sales_manager_sidebar.dart](../../lib/widgets/sales_manager/sales_manager_sidebar.dart) | 4 |
| [lib/screens/admin/products/products_screen.dart](../../lib/screens/admin/products/products_screen.dart) | 3 |
| [lib/screens/delivery/customers/delivery_customers_screen.dart](../../lib/screens/delivery/customers/delivery_customers_screen.dart) | 3 |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_empty_state.dart](../../lib/screens/delivery/end_of_day/widgets/end_of_day_empty_state.dart) | 3 |
| [lib/widgets/delivery/delivery_bottom_navigation.dart](../../lib/widgets/delivery/delivery_bottom_navigation.dart) | 3 |
| [lib/widgets/sales_manager/sales_manager_bottom_navigation.dart](../../lib/widgets/sales_manager/sales_manager_bottom_navigation.dart) | 3 |
| [lib/screens/admin/inventory/inventory_screen.dart](../../lib/screens/admin/inventory/inventory_screen.dart) | 2 |
| [lib/screens/admin/invoices/invoices_screen.dart](../../lib/screens/admin/invoices/invoices_screen.dart) | 2 |
| [lib/screens/admin/purchases/purchases_screen.dart](../../lib/screens/admin/purchases/purchases_screen.dart) | 2 |
| [lib/screens/admin/reports/reports_screen.dart](../../lib/screens/admin/reports/reports_screen.dart) | 2 |
| [lib/screens/admin/settings/admin_settings_screen.dart](../../lib/screens/admin/settings/admin_settings_screen.dart) | 2 |
| [lib/screens/delivery/collections/delivery_collection_list_screen.dart](../../lib/screens/delivery/collections/delivery_collection_list_screen.dart) | 2 |
| [lib/screens/delivery/customers/create_delivery_customer_screen.dart](../../lib/screens/delivery/customers/create_delivery_customer_screen.dart) | 2 |
| [lib/screens/delivery/customers/delivery_customer_detail_screen.dart](../../lib/screens/delivery/customers/delivery_customer_detail_screen.dart) | 2 |
| [lib/screens/shared/map_location_view_screen.dart](../../lib/screens/shared/map_location_view_screen.dart) | 2 |
| [lib/widgets/completion_feedback_sheet.dart](../../lib/widgets/completion_feedback_sheet.dart) | 2 |
| [lib/widgets/delivery/customer_search_dialog.dart](../../lib/widgets/delivery/customer_search_dialog.dart) | 2 |
| [lib/screens/admin/orders/order_detail_screen.dart](../../lib/screens/admin/orders/order_detail_screen.dart) | 1 |
| [lib/screens/admin/profile/admin_profile_screen.dart](../../lib/screens/admin/profile/admin_profile_screen.dart) | 1 |
| [lib/screens/delivery/end_of_day/end_of_day_return_screen.dart](../../lib/screens/delivery/end_of_day/end_of_day_return_screen.dart) | 1 |
| [lib/widgets/delivery/delivery_partner_search_dialog.dart](../../lib/widgets/delivery/delivery_partner_search_dialog.dart) | 1 |
| [lib/widgets/delivery/voice_input_sheet.dart](../../lib/widgets/delivery/voice_input_sheet.dart) | 1 |
| [lib/widgets/list_pagination_bar.dart](../../lib/widgets/list_pagination_bar.dart) | 1 |
| [lib/widgets/sidebar_logout_button.dart](../../lib/widgets/sidebar_logout_button.dart) | 1 |

## Every direct color occurrence by file

### lib/screens/admin/attendance/attendance_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/attendance/attendance_screen.dart:68](../../lib/screens/admin/attendance/attendance_screen.dart#L68) (column 20) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:82](../../lib/screens/admin/attendance/attendance_screen.dart#L82) (column 20) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:96](../../lib/screens/admin/attendance/attendance_screen.dart#L96) (column 20) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:110](../../lib/screens/admin/attendance/attendance_screen.dart#L110) (column 20) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:190](../../lib/screens/admin/attendance/attendance_screen.dart#L190) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/attendance/attendance_screen.dart:192](../../lib/screens/admin/attendance/attendance_screen.dart#L192) (column 61) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:195](../../lib/screens/admin/attendance/attendance_screen.dart#L195) (column 40) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/attendance/attendance_screen.dart:259](../../lib/screens/admin/attendance/attendance_screen.dart#L259) (column 40) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:274](../../lib/screens/admin/attendance/attendance_screen.dart#L274) (column 40) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:288](../../lib/screens/admin/attendance/attendance_screen.dart#L288) (column 48) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:319](../../lib/screens/admin/attendance/attendance_screen.dart#L319) (column 26) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:320](../../lib/screens/admin/attendance/attendance_screen.dart#L320) (column 23) | `Color(0xFFEAF5EA)` | `#FFEAF5EA` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:327](../../lib/screens/admin/attendance/attendance_screen.dart#L327) (column 26) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:328](../../lib/screens/admin/attendance/attendance_screen.dart#L328) (column 23) | `Color(0xFFEAF2FF)` | `#FFEAF2FF` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:335](../../lib/screens/admin/attendance/attendance_screen.dart#L335) (column 26) | `Color(0xFFF97316)` | `#FFF97316` | inline literal | orange, deliveryOrange |
| [lib/screens/admin/attendance/attendance_screen.dart:336](../../lib/screens/admin/attendance/attendance_screen.dart#L336) (column 23) | `Color(0xFFFFF3E8)` | `#FFFFF3E8` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:343](../../lib/screens/admin/attendance/attendance_screen.dart#L343) (column 26) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:344](../../lib/screens/admin/attendance/attendance_screen.dart#L344) (column 23) | `Color(0xFFEFF6EE)` | `#FFEFF6EE` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:351](../../lib/screens/admin/attendance/attendance_screen.dart#L351) (column 26) | `Color(0xFF6B7280)` | `#FF6B7280` | inline literal | accentGrey, textMuted |
| [lib/screens/admin/attendance/attendance_screen.dart:352](../../lib/screens/admin/attendance/attendance_screen.dart#L352) (column 23) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:468](../../lib/screens/admin/attendance/attendance_screen.dart#L468) (column 28) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:475](../../lib/screens/admin/attendance/attendance_screen.dart#L475) (column 49) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:479](../../lib/screens/admin/attendance/attendance_screen.dart#L479) (column 49) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:498](../../lib/screens/admin/attendance/attendance_screen.dart#L498) (column 28) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:501](../../lib/screens/admin/attendance/attendance_screen.dart#L501) (column 49) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:505](../../lib/screens/admin/attendance/attendance_screen.dart#L505) (column 49) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:526](../../lib/screens/admin/attendance/attendance_screen.dart#L526) (column 41) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:527](../../lib/screens/admin/attendance/attendance_screen.dart#L527) (column 34) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:547](../../lib/screens/admin/attendance/attendance_screen.dart#L547) (column 34) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:548](../../lib/screens/admin/attendance/attendance_screen.dart#L548) (column 41) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:566](../../lib/screens/admin/attendance/attendance_screen.dart#L566) (column 34) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:567](../../lib/screens/admin/attendance/attendance_screen.dart#L567) (column 41) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:584](../../lib/screens/admin/attendance/attendance_screen.dart#L584) (column 22) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:624](../../lib/screens/admin/attendance/attendance_screen.dart#L624) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/attendance/attendance_screen.dart:626](../../lib/screens/admin/attendance/attendance_screen.dart#L626) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:640](../../lib/screens/admin/attendance/attendance_screen.dart#L640) (column 42) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:644](../../lib/screens/admin/attendance/attendance_screen.dart#L644) (column 30) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:658](../../lib/screens/admin/attendance/attendance_screen.dart#L658) (column 34) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/attendance/attendance_screen.dart:667](../../lib/screens/admin/attendance/attendance_screen.dart#L667) (column 34) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:682](../../lib/screens/admin/attendance/attendance_screen.dart#L682) (column 24) | `Color(0xFF334155)` | `#FF334155` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:696](../../lib/screens/admin/attendance/attendance_screen.dart#L696) (column 28) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/attendance/attendance_screen.dart:705](../../lib/screens/admin/attendance/attendance_screen.dart#L705) (column 28) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:720](../../lib/screens/admin/attendance/attendance_screen.dart#L720) (column 28) | `Color(0xFF334155)` | `#FF334155` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:738](../../lib/screens/admin/attendance/attendance_screen.dart#L738) (column 24) | `Color(0xFF334155)` | `#FF334155` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:749](../../lib/screens/admin/attendance/attendance_screen.dart#L749) (column 24) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:779](../../lib/screens/admin/attendance/attendance_screen.dart#L779) (column 22) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:794](../../lib/screens/admin/attendance/attendance_screen.dart#L794) (column 28) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:796](../../lib/screens/admin/attendance/attendance_screen.dart#L796) (column 47) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:806](../../lib/screens/admin/attendance/attendance_screen.dart#L806) (column 46) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:810](../../lib/screens/admin/attendance/attendance_screen.dart#L810) (column 34) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:824](../../lib/screens/admin/attendance/attendance_screen.dart#L824) (column 38) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/attendance/attendance_screen.dart:832](../../lib/screens/admin/attendance/attendance_screen.dart#L832) (column 38) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:930](../../lib/screens/admin/attendance/attendance_screen.dart#L930) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/attendance/attendance_screen.dart:932](../../lib/screens/admin/attendance/attendance_screen.dart#L932) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:935](../../lib/screens/admin/attendance/attendance_screen.dart#L935) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/attendance/attendance_screen.dart:962](../../lib/screens/admin/attendance/attendance_screen.dart#L962) (column 28) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:971](../../lib/screens/admin/attendance/attendance_screen.dart#L971) (column 28) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/attendance/attendance_screen.dart:981](../../lib/screens/admin/attendance/attendance_screen.dart#L981) (column 28) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1005](../../lib/screens/admin/attendance/attendance_screen.dart#L1005) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1023](../../lib/screens/admin/attendance/attendance_screen.dart#L1023) (column 31) | `Color(0xFFEAF7ED)` | `#FFEAF7ED` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1023](../../lib/screens/admin/attendance/attendance_screen.dart#L1023) (column 57) | `Color(0xFFFFF4E5)` | `#FFFFF4E5` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1024](../../lib/screens/admin/attendance/attendance_screen.dart#L1024) (column 31) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:1024](../../lib/screens/admin/attendance/attendance_screen.dart#L1024) (column 57) | `Color(0xFFB45309)` | `#FFB45309` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1025](../../lib/screens/admin/attendance/attendance_screen.dart#L1025) (column 32) | `Color(0xFF22C55E)` | `#FF22C55E` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1025](../../lib/screens/admin/attendance/attendance_screen.dart#L1025) (column 58) | `Color(0xFFF59E0B)` | `#FFF59E0B` | inline literal | amber, deliveryYellow |
| [lib/screens/admin/attendance/attendance_screen.dart:1063](../../lib/screens/admin/attendance/attendance_screen.dart#L1063) (column 31) | `Color(0xFFEAF7ED)` | `#FFEAF7ED` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1063](../../lib/screens/admin/attendance/attendance_screen.dart#L1063) (column 57) | `Color(0xFFFFF4E5)` | `#FFFFF4E5` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1069](../../lib/screens/admin/attendance/attendance_screen.dart#L1069) (column 33) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/attendance/attendance_screen.dart:1069](../../lib/screens/admin/attendance/attendance_screen.dart#L1069) (column 59) | `Color(0xFFB45309)` | `#FFB45309` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1090](../../lib/screens/admin/attendance/attendance_screen.dart#L1090) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/attendance/attendance_screen.dart:1092](../../lib/screens/admin/attendance/attendance_screen.dart#L1092) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1100](../../lib/screens/admin/attendance/attendance_screen.dart#L1100) (column 22) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/attendance/attendance_screen.dart:1109](../../lib/screens/admin/attendance/attendance_screen.dart#L1109) (column 22) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |

### lib/screens/admin/categories/add_category_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/categories/add_category_screen.dart:158](../../lib/screens/admin/categories/add_category_screen.dart#L158) (column 46) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:167](../../lib/screens/admin/categories/add_category_screen.dart#L167) (column 46) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:229](../../lib/screens/admin/categories/add_category_screen.dart#L229) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/categories/add_category_screen.dart:230](../../lib/screens/admin/categories/add_category_screen.dart#L230) (column 47) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:236](../../lib/screens/admin/categories/add_category_screen.dart#L236) (column 22) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:244](../../lib/screens/admin/categories/add_category_screen.dart#L244) (column 20) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:256](../../lib/screens/admin/categories/add_category_screen.dart#L256) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/categories/add_category_screen.dart:258](../../lib/screens/admin/categories/add_category_screen.dart#L258) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:261](../../lib/screens/admin/categories/add_category_screen.dart#L261) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/categories/add_category_screen.dart:275](../../lib/screens/admin/categories/add_category_screen.dart#L275) (column 24) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/categories/add_category_screen.dart:304](../../lib/screens/admin/categories/add_category_screen.dart#L304) (column 52) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/categories/add_category_screen.dart:305](../../lib/screens/admin/categories/add_category_screen.dart#L305) (column 46) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/categories/add_category_screen.dart:333](../../lib/screens/admin/categories/add_category_screen.dart#L333) (column 52) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/categories/add_category_screen.dart:334](../../lib/screens/admin/categories/add_category_screen.dart#L334) (column 46) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/categories/add_category_screen.dart:356](../../lib/screens/admin/categories/add_category_screen.dart#L356) (column 24) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/categories/add_category_screen.dart:364](../../lib/screens/admin/categories/add_category_screen.dart#L364) (column 39) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:382](../../lib/screens/admin/categories/add_category_screen.dart#L382) (column 52) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:383](../../lib/screens/admin/categories/add_category_screen.dart#L383) (column 59) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/categories/add_category_screen.dart:409](../../lib/screens/admin/categories/add_category_screen.dart#L409) (column 52) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:410](../../lib/screens/admin/categories/add_category_screen.dart#L410) (column 59) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/categories/add_category_screen.dart:436](../../lib/screens/admin/categories/add_category_screen.dart#L436) (column 45) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:446](../../lib/screens/admin/categories/add_category_screen.dart#L446) (column 52) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:447](../../lib/screens/admin/categories/add_category_screen.dart#L447) (column 52) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/categories/add_category_screen.dart:467](../../lib/screens/admin/categories/add_category_screen.dart#L467) (column 50) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:468](../../lib/screens/admin/categories/add_category_screen.dart#L468) (column 50) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/categories/add_category_screen.dart:498](../../lib/screens/admin/categories/add_category_screen.dart#L498) (column 30) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:500](../../lib/screens/admin/categories/add_category_screen.dart#L500) (column 49) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:519](../../lib/screens/admin/categories/add_category_screen.dart#L519) (column 40) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:526](../../lib/screens/admin/categories/add_category_screen.dart#L526) (column 36) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:535](../../lib/screens/admin/categories/add_category_screen.dart#L535) (column 36) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:552](../../lib/screens/admin/categories/add_category_screen.dart#L552) (column 45) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:577](../../lib/screens/admin/categories/add_category_screen.dart#L577) (column 32) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:578](../../lib/screens/admin/categories/add_category_screen.dart#L578) (column 32) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/categories/add_category_screen.dart:592](../../lib/screens/admin/categories/add_category_screen.dart#L592) (column 34) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/categories/add_category_screen.dart:593](../../lib/screens/admin/categories/add_category_screen.dart#L593) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/categories/add_category_screen.dart:632](../../lib/screens/admin/categories/add_category_screen.dart#L632) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/categories/add_category_screen.dart:634](../../lib/screens/admin/categories/add_category_screen.dart#L634) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:637](../../lib/screens/admin/categories/add_category_screen.dart#L637) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/categories/add_category_screen.dart:649](../../lib/screens/admin/categories/add_category_screen.dart#L649) (column 22) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/categories/add_category_screen.dart:668](../../lib/screens/admin/categories/add_category_screen.dart#L668) (column 43) | `Color(0xFF334155)` | `#FF334155` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:675](../../lib/screens/admin/categories/add_category_screen.dart#L675) (column 30) | `Color(0xFFFFF7ED)` | `#FFFFF7ED` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:680](../../lib/screens/admin/categories/add_category_screen.dart#L680) (column 47) | `Color(0xFFB45309)` | `#FFB45309` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:687](../../lib/screens/admin/categories/add_category_screen.dart#L687) (column 24) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:697](../../lib/screens/admin/categories/add_category_screen.dart#L697) (column 56) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/add_category_screen.dart:713](../../lib/screens/admin/categories/add_category_screen.dart#L713) (column 22) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/categories/add_category_screen.dart:727](../../lib/screens/admin/categories/add_category_screen.dart#L727) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/categories/add_category_screen.dart:734](../../lib/screens/admin/categories/add_category_screen.dart#L734) (column 51) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/categories/add_category_screen.dart:738](../../lib/screens/admin/categories/add_category_screen.dart#L738) (column 51) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/categories/add_category_screen.dart:742](../../lib/screens/admin/categories/add_category_screen.dart#L742) (column 51) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |

### lib/screens/admin/categories/categories_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/categories/categories_screen.dart:154](../../lib/screens/admin/categories/categories_screen.dart#L154) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/categories/categories_screen.dart:156](../../lib/screens/admin/categories/categories_screen.dart#L156) (column 57) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:159](../../lib/screens/admin/categories/categories_screen.dart#L159) (column 36) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/categories/categories_screen.dart:183](../../lib/screens/admin/categories/categories_screen.dart#L183) (column 56) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/categories/categories_screen.dart:192](../../lib/screens/admin/categories/categories_screen.dart#L192) (column 56) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:213](../../lib/screens/admin/categories/categories_screen.dart#L213) (column 56) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/categories/categories_screen.dart:222](../../lib/screens/admin/categories/categories_screen.dart#L222) (column 56) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:234](../../lib/screens/admin/categories/categories_screen.dart#L234) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:249](../../lib/screens/admin/categories/categories_screen.dart#L249) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:267](../../lib/screens/admin/categories/categories_screen.dart#L267) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:275](../../lib/screens/admin/categories/categories_screen.dart#L275) (column 44) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:284](../../lib/screens/admin/categories/categories_screen.dart#L284) (column 44) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:313](../../lib/screens/admin/categories/categories_screen.dart#L313) (column 34) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/categories/categories_screen.dart:314](../../lib/screens/admin/categories/categories_screen.dart#L314) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/categories/categories_screen.dart:335](../../lib/screens/admin/categories/categories_screen.dart#L335) (column 61) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/categories/categories_screen.dart:366](../../lib/screens/admin/categories/categories_screen.dart#L366) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/categories/categories_screen.dart:373](../../lib/screens/admin/categories/categories_screen.dart#L373) (column 49) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/categories/categories_screen.dart:377](../../lib/screens/admin/categories/categories_screen.dart#L377) (column 49) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/categories/categories_screen.dart:381](../../lib/screens/admin/categories/categories_screen.dart#L381) (column 49) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/categories/categories_screen.dart:396](../../lib/screens/admin/categories/categories_screen.dart#L396) (column 22) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:450](../../lib/screens/admin/categories/categories_screen.dart#L450) (column 26) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:467](../../lib/screens/admin/categories/categories_screen.dart#L467) (column 50) | `Color(0xFFF1F5F9)` | `#FFF1F5F9` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:481](../../lib/screens/admin/categories/categories_screen.dart#L481) (column 42) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:485](../../lib/screens/admin/categories/categories_screen.dart#L485) (column 30) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/categories/categories_screen.dart:495](../../lib/screens/admin/categories/categories_screen.dart#L495) (column 28) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:512](../../lib/screens/admin/categories/categories_screen.dart#L512) (column 24) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:523](../../lib/screens/admin/categories/categories_screen.dart#L523) (column 24) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:548](../../lib/screens/admin/categories/categories_screen.dart#L548) (column 22) | `Color(0xFFFAFAFA)` | `#FFFAFAFA` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:550](../../lib/screens/admin/categories/categories_screen.dart#L550) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:561](../../lib/screens/admin/categories/categories_screen.dart#L561) (column 36) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:565](../../lib/screens/admin/categories/categories_screen.dart#L565) (column 24) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/categories/categories_screen.dart:579](../../lib/screens/admin/categories/categories_screen.dart#L579) (column 28) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:595](../../lib/screens/admin/categories/categories_screen.dart#L595) (column 34) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:603](../../lib/screens/admin/categories/categories_screen.dart#L603) (column 32) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:632](../../lib/screens/admin/categories/categories_screen.dart#L632) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:653](../../lib/screens/admin/categories/categories_screen.dart#L653) (column 22) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:655](../../lib/screens/admin/categories/categories_screen.dart#L655) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/categories/categories_screen.dart:660](../../lib/screens/admin/categories/categories_screen.dart#L660) (column 22) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |

### lib/screens/admin/customers/add_customer_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/customers/add_customer_screen.dart:988](../../lib/screens/admin/customers/add_customer_screen.dart#L988) (column 19) | `Color(0xFF0F5A00)` | `#FF0F5A00` | inline literal | — |
| [lib/screens/admin/customers/add_customer_screen.dart:1006](../../lib/screens/admin/customers/add_customer_screen.dart#L1006) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1008](../../lib/screens/admin/customers/add_customer_screen.dart#L1008) (column 41) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1013](../../lib/screens/admin/customers/add_customer_screen.dart#L1013) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1023](../../lib/screens/admin/customers/add_customer_screen.dart#L1023) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1032](../../lib/screens/admin/customers/add_customer_screen.dart#L1032) (column 37) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/admin/customers/add_customer_screen.dart:1044](../../lib/screens/admin/customers/add_customer_screen.dart#L1044) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1046](../../lib/screens/admin/customers/add_customer_screen.dart#L1046) (column 41) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1054](../../lib/screens/admin/customers/add_customer_screen.dart#L1054) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1098](../../lib/screens/admin/customers/add_customer_screen.dart#L1098) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1100](../../lib/screens/admin/customers/add_customer_screen.dart#L1100) (column 41) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/admin/customers/add_customer_screen.dart:1106](../../lib/screens/admin/customers/add_customer_screen.dart#L1106) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1114](../../lib/screens/admin/customers/add_customer_screen.dart#L1114) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1130](../../lib/screens/admin/customers/add_customer_screen.dart#L1130) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1132](../../lib/screens/admin/customers/add_customer_screen.dart#L1132) (column 35) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1140](../../lib/screens/admin/customers/add_customer_screen.dart#L1140) (column 22) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/admin/customers/add_customer_screen.dart:1149](../../lib/screens/admin/customers/add_customer_screen.dart#L1149) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1235](../../lib/screens/admin/customers/add_customer_screen.dart#L1235) (column 43) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/customers/add_customer_screen.dart:1253](../../lib/screens/admin/customers/add_customer_screen.dart#L1253) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1259](../../lib/screens/admin/customers/add_customer_screen.dart#L1259) (column 43) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1288](../../lib/screens/admin/customers/add_customer_screen.dart#L1288) (column 39) | `Color(0xFFD8DFE6)` | `#FFD8DFE6` | inline literal | — |
| [lib/screens/admin/customers/add_customer_screen.dart:1372](../../lib/screens/admin/customers/add_customer_screen.dart#L1372) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1388](../../lib/screens/admin/customers/add_customer_screen.dart#L1388) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1421](../../lib/screens/admin/customers/add_customer_screen.dart#L1421) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1753](../../lib/screens/admin/customers/add_customer_screen.dart#L1753) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:1939](../../lib/screens/admin/customers/add_customer_screen.dart#L1939) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2281](../../lib/screens/admin/customers/add_customer_screen.dart#L2281) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2283](../../lib/screens/admin/customers/add_customer_screen.dart#L2283) (column 41) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/customers/add_customer_screen.dart:2292](../../lib/screens/admin/customers/add_customer_screen.dart#L2292) (column 28) | `Color(0xFFFBFBFB)` | `#FFFBFBFB` | inline literal | — |
| [lib/screens/admin/customers/add_customer_screen.dart:2294](../../lib/screens/admin/customers/add_customer_screen.dart#L2294) (column 47) | `Color(0xFFE1E4E8)` | `#FFE1E4E8` | inline literal | — |
| [lib/screens/admin/customers/add_customer_screen.dart:2302](../../lib/screens/admin/customers/add_customer_screen.dart#L2302) (column 30) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |
| [lib/screens/admin/customers/add_customer_screen.dart:2342](../../lib/screens/admin/customers/add_customer_screen.dart#L2342) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2348](../../lib/screens/admin/customers/add_customer_screen.dart#L2348) (column 48) | `Color(0xFF8CAD84)` | `#FF8CAD84` | inline literal | — |
| [lib/screens/admin/customers/add_customer_screen.dart:2349](../../lib/screens/admin/customers/add_customer_screen.dart#L2349) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2369](../../lib/screens/admin/customers/add_customer_screen.dart#L2369) (column 48) | `Color(0xFF9CA3AF)` | `#FF9CA3AF` | inline literal | — |
| [lib/screens/admin/customers/add_customer_screen.dart:2370](../../lib/screens/admin/customers/add_customer_screen.dart#L2370) (column 55) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/customers/add_customer_screen.dart:2579](../../lib/screens/admin/customers/add_customer_screen.dart#L2579) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2685](../../lib/screens/admin/customers/add_customer_screen.dart#L2685) (column 39) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2687](../../lib/screens/admin/customers/add_customer_screen.dart#L2687) (column 41) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2692](../../lib/screens/admin/customers/add_customer_screen.dart#L2692) (column 23) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/customers/add_customer_screen.dart:2727](../../lib/screens/admin/customers/add_customer_screen.dart#L2727) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2743](../../lib/screens/admin/customers/add_customer_screen.dart#L2743) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2771](../../lib/screens/admin/customers/add_customer_screen.dart#L2771) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2933](../../lib/screens/admin/customers/add_customer_screen.dart#L2933) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:2963](../../lib/screens/admin/customers/add_customer_screen.dart#L2963) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:3020](../../lib/screens/admin/customers/add_customer_screen.dart#L3020) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/add_customer_screen.dart:3047](../../lib/screens/admin/customers/add_customer_screen.dart#L3047) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/customers/customer_details_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/customers/customer_details_screen.dart:382](../../lib/screens/admin/customers/customer_details_screen.dart#L382) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customer_details_screen.dart:460](../../lib/screens/admin/customers/customer_details_screen.dart#L460) (column 40) | `Color(0xFFF1F7EF)` | `#FFF1F7EF` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:498](../../lib/screens/admin/customers/customer_details_screen.dart#L498) (column 38) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:518](../../lib/screens/admin/customers/customer_details_screen.dart#L518) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customer_details_screen.dart:807](../../lib/screens/admin/customers/customer_details_screen.dart#L807) (column 30) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:952](../../lib/screens/admin/customers/customer_details_screen.dart#L952) (column 31) | `Color(0xFFE8F6E5)` | `#FFE8F6E5` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:960](../../lib/screens/admin/customers/customer_details_screen.dart#L960) (column 42) | `Color(0xFFEFF7EA)` | `#FFEFF7EA` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:976](../../lib/screens/admin/customers/customer_details_screen.dart#L976) (column 34) | `Color(0xFFEFF7EA)` | `#FFEFF7EA` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1004](../../lib/screens/admin/customers/customer_details_screen.dart#L1004) (column 24) | `Color(0xFFFFFFFF)` | `#FFFFFFFF` | inline literal | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customer_details_screen.dart:1004](../../lib/screens/admin/customers/customer_details_screen.dart#L1004) (column 43) | `Color(0xFFF7FBF4)` | `#FFF7FBF4` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1004](../../lib/screens/admin/customers/customer_details_screen.dart#L1004) (column 62) | `Color(0xFFF1F8EC)` | `#FFF1F8EC` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1009](../../lib/screens/admin/customers/customer_details_screen.dart#L1009) (column 45) | `Color(0xFFDDE8D8)` | `#FFDDE8D8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1012](../../lib/screens/admin/customers/customer_details_screen.dart#L1012) (column 30) | `Color(0xFF0A3C02)` | `#FF0A3C02` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1059](../../lib/screens/admin/customers/customer_details_screen.dart#L1059) (column 20) | `Color(0xFFF0F7E9)` | `#FFF0F7E9` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1059](../../lib/screens/admin/customers/customer_details_screen.dart#L1059) (column 39) | `Color(0xFFE2EFD8)` | `#FFE2EFD8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1301](../../lib/screens/admin/customers/customer_details_screen.dart#L1301) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customer_details_screen.dart:1306](../../lib/screens/admin/customers/customer_details_screen.dart#L1306) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1323](../../lib/screens/admin/customers/customer_details_screen.dart#L1323) (column 32) | `Color(0xFFF1F7EF)` | `#FFF1F7EF` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1364](../../lib/screens/admin/customers/customer_details_screen.dart#L1364) (column 21) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1410](../../lib/screens/admin/customers/customer_details_screen.dart#L1410) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customer_details_screen.dart:1415](../../lib/screens/admin/customers/customer_details_screen.dart#L1415) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1422](../../lib/screens/admin/customers/customer_details_screen.dart#L1422) (column 56) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1433](../../lib/screens/admin/customers/customer_details_screen.dart#L1433) (column 28) | `Color(0xFFF1F7EF)` | `#FFF1F7EF` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1658](../../lib/screens/admin/customers/customer_details_screen.dart#L1658) (column 22) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1709](../../lib/screens/admin/customers/customer_details_screen.dart#L1709) (column 24) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1745](../../lib/screens/admin/customers/customer_details_screen.dart#L1745) (column 24) | `Color(0xFFFFFBFA)` | `#FFFFFBFA` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1774](../../lib/screens/admin/customers/customer_details_screen.dart#L1774) (column 24) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:1804](../../lib/screens/admin/customers/customer_details_screen.dart#L1804) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customer_details_screen.dart:1862](../../lib/screens/admin/customers/customer_details_screen.dart#L1862) (column 22) | `Color(0xFFEFF7EA)` | `#FFEFF7EA` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2047](../../lib/screens/admin/customers/customer_details_screen.dart#L2047) (column 24) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2061](../../lib/screens/admin/customers/customer_details_screen.dart#L2061) (column 24) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2110](../../lib/screens/admin/customers/customer_details_screen.dart#L2110) (column 22) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2134](../../lib/screens/admin/customers/customer_details_screen.dart#L2134) (column 30) | `Colors.red` | `#FFF44336` | Flutter palette reference | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2251](../../lib/screens/admin/customers/customer_details_screen.dart#L2251) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customer_details_screen.dart:2317](../../lib/screens/admin/customers/customer_details_screen.dart#L2317) (column 17) | `Color(0xFF0A8F3D)` | `#FF0A8F3D` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2318](../../lib/screens/admin/customers/customer_details_screen.dart#L2318) (column 17) | `Color(0xFFC53030)` | `#FFC53030` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2325](../../lib/screens/admin/customers/customer_details_screen.dart#L2325) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customer_details_screen.dart:2330](../../lib/screens/admin/customers/customer_details_screen.dart#L2330) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2478](../../lib/screens/admin/customers/customer_details_screen.dart#L2478) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customer_details_screen.dart:2483](../../lib/screens/admin/customers/customer_details_screen.dart#L2483) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2508](../../lib/screens/admin/customers/customer_details_screen.dart#L2508) (column 35) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2529](../../lib/screens/admin/customers/customer_details_screen.dart#L2529) (column 33) | `Color(0xFFEFF7EA)` | `#FFEFF7EA` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2605](../../lib/screens/admin/customers/customer_details_screen.dart#L2605) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customer_details_screen.dart:2610](../../lib/screens/admin/customers/customer_details_screen.dart#L2610) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2670](../../lib/screens/admin/customers/customer_details_screen.dart#L2670) (column 35) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2683](../../lib/screens/admin/customers/customer_details_screen.dart#L2683) (column 18) | `Color(0xFF04844B)` | `#FF04844B` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2688](../../lib/screens/admin/customers/customer_details_screen.dart#L2688) (column 18) | `Color(0xFF1256F3)` | `#FF1256F3` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2691](../../lib/screens/admin/customers/customer_details_screen.dart#L2691) (column 18) | `Color(0xFFC53030)` | `#FFC53030` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2699](../../lib/screens/admin/customers/customer_details_screen.dart#L2699) (column 18) | `Color(0xFFE9F8EF)` | `#FFE9F8EF` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2704](../../lib/screens/admin/customers/customer_details_screen.dart#L2704) (column 18) | `Color(0xFFECF3FF)` | `#FFECF3FF` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2707](../../lib/screens/admin/customers/customer_details_screen.dart#L2707) (column 18) | `Color(0xFFFDECEC)` | `#FFFDECEC` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2709](../../lib/screens/admin/customers/customer_details_screen.dart#L2709) (column 16) | `Color(0xFFF4F6F8)` | `#FFF4F6F8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2786](../../lib/screens/admin/customers/customer_details_screen.dart#L2786) (column 22) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2808](../../lib/screens/admin/customers/customer_details_screen.dart#L2808) (column 22) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2855](../../lib/screens/admin/customers/customer_details_screen.dart#L2855) (column 22) | `Color(0xFFF2F5FA)` | `#FFF2F5FA` | inline literal | adminSidebarBg, surfaceSoft, deliveryBackground, deliveryBlueSoft, deliveryVioletSoft, deliveryVioletBadge, deliveryBlueBadge |
| [lib/screens/admin/customers/customer_details_screen.dart:2882](../../lib/screens/admin/customers/customer_details_screen.dart#L2882) (column 22) | `Color(0xFFF8FBF8)` | `#FFF8FBF8` | inline literal | — |
| [lib/screens/admin/customers/customer_details_screen.dart:2931](../../lib/screens/admin/customers/customer_details_screen.dart#L2931) (column 24) | `Color(0xFFF1F7EF)` | `#FFF1F7EF` | inline literal | — |

### lib/screens/admin/customers/customers_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/customers/customers_screen.dart:249](../../lib/screens/admin/customers/customers_screen.dart#L249) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customers_screen.dart:395](../../lib/screens/admin/customers/customers_screen.dart#L395) (column 48) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customers_screen.dart:554](../../lib/screens/admin/customers/customers_screen.dart#L554) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/customers/customers_screen.dart:681](../../lib/screens/admin/customers/customers_screen.dart#L681) (column 34) | `Color(0xFFF4F6F8)` | `#FFF4F6F8` | inline literal | — |
| [lib/screens/admin/customers/customers_screen.dart:901](../../lib/screens/admin/customers/customers_screen.dart#L901) (column 37) | `Color(0xFFF3F5F8)` | `#FFF3F5F8` | inline literal | — |
| [lib/screens/admin/customers/customers_screen.dart:940](../../lib/screens/admin/customers/customers_screen.dart#L940) (column 25) | `Color(0xFFF3F5F8)` | `#FFF3F5F8` | inline literal | — |
| [lib/screens/admin/customers/customers_screen.dart:1028](../../lib/screens/admin/customers/customers_screen.dart#L1028) (column 34) | `Color(0xFFF3F5F8)` | `#FFF3F5F8` | inline literal | — |
| [lib/screens/admin/customers/customers_screen.dart:1036](../../lib/screens/admin/customers/customers_screen.dart#L1036) (column 34) | `Color(0xFFF3F5F8)` | `#FFF3F5F8` | inline literal | — |
| [lib/screens/admin/customers/customers_screen.dart:1044](../../lib/screens/admin/customers/customers_screen.dart#L1044) (column 34) | `Color(0xFFFFEBEB)` | `#FFFFEBEB` | inline literal | — |
| [lib/screens/admin/customers/customers_screen.dart:1216](../../lib/screens/admin/customers/customers_screen.dart#L1216) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/dashboard/admin_dashboard_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:57](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L57) (column 31) | `Color(0xFF08763A)` | `#FF08763A` | local definition: _green | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:58](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L58) (column 35) | `Color(0xFF00451F)` | `#FF00451F` | local definition: _darkGreen | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:59](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L59) (column 30) | `Color(0xFF56D36F)` | `#FF56D36F` | local definition: _lime | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:60](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L60) (column 29) | `Color(0xFFFF4B4B)` | `#FFFF4B4B` | local definition: _red | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:61](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L61) (column 30) | `Color(0xFF3168FF)` | `#FF3168FF` | local definition: _blue | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:62](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L62) (column 32) | `Color(0xFFFF9F1C)` | `#FFFF9F1C` | local definition: _orange | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:63](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L63) (column 32) | `Color(0xFF7C3EFF)` | `#FF7C3EFF` | local definition: _violet | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:64](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L64) (column 30) | `Color(0xFF009688)` | `#FF009688` | local definition: _teal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:200](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L200) (column 30) | `Color(0xFFFBFCFB)` | `#FFFBFCFB` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:248](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L248) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:250](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L250) (column 41) | `Color(0xFFE8ECEF)` | `#FFE8ECEF` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:253](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L253) (column 20) | `Color(0x10000000)` | `#10000000` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:292](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L292) (column 56) | `Color(0xFFE7EBEE)` | `#FFE7EBEE` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:301](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L301) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:382](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L382) (column 32) | `Color(0xFF00662F)` | `#FF00662F` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:382](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L382) (column 51) | `Color(0xFF064B26)` | `#FF064B26` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:389](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L389) (column 20) | `Color(0x33005225)` | `#33005225` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:403](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L403) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:412](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L412) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:421](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L421) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:438](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L438) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:455](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L455) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:464](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L464) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:478](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L478) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:485](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L485) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:488](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L488) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:519](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L519) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:527](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L527) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:543](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L543) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:552](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L552) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:564](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L564) (column 12) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:616](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L616) (column 15) | `Color(0xFFE91E63)` | `#FFE91E63` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:761](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L761) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:773](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L773) (column 57) | `Color(0xFFE9EDF0)` | `#FFE9EDF0` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:890](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L890) (column 55) | `Color(0xFFE9EDF0)` | `#FFE9EDF0` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:898](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L898) (column 42) | `Color(0xFFF2F4F3)` | `#FFF2F4F3` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:943](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L943) (column 58) | `Color(0xFFE9EDF0)` | `#FFE9EDF0` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1226](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1226) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1280](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1280) (column 49) | `Color(0xFFE9EDF0)` | `#FFE9EDF0` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1435](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1435) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1444](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1444) (column 53) | `Color(0xFFE7EBEF)` | `#FFE7EBEF` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1545](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1545) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1547](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1547) (column 41) | `Color(0xFFE7EBEF)` | `#FFE7EBEF` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1550](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1550) (column 20) | `Color(0x0D000000)` | `#0D000000` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1673](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1673) (column 42) | `Color(0xFFE7EBEF)` | `#FFE7EBEF` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1690](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1690) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1692](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1692) (column 61) | `Color(0xFFE1E5E8)` | `#FFE1E5E8` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1697](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1697) (column 29) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1770](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1770) (column 22) | `Color(0xFFFFF8E7)` | `#FFFFF8E7` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1772](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1772) (column 41) | `Color(0xFFFFE2A8)` | `#FFFFE2A8` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1815](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1815) (column 22) | `Color(0xFFF0F3F2)` | `#FFF0F3F2` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1851](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1851) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:1998](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L1998) (column 23) | `Color(0xFFE2E6EA)` | `#FFE2E6EA` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:2080](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L2080) (column 23) | `Color(0xFFE2E6EA)` | `#FFE2E6EA` | inline literal | — |
| [lib/screens/admin/dashboard/admin_dashboard_screen.dart:2114](../../lib/screens/admin/dashboard/admin_dashboard_screen.dart#L2114) (column 59) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/inventory/inventory_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/inventory/inventory_screen.dart:507](../../lib/screens/admin/inventory/inventory_screen.dart#L507) (column 41) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/inventory/inventory_screen.dart:517](../../lib/screens/admin/inventory/inventory_screen.dart#L517) (column 29) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/invoices/invoices_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/invoices/invoices_screen.dart:379](../../lib/screens/admin/invoices/invoices_screen.dart#L379) (column 49) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/invoices/invoices_screen.dart:386](../../lib/screens/admin/invoices/invoices_screen.dart#L386) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/leads/admin_leads_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/leads/admin_leads_screen.dart:351](../../lib/screens/admin/leads/admin_leads_screen.dart#L351) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/leads/admin_leads_screen.dart:472](../../lib/screens/admin/leads/admin_leads_screen.dart#L472) (column 48) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/leads/admin_leads_screen.dart:661](../../lib/screens/admin/leads/admin_leads_screen.dart#L661) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/leads/admin_leads_screen.dart:666](../../lib/screens/admin/leads/admin_leads_screen.dart#L666) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/leads/admin_leads_screen.dart:814](../../lib/screens/admin/leads/admin_leads_screen.dart#L814) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/leads/admin_leads_screen.dart:819](../../lib/screens/admin/leads/admin_leads_screen.dart#L819) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/leads/admin_leads_screen.dart:833](../../lib/screens/admin/leads/admin_leads_screen.dart#L833) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/leads/admin_leads_screen.dart:845](../../lib/screens/admin/leads/admin_leads_screen.dart#L845) (column 28) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/admin/leads/admin_leads_screen.dart:855](../../lib/screens/admin/leads/admin_leads_screen.dart#L855) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/leads/admin_leads_screen.dart:969](../../lib/screens/admin/leads/admin_leads_screen.dart#L969) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/leads/admin_leads_screen.dart:1013](../../lib/screens/admin/leads/admin_leads_screen.dart#L1013) (column 28) | `Color(0xFF586176)` | `#FF586176` | inline literal | — |
| [lib/screens/admin/leads/admin_leads_screen.dart:1136](../../lib/screens/admin/leads/admin_leads_screen.dart#L1136) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/leads/admin_leads_screen.dart:1216](../../lib/screens/admin/leads/admin_leads_screen.dart#L1216) (column 43) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/leads/admin_leads_screen.dart:1310](../../lib/screens/admin/leads/admin_leads_screen.dart#L1310) (column 14) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/leads/admin_leads_screen.dart:1459](../../lib/screens/admin/leads/admin_leads_screen.dart#L1459) (column 40) | `Color(0xFF25D366)` | `#FF25D366` | inline literal | — |
| [lib/screens/admin/leads/admin_leads_screen.dart:1460](../../lib/screens/admin/leads/admin_leads_screen.dart#L1460) (column 45) | `Color(0xFFEDFBF0)` | `#FFEDFBF0` | inline literal | — |
| [lib/screens/admin/leads/admin_leads_screen.dart:1663](../../lib/screens/admin/leads/admin_leads_screen.dart#L1663) (column 24) | `Color(0x080F172A)` | `#080F172A` | inline literal | — |
| [lib/screens/admin/leads/admin_leads_screen.dart:1728](../../lib/screens/admin/leads/admin_leads_screen.dart#L1728) (column 38) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/orders/admin_orders_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/orders/admin_orders_screen.dart:85](../../lib/screens/admin/orders/admin_orders_screen.dart#L85) (column 7) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:91](../../lib/screens/admin/orders/admin_orders_screen.dart#L91) (column 7) | `Color(0xFFF59E0B)` | `#FFF59E0B` | inline literal | amber, deliveryYellow |
| [lib/screens/admin/orders/admin_orders_screen.dart:97](../../lib/screens/admin/orders/admin_orders_screen.dart#L97) (column 7) | `Color(0xFF22C55E)` | `#FF22C55E` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:103](../../lib/screens/admin/orders/admin_orders_screen.dart#L103) (column 7) | `Color(0xFFEF4444)` | `#FFEF4444` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:115](../../lib/screens/admin/orders/admin_orders_screen.dart#L115) (column 21) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:116](../../lib/screens/admin/orders/admin_orders_screen.dart#L116) (column 26) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:118](../../lib/screens/admin/orders/admin_orders_screen.dart#L118) (column 20) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:119](../../lib/screens/admin/orders/admin_orders_screen.dart#L119) (column 25) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:129](../../lib/screens/admin/orders/admin_orders_screen.dart#L129) (column 21) | `Color(0xFFF59E0B)` | `#FFF59E0B` | inline literal | amber, deliveryYellow |
| [lib/screens/admin/orders/admin_orders_screen.dart:130](../../lib/screens/admin/orders/admin_orders_screen.dart#L130) (column 26) | `Color(0xFFFFF7E6)` | `#FFFFF7E6` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:132](../../lib/screens/admin/orders/admin_orders_screen.dart#L132) (column 20) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:133](../../lib/screens/admin/orders/admin_orders_screen.dart#L133) (column 25) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:143](../../lib/screens/admin/orders/admin_orders_screen.dart#L143) (column 21) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:144](../../lib/screens/admin/orders/admin_orders_screen.dart#L144) (column 26) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:146](../../lib/screens/admin/orders/admin_orders_screen.dart#L146) (column 20) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:147](../../lib/screens/admin/orders/admin_orders_screen.dart#L147) (column 25) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:157](../../lib/screens/admin/orders/admin_orders_screen.dart#L157) (column 21) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:158](../../lib/screens/admin/orders/admin_orders_screen.dart#L158) (column 26) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:160](../../lib/screens/admin/orders/admin_orders_screen.dart#L160) (column 20) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:161](../../lib/screens/admin/orders/admin_orders_screen.dart#L161) (column 25) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:171](../../lib/screens/admin/orders/admin_orders_screen.dart#L171) (column 21) | `Color(0xFFEF4444)` | `#FFEF4444` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:172](../../lib/screens/admin/orders/admin_orders_screen.dart#L172) (column 26) | `Color(0xFFFEE2E2)` | `#FFFEE2E2` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:174](../../lib/screens/admin/orders/admin_orders_screen.dart#L174) (column 20) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:175](../../lib/screens/admin/orders/admin_orders_screen.dart#L175) (column 25) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:185](../../lib/screens/admin/orders/admin_orders_screen.dart#L185) (column 21) | `Color(0xFFF59E0B)` | `#FFF59E0B` | inline literal | amber, deliveryYellow |
| [lib/screens/admin/orders/admin_orders_screen.dart:186](../../lib/screens/admin/orders/admin_orders_screen.dart#L186) (column 26) | `Color(0xFFFFF7E6)` | `#FFFFF7E6` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:188](../../lib/screens/admin/orders/admin_orders_screen.dart#L188) (column 20) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:189](../../lib/screens/admin/orders/admin_orders_screen.dart#L189) (column 25) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:199](../../lib/screens/admin/orders/admin_orders_screen.dart#L199) (column 21) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:200](../../lib/screens/admin/orders/admin_orders_screen.dart#L200) (column 26) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:202](../../lib/screens/admin/orders/admin_orders_screen.dart#L202) (column 20) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:203](../../lib/screens/admin/orders/admin_orders_screen.dart#L203) (column 25) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:231](../../lib/screens/admin/orders/admin_orders_screen.dart#L231) (column 15) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:240](../../lib/screens/admin/orders/admin_orders_screen.dart#L240) (column 15) | `Color(0xFFF59E0B)` | `#FFF59E0B` | inline literal | amber, deliveryYellow |
| [lib/screens/admin/orders/admin_orders_screen.dart:246](../../lib/screens/admin/orders/admin_orders_screen.dart#L246) (column 15) | `Color(0xFF22C55E)` | `#FF22C55E` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:252](../../lib/screens/admin/orders/admin_orders_screen.dart#L252) (column 15) | `Color(0xFFEF4444)` | `#FFEF4444` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:554](../../lib/screens/admin/orders/admin_orders_screen.dart#L554) (column 19) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:861](../../lib/screens/admin/orders/admin_orders_screen.dart#L861) (column 42) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:862](../../lib/screens/admin/orders/admin_orders_screen.dart#L862) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:864](../../lib/screens/admin/orders/admin_orders_screen.dart#L864) (column 38) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:902](../../lib/screens/admin/orders/admin_orders_screen.dart#L902) (column 40) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:903](../../lib/screens/admin/orders/admin_orders_screen.dart#L903) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:905](../../lib/screens/admin/orders/admin_orders_screen.dart#L905) (column 36) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:944](../../lib/screens/admin/orders/admin_orders_screen.dart#L944) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:946](../../lib/screens/admin/orders/admin_orders_screen.dart#L946) (column 45) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:949](../../lib/screens/admin/orders/admin_orders_screen.dart#L949) (column 24) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:984](../../lib/screens/admin/orders/admin_orders_screen.dart#L984) (column 53) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:1014](../../lib/screens/admin/orders/admin_orders_screen.dart#L1014) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:1016](../../lib/screens/admin/orders/admin_orders_screen.dart#L1016) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1019](../../lib/screens/admin/orders/admin_orders_screen.dart#L1019) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1066](../../lib/screens/admin/orders/admin_orders_screen.dart#L1066) (column 53) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1123](../../lib/screens/admin/orders/admin_orders_screen.dart#L1123) (column 35) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:1135](../../lib/screens/admin/orders/admin_orders_screen.dart#L1135) (column 34) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:1220](../../lib/screens/admin/orders/admin_orders_screen.dart#L1220) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:1222](../../lib/screens/admin/orders/admin_orders_screen.dart#L1222) (column 41) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/orders/admin_orders_screen.dart:1231](../../lib/screens/admin/orders/admin_orders_screen.dart#L1231) (column 28) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:1234](../../lib/screens/admin/orders/admin_orders_screen.dart#L1234) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:1237](../../lib/screens/admin/orders/admin_orders_screen.dart#L1237) (column 20) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1252](../../lib/screens/admin/orders/admin_orders_screen.dart#L1252) (column 49) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:1268](../../lib/screens/admin/orders/admin_orders_screen.dart#L1268) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:1270](../../lib/screens/admin/orders/admin_orders_screen.dart#L1270) (column 41) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/orders/admin_orders_screen.dart:1285](../../lib/screens/admin/orders/admin_orders_screen.dart#L1285) (column 20) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1324](../../lib/screens/admin/orders/admin_orders_screen.dart#L1324) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:1327](../../lib/screens/admin/orders/admin_orders_screen.dart#L1327) (column 39) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1337](../../lib/screens/admin/orders/admin_orders_screen.dart#L1337) (column 31) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:1353](../../lib/screens/admin/orders/admin_orders_screen.dart#L1353) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:1356](../../lib/screens/admin/orders/admin_orders_screen.dart#L1356) (column 39) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1365](../../lib/screens/admin/orders/admin_orders_screen.dart#L1365) (column 27) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:1378](../../lib/screens/admin/orders/admin_orders_screen.dart#L1378) (column 29) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/orders/admin_orders_screen.dart:1390](../../lib/screens/admin/orders/admin_orders_screen.dart#L1390) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:1392](../../lib/screens/admin/orders/admin_orders_screen.dart#L1392) (column 43) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/orders/admin_orders_screen.dart:1407](../../lib/screens/admin/orders/admin_orders_screen.dart#L1407) (column 22) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1424](../../lib/screens/admin/orders/admin_orders_screen.dart#L1424) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:1426](../../lib/screens/admin/orders/admin_orders_screen.dart#L1426) (column 41) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/orders/admin_orders_screen.dart:1445](../../lib/screens/admin/orders/admin_orders_screen.dart#L1445) (column 22) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1461](../../lib/screens/admin/orders/admin_orders_screen.dart#L1461) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1494](../../lib/screens/admin/orders/admin_orders_screen.dart#L1494) (column 37) | `Color(0xFF6B7280)` | `#FF6B7280` | inline literal | accentGrey, textMuted |
| [lib/screens/admin/orders/admin_orders_screen.dart:1646](../../lib/screens/admin/orders/admin_orders_screen.dart#L1646) (column 41) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1649](../../lib/screens/admin/orders/admin_orders_screen.dart#L1649) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1688](../../lib/screens/admin/orders/admin_orders_screen.dart#L1688) (column 34) | `Color(0xFF4F5870)` | `#FF4F5870` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1702](../../lib/screens/admin/orders/admin_orders_screen.dart#L1702) (column 26) | `Color(0xFF31394D)` | `#FF31394D` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1736](../../lib/screens/admin/orders/admin_orders_screen.dart#L1736) (column 43) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1739](../../lib/screens/admin/orders/admin_orders_screen.dart#L1739) (column 22) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:1841](../../lib/screens/admin/orders/admin_orders_screen.dart#L1841) (column 48) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2141](../../lib/screens/admin/orders/admin_orders_screen.dart#L2141) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:2143](../../lib/screens/admin/orders/admin_orders_screen.dart#L2143) (column 43) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2146](../../lib/screens/admin/orders/admin_orders_screen.dart#L2146) (column 22) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2235](../../lib/screens/admin/orders/admin_orders_screen.dart#L2235) (column 20) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2341](../../lib/screens/admin/orders/admin_orders_screen.dart#L2341) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2396](../../lib/screens/admin/orders/admin_orders_screen.dart#L2396) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/orders/admin_orders_screen.dart:2400](../../lib/screens/admin/orders/admin_orders_screen.dart#L2400) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2771](../../lib/screens/admin/orders/admin_orders_screen.dart#L2771) (column 32) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2771](../../lib/screens/admin/orders/admin_orders_screen.dart#L2771) (column 51) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2773](../../lib/screens/admin/orders/admin_orders_screen.dart#L2773) (column 32) | `Color(0xFFF59E0B)` | `#FFF59E0B` | inline literal | amber, deliveryYellow |
| [lib/screens/admin/orders/admin_orders_screen.dart:2773](../../lib/screens/admin/orders/admin_orders_screen.dart#L2773) (column 51) | `Color(0xFFFFF7E6)` | `#FFFFF7E6` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2775](../../lib/screens/admin/orders/admin_orders_screen.dart#L2775) (column 32) | `Color(0xFFEF4444)` | `#FFEF4444` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2775](../../lib/screens/admin/orders/admin_orders_screen.dart#L2775) (column 51) | `Color(0xFFFEE2E2)` | `#FFFEE2E2` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2782](../../lib/screens/admin/orders/admin_orders_screen.dart#L2782) (column 30) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2782](../../lib/screens/admin/orders/admin_orders_screen.dart#L2782) (column 49) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2785](../../lib/screens/admin/orders/admin_orders_screen.dart#L2785) (column 30) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2785](../../lib/screens/admin/orders/admin_orders_screen.dart#L2785) (column 49) | `Color(0xFFEFF6FF)` | `#FFEFF6FF` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2788](../../lib/screens/admin/orders/admin_orders_screen.dart#L2788) (column 30) | `Color(0xFFF59E0B)` | `#FFF59E0B` | inline literal | amber, deliveryYellow |
| [lib/screens/admin/orders/admin_orders_screen.dart:2788](../../lib/screens/admin/orders/admin_orders_screen.dart#L2788) (column 49) | `Color(0xFFFFF7E6)` | `#FFFFF7E6` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2791](../../lib/screens/admin/orders/admin_orders_screen.dart#L2791) (column 30) | `Color(0xFFEF4444)` | `#FFEF4444` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2791](../../lib/screens/admin/orders/admin_orders_screen.dart#L2791) (column 49) | `Color(0xFFFEE2E2)` | `#FFFEE2E2` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2794](../../lib/screens/admin/orders/admin_orders_screen.dart#L2794) (column 30) | `Color(0xFF7C3AED)` | `#FF7C3AED` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2794](../../lib/screens/admin/orders/admin_orders_screen.dart#L2794) (column 49) | `Color(0xFFF3E8FF)` | `#FFF3E8FF` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2796](../../lib/screens/admin/orders/admin_orders_screen.dart#L2796) (column 28) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/orders/admin_orders_screen.dart:2796](../../lib/screens/admin/orders/admin_orders_screen.dart#L2796) (column 47) | `Color(0xFFF1F5F9)` | `#FFF1F5F9` | inline literal | — |

### lib/screens/admin/orders/order_detail_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/orders/order_detail_screen.dart:843](../../lib/screens/admin/orders/order_detail_screen.dart#L843) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/products/products_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/products/products_screen.dart:488](../../lib/screens/admin/products/products_screen.dart#L488) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/products/products_screen.dart:992](../../lib/screens/admin/products/products_screen.dart#L992) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/products/products_screen.dart:1552](../../lib/screens/admin/products/products_screen.dart#L1552) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/profile/admin_profile_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/profile/admin_profile_screen.dart:184](../../lib/screens/admin/profile/admin_profile_screen.dart#L184) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/purchases/purchases_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/purchases/purchases_screen.dart:226](../../lib/screens/admin/purchases/purchases_screen.dart#L226) (column 46) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/purchases/purchases_screen.dart:894](../../lib/screens/admin/purchases/purchases_screen.dart#L894) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/quotations/admin_quotations_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:76](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L76) (column 20) | `Color(0xFF6B7280)` | `#FF6B7280` | inline literal | accentGrey, textMuted |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:77](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L77) (column 25) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:89](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L89) (column 20) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:90](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L90) (column 25) | `Color(0xFFEFF6FF)` | `#FFEFF6FF` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:400](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L400) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:469](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L469) (column 42) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:470](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L470) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:487](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L487) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:492](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L492) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:500](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L500) (column 26) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:509](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L509) (column 26) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:524](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L524) (column 61) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:569](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L569) (column 46) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:570](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L570) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:589](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L589) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:611](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L611) (column 32) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:621](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L621) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:629](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L629) (column 26) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:638](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L638) (column 26) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:657](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L657) (column 61) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:659](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L659) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:666](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L666) (column 47) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:670](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L670) (column 47) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:674](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L674) (column 47) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:697](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L697) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:704](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L704) (column 47) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:708](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L708) (column 47) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:712](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L712) (column 47) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:717](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L717) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:727](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L727) (column 26) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:752](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L752) (column 22) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:808](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L808) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:810](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L810) (column 41) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:814](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L814) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:826](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L826) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:835](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L835) (column 28) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:847](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L847) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:855](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L855) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:862](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L862) (column 43) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1020](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1020) (column 21) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1021](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1021) (column 25) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1022](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1022) (column 25) | `Color(0xFFDC2626)` | `#FFDC2626` | inline literal | statusInactiveText, red, deliveryRed |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1023](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1023) (column 16) | `Color(0xFF6B7280)` | `#FF6B7280` | inline literal | accentGrey, textMuted |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1029](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1029) (column 21) | `Color(0xFFEFF6FF)` | `#FFEFF6FF` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1030](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1030) (column 25) | `Color(0xFFE8F8EE)` | `#FFE8F8EE` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1031](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1031) (column 25) | `Color(0xFFFEE2E2)` | `#FFFEE2E2` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1032](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1032) (column 16) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1207](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1207) (column 34) | `Color(0xFFF3F5F8)` | `#FFF3F5F8` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1215](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1215) (column 34) | `Color(0xFFF3F5F8)` | `#FFF3F5F8` | inline literal | — |
| [lib/screens/admin/quotations/admin_quotations_screen.dart:1223](../../lib/screens/admin/quotations/admin_quotations_screen.dart#L1223) (column 34) | `Color(0xFFFFEBEB)` | `#FFFFEBEB` | inline literal | — |

### lib/screens/admin/quotations/create_quotation_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/quotations/create_quotation_screen.dart:190](../../lib/screens/admin/quotations/create_quotation_screen.dart#L190) (column 21) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:406](../../lib/screens/admin/quotations/create_quotation_screen.dart#L406) (column 30) | `Color(0xFFF6F8FC)` | `#FFF6F8FC` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:497](../../lib/screens/admin/quotations/create_quotation_screen.dart#L497) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:502](../../lib/screens/admin/quotations/create_quotation_screen.dart#L502) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:520](../../lib/screens/admin/quotations/create_quotation_screen.dart#L520) (column 33) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:522](../../lib/screens/admin/quotations/create_quotation_screen.dart#L522) (column 45) | `Color(0xFF284BFF)` | `#FF284BFF` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:531](../../lib/screens/admin/quotations/create_quotation_screen.dart#L531) (column 39) | `Color(0xFF284BFF)` | `#FF284BFF` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:532](../../lib/screens/admin/quotations/create_quotation_screen.dart#L532) (column 33) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:536](../../lib/screens/admin/quotations/create_quotation_screen.dart#L536) (column 41) | `Color(0xFF284BFF)` | `#FF284BFF` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:545](../../lib/screens/admin/quotations/create_quotation_screen.dart#L545) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:551](../../lib/screens/admin/quotations/create_quotation_screen.dart#L551) (column 43) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:563](../../lib/screens/admin/quotations/create_quotation_screen.dart#L563) (column 33) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:565](../../lib/screens/admin/quotations/create_quotation_screen.dart#L565) (column 45) | `Color(0xFF284BFF)` | `#FF284BFF` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:576](../../lib/screens/admin/quotations/create_quotation_screen.dart#L576) (column 35) | `Color(0xFF1234D8)` | `#FF1234D8` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:613](../../lib/screens/admin/quotations/create_quotation_screen.dart#L613) (column 60) | `Color(0xFF284BFF)` | `#FF284BFF` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:836](../../lib/screens/admin/quotations/create_quotation_screen.dart#L836) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:840](../../lib/screens/admin/quotations/create_quotation_screen.dart#L840) (column 22) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:869](../../lib/screens/admin/quotations/create_quotation_screen.dart#L869) (column 42) | `Color(0xFF284BFF)` | `#FF284BFF` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:870](../../lib/screens/admin/quotations/create_quotation_screen.dart#L870) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1001](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1001) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1007](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1007) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1053](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1053) (column 46) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1142](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1142) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1148](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1148) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1152](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1152) (column 22) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1220](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1220) (column 46) | `Color(0xFF284BFF)` | `#FF284BFF` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1221](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1221) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1246](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1246) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1251](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1251) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1294](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1294) (column 22) | `Color(0xFFF1F5F9)` | `#FFF1F5F9` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1339](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1339) (column 35) | `Color(0xFF284BFF)` | `#FF284BFF` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1339](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1339) (column 55) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1346](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1346) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1388](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1388) (column 28) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1503](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1503) (column 22) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1541](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1541) (column 38) | `Color(0xFF284BFF)` | `#FF284BFF` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1542](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1542) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1570](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1570) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1621](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1621) (column 22) | `Color(0xFFEF4444)` | `#FFEF4444` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1646](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1646) (column 24) | `Color(0xFFF1F5F9)` | `#FFF1F5F9` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1757](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1757) (column 22) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1820](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1820) (column 13) | `Color(0xFFE0F2FE)` | `#FFE0F2FE` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1821](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1821) (column 13) | `Color(0xFFDCFCE7)` | `#FFDCFCE7` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1822](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1822) (column 13) | `Color(0xFFFFEDD5)` | `#FFFFEDD5` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1823](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1823) (column 13) | `Color(0xFFF3E8FF)` | `#FFF3E8FF` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:1852](../../lib/screens/admin/quotations/create_quotation_screen.dart#L1852) (column 22) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:2065](../../lib/screens/admin/quotations/create_quotation_screen.dart#L2065) (column 22) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/quotations/create_quotation_screen.dart:2077](../../lib/screens/admin/quotations/create_quotation_screen.dart#L2077) (column 43) | `Color(0xFF284BFF)` | `#FF284BFF` | inline literal | — |

### lib/screens/admin/quotations/quotation_detail_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:497](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L497) (column 26) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:513](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L513) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:516](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L516) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:521](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L521) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:538](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L538) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:546](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L546) (column 39) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:554](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L554) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:887](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L887) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:1045](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L1045) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:1047](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L1047) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:1611](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L1611) (column 21) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:1612](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L1612) (column 25) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:1613](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L1613) (column 25) | `Color(0xFFDC2626)` | `#FFDC2626` | inline literal | statusInactiveText, red, deliveryRed |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:1614](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L1614) (column 26) | `Color(0xFF7C3AED)` | `#FF7C3AED` | inline literal | — |
| [lib/screens/admin/quotations/quotation_detail_screen.dart:1615](../../lib/screens/admin/quotations/quotation_detail_screen.dart#L1615) (column 16) | `Color(0xFF6B7280)` | `#FF6B7280` | inline literal | accentGrey, textMuted |

### lib/screens/admin/reports/reports_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/reports/reports_screen.dart:159](../../lib/screens/admin/reports/reports_screen.dart#L159) (column 46) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/reports/reports_screen.dart:453](../../lib/screens/admin/reports/reports_screen.dart#L453) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/roles/new_role_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/roles/new_role_screen.dart:176](../../lib/screens/admin/roles/new_role_screen.dart#L176) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/roles/new_role_screen.dart:178](../../lib/screens/admin/roles/new_role_screen.dart#L178) (column 57) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:181](../../lib/screens/admin/roles/new_role_screen.dart#L181) (column 36) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/roles/new_role_screen.dart:207](../../lib/screens/admin/roles/new_role_screen.dart#L207) (column 60) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/roles/new_role_screen.dart:216](../../lib/screens/admin/roles/new_role_screen.dart#L216) (column 60) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:256](../../lib/screens/admin/roles/new_role_screen.dart#L256) (column 56) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/roles/new_role_screen.dart:265](../../lib/screens/admin/roles/new_role_screen.dart#L265) (column 56) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:292](../../lib/screens/admin/roles/new_role_screen.dart#L292) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:298](../../lib/screens/admin/roles/new_role_screen.dart#L298) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:306](../../lib/screens/admin/roles/new_role_screen.dart#L306) (column 44) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/roles/new_role_screen.dart:327](../../lib/screens/admin/roles/new_role_screen.dart#L327) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:337](../../lib/screens/admin/roles/new_role_screen.dart#L337) (column 60) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:354](../../lib/screens/admin/roles/new_role_screen.dart#L354) (column 60) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/roles/new_role_screen.dart:355](../../lib/screens/admin/roles/new_role_screen.dart#L355) (column 54) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/roles/new_role_screen.dart:489](../../lib/screens/admin/roles/new_role_screen.dart#L489) (column 20) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/roles/new_role_screen.dart:502](../../lib/screens/admin/roles/new_role_screen.dart#L502) (column 30) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:505](../../lib/screens/admin/roles/new_role_screen.dart#L505) (column 51) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:509](../../lib/screens/admin/roles/new_role_screen.dart#L509) (column 51) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:514](../../lib/screens/admin/roles/new_role_screen.dart#L514) (column 24) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/roles/new_role_screen.dart:536](../../lib/screens/admin/roles/new_role_screen.dart#L536) (column 20) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/roles/new_role_screen.dart:546](../../lib/screens/admin/roles/new_role_screen.dart#L546) (column 30) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:549](../../lib/screens/admin/roles/new_role_screen.dart#L549) (column 51) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:553](../../lib/screens/admin/roles/new_role_screen.dart#L553) (column 51) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:558](../../lib/screens/admin/roles/new_role_screen.dart#L558) (column 24) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/roles/new_role_screen.dart:580](../../lib/screens/admin/roles/new_role_screen.dart#L580) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:585](../../lib/screens/admin/roles/new_role_screen.dart#L585) (column 43) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:590](../../lib/screens/admin/roles/new_role_screen.dart#L590) (column 49) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:601](../../lib/screens/admin/roles/new_role_screen.dart#L601) (column 20) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:610](../../lib/screens/admin/roles/new_role_screen.dart#L610) (column 24) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:623](../../lib/screens/admin/roles/new_role_screen.dart#L623) (column 26) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:641](../../lib/screens/admin/roles/new_role_screen.dart#L641) (column 30) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:651](../../lib/screens/admin/roles/new_role_screen.dart#L651) (column 28) | `Color(0xFFCBD5E1)` | `#FFCBD5E1` | inline literal | — |
| [lib/screens/admin/roles/new_role_screen.dart:664](../../lib/screens/admin/roles/new_role_screen.dart#L664) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/roles/new_role_screen.dart:673](../../lib/screens/admin/roles/new_role_screen.dart#L673) (column 24) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/roles/new_role_screen.dart:686](../../lib/screens/admin/roles/new_role_screen.dart#L686) (column 36) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/roles/new_role_screen.dart:701](../../lib/screens/admin/roles/new_role_screen.dart#L701) (column 38) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |

### lib/screens/admin/roles/roles_permissions_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/roles/roles_permissions_screen.dart:31](../../lib/screens/admin/roles/roles_permissions_screen.dart#L31) (column 20) | `Color(0xFF1F6D2A)` | `#FF1F6D2A` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:38](../../lib/screens/admin/roles/roles_permissions_screen.dart#L38) (column 20) | `Color(0xFF1F6D2A)` | `#FF1F6D2A` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:45](../../lib/screens/admin/roles/roles_permissions_screen.dart#L45) (column 20) | `Color(0xFF1F6D2A)` | `#FF1F6D2A` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:52](../../lib/screens/admin/roles/roles_permissions_screen.dart#L52) (column 20) | `Color(0xFF1F6D2A)` | `#FF1F6D2A` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:92](../../lib/screens/admin/roles/roles_permissions_screen.dart#L92) (column 32) | `Color(0xFF1F6D2A)` | `#FF1F6D2A` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:140](../../lib/screens/admin/roles/roles_permissions_screen.dart#L140) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/roles/roles_permissions_screen.dart:142](../../lib/screens/admin/roles/roles_permissions_screen.dart#L142) (column 57) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:145](../../lib/screens/admin/roles/roles_permissions_screen.dart#L145) (column 36) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:164](../../lib/screens/admin/roles/roles_permissions_screen.dart#L164) (column 50) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/roles/roles_permissions_screen.dart:173](../../lib/screens/admin/roles/roles_permissions_screen.dart#L173) (column 50) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:200](../../lib/screens/admin/roles/roles_permissions_screen.dart#L200) (column 56) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/roles/roles_permissions_screen.dart:209](../../lib/screens/admin/roles/roles_permissions_screen.dart#L209) (column 56) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:221](../../lib/screens/admin/roles/roles_permissions_screen.dart#L221) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:241](../../lib/screens/admin/roles/roles_permissions_screen.dart#L241) (column 61) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:248](../../lib/screens/admin/roles/roles_permissions_screen.dart#L248) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:258](../../lib/screens/admin/roles/roles_permissions_screen.dart#L258) (column 44) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:267](../../lib/screens/admin/roles/roles_permissions_screen.dart#L267) (column 44) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:296](../../lib/screens/admin/roles/roles_permissions_screen.dart#L296) (column 34) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/roles/roles_permissions_screen.dart:297](../../lib/screens/admin/roles/roles_permissions_screen.dart#L297) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/roles/roles_permissions_screen.dart:327](../../lib/screens/admin/roles/roles_permissions_screen.dart#L327) (column 28) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:334](../../lib/screens/admin/roles/roles_permissions_screen.dart#L334) (column 49) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:338](../../lib/screens/admin/roles/roles_permissions_screen.dart#L338) (column 49) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:342](../../lib/screens/admin/roles/roles_permissions_screen.dart#L342) (column 49) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/roles/roles_permissions_screen.dart:379](../../lib/screens/admin/roles/roles_permissions_screen.dart#L379) (column 22) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:395](../../lib/screens/admin/roles/roles_permissions_screen.dart#L395) (column 32) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:397](../../lib/screens/admin/roles/roles_permissions_screen.dart#L397) (column 51) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:428](../../lib/screens/admin/roles/roles_permissions_screen.dart#L428) (column 46) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/roles/roles_permissions_screen.dart:441](../../lib/screens/admin/roles/roles_permissions_screen.dart#L441) (column 40) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:500](../../lib/screens/admin/roles/roles_permissions_screen.dart#L500) (column 22) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:502](../../lib/screens/admin/roles/roles_permissions_screen.dart#L502) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:525](../../lib/screens/admin/roles/roles_permissions_screen.dart#L525) (column 30) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/roles/roles_permissions_screen.dart:540](../../lib/screens/admin/roles/roles_permissions_screen.dart#L540) (column 24) | `Color(0xFF334155)` | `#FF334155` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:575](../../lib/screens/admin/roles/roles_permissions_screen.dart#L575) (column 22) | `Color(0xFFF6F8F3)` | `#FFF6F8F3` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:577](../../lib/screens/admin/roles/roles_permissions_screen.dart#L577) (column 41) | `Color(0xFFE6ECD9)` | `#FFE6ECD9` | inline literal | — |
| [lib/screens/admin/roles/roles_permissions_screen.dart:582](../../lib/screens/admin/roles/roles_permissions_screen.dart#L582) (column 18) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/roles/roles_permissions_screen.dart:601](../../lib/screens/admin/roles/roles_permissions_screen.dart#L601) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |

### lib/screens/admin/sales_returns/new_sales_return_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:282](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L282) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:283](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L283) (column 52) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:303](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L303) (column 52) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:304](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L304) (column 46) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:306](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L306) (column 48) | `Color(0x330B4A06)` | `#330B4A06` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:349](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L349) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:351](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L351) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:354](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L354) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:411](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L411) (column 22) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:413](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L413) (column 41) | `Color(0xFFD8DFE8)` | `#FFD8DFE8` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:430](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L430) (column 20) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:445](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L445) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:448](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L448) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:452](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L452) (column 26) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:459](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L459) (column 47) | `Color(0xFFD8DFE8)` | `#FFD8DFE8` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:463](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L463) (column 47) | `Color(0xFFD8DFE8)` | `#FFD8DFE8` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:467](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L467) (column 47) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:500](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L500) (column 39) | `Color(0xFFD8DFE8)` | `#FFD8DFE8` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:501](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L501) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:514](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L514) (column 24) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:518](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L518) (column 45) | `Color(0xFFD8DFE8)` | `#FFD8DFE8` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:522](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L522) (column 45) | `Color(0xFFD8DFE8)` | `#FFD8DFE8` | inline literal | — |
| [lib/screens/admin/sales_returns/new_sales_return_screen.dart:526](../../lib/screens/admin/sales_returns/new_sales_return_screen.dart#L526) (column 45) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |

### lib/screens/admin/sales_returns/sales_returns_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:178](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L178) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:180](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L180) (column 57) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:183](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L183) (column 36) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:221](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L221) (column 40) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:231](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L231) (column 44) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:240](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L240) (column 40) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:252](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L252) (column 38) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:261](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L261) (column 38) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:305](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L305) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:312](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L312) (column 49) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:316](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L316) (column 49) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:320](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L320) (column 49) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:332](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L332) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:334](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L334) (column 41) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:342](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L342) (column 20) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:344](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L344) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:377](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L377) (column 35) | `Color(0xFF475569)` | `#FF475569` | inline literal | — |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:401](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L401) (column 32) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:402](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L402) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/sales_returns/sales_returns_screen.dart:404](../../lib/screens/admin/sales_returns/sales_returns_screen.dart#L404) (column 28) | `Color(0x330B4A06)` | `#330B4A06` | inline literal | — |

### lib/screens/admin/settings/account_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/account_screen.dart:26](../../lib/screens/admin/settings/account_screen.dart#L26) (column 36) | `Color(0xFF0F172A)` | `#FF0F172A` | local definition: _titleColor | — |
| [lib/screens/admin/settings/account_screen.dart:27](../../lib/screens/admin/settings/account_screen.dart#L27) (column 36) | `Color(0xFF64748B)` | `#FF64748B` | local definition: _mutedColor | — |
| [lib/screens/admin/settings/account_screen.dart:28](../../lib/screens/admin/settings/account_screen.dart#L28) (column 32) | `Colors.white` | `#FFFFFFFF` | local definition: _cardBg | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:29](../../lib/screens/admin/settings/account_screen.dart#L29) (column 32) | `Color(0xFF0D1F42)` | `#FF0D1F42` | local definition: _accent | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/account_screen.dart:322](../../lib/screens/admin/settings/account_screen.dart#L322) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:324](../../lib/screens/admin/settings/account_screen.dart#L324) (column 41) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:327](../../lib/screens/admin/settings/account_screen.dart#L327) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/settings/account_screen.dart:344](../../lib/screens/admin/settings/account_screen.dart#L344) (column 51) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:345](../../lib/screens/admin/settings/account_screen.dart#L345) (column 32) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:385](../../lib/screens/admin/settings/account_screen.dart#L385) (column 43) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:474](../../lib/screens/admin/settings/account_screen.dart#L474) (column 15) | `Color(0xFFDCFCE7)` | `#FFDCFCE7` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:475](../../lib/screens/admin/settings/account_screen.dart#L475) (column 15) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:482](../../lib/screens/admin/settings/account_screen.dart#L482) (column 15) | `Color(0xFFFFEDD5)` | `#FFFFEDD5` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:483](../../lib/screens/admin/settings/account_screen.dart#L483) (column 15) | `Color(0xFFF97316)` | `#FFF97316` | inline literal | orange, deliveryOrange |
| [lib/screens/admin/settings/account_screen.dart:490](../../lib/screens/admin/settings/account_screen.dart#L490) (column 15) | `Color(0xFFE0F2FE)` | `#FFE0F2FE` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:491](../../lib/screens/admin/settings/account_screen.dart#L491) (column 15) | `Color(0xFF0284C7)` | `#FF0284C7` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:498](../../lib/screens/admin/settings/account_screen.dart#L498) (column 15) | `Color(0xFFFEF3C7)` | `#FFFEF3C7` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:499](../../lib/screens/admin/settings/account_screen.dart#L499) (column 15) | `Color(0xFFF59E0B)` | `#FFF59E0B` | inline literal | amber, deliveryYellow |
| [lib/screens/admin/settings/account_screen.dart:506](../../lib/screens/admin/settings/account_screen.dart#L506) (column 15) | `Color(0xFFF3E8FF)` | `#FFF3E8FF` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:507](../../lib/screens/admin/settings/account_screen.dart#L507) (column 15) | `Color(0xFF7C3AED)` | `#FF7C3AED` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:526](../../lib/screens/admin/settings/account_screen.dart#L526) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:528](../../lib/screens/admin/settings/account_screen.dart#L528) (column 45) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:531](../../lib/screens/admin/settings/account_screen.dart#L531) (column 24) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/settings/account_screen.dart:601](../../lib/screens/admin/settings/account_screen.dart#L601) (column 42) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:603](../../lib/screens/admin/settings/account_screen.dart#L603) (column 21) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:682](../../lib/screens/admin/settings/account_screen.dart#L682) (column 40) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:733](../../lib/screens/admin/settings/account_screen.dart#L733) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:734](../../lib/screens/admin/settings/account_screen.dart#L734) (column 38) | `Color(0xFFD8DFD8)` | `#FFD8DFD8` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:742](../../lib/screens/admin/settings/account_screen.dart#L742) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:767](../../lib/screens/admin/settings/account_screen.dart#L767) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:780](../../lib/screens/admin/settings/account_screen.dart#L780) (column 28) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:796](../../lib/screens/admin/settings/account_screen.dart#L796) (column 35) | `Color(0xFFF97316)` | `#FFF97316` | inline literal | orange, deliveryOrange |
| [lib/screens/admin/settings/account_screen.dart:828](../../lib/screens/admin/settings/account_screen.dart#L828) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:883](../../lib/screens/admin/settings/account_screen.dart#L883) (column 28) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:884](../../lib/screens/admin/settings/account_screen.dart#L884) (column 47) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:889](../../lib/screens/admin/settings/account_screen.dart#L889) (column 24) | `Color(0xFFEF4444)` | `#FFEF4444` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:935](../../lib/screens/admin/settings/account_screen.dart#L935) (column 36) | `Color(0xFFF3FAF0)` | `#FFF3FAF0` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:937](../../lib/screens/admin/settings/account_screen.dart#L937) (column 55) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/settings/account_screen.dart:992](../../lib/screens/admin/settings/account_screen.dart#L992) (column 19) | `Color(0xFFDCFCE7)` | `#FFDCFCE7` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:993](../../lib/screens/admin/settings/account_screen.dart#L993) (column 19) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:999](../../lib/screens/admin/settings/account_screen.dart#L999) (column 19) | `Color(0xFFE0E7FF)` | `#FFE0E7FF` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1000](../../lib/screens/admin/settings/account_screen.dart#L1000) (column 19) | `Color(0xFF4F46E5)` | `#FF4F46E5` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1006](../../lib/screens/admin/settings/account_screen.dart#L1006) (column 19) | `Color(0xFFF3E8FF)` | `#FFF3E8FF` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1007](../../lib/screens/admin/settings/account_screen.dart#L1007) (column 19) | `Color(0xFF7C3AED)` | `#FF7C3AED` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1013](../../lib/screens/admin/settings/account_screen.dart#L1013) (column 19) | `Color(0xFFFFEDD5)` | `#FFFFEDD5` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1014](../../lib/screens/admin/settings/account_screen.dart#L1014) (column 19) | `Color(0xFFF97316)` | `#FFF97316` | inline literal | orange, deliveryOrange |
| [lib/screens/admin/settings/account_screen.dart:1030](../../lib/screens/admin/settings/account_screen.dart#L1030) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:1038](../../lib/screens/admin/settings/account_screen.dart#L1038) (column 45) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1123](../../lib/screens/admin/settings/account_screen.dart#L1123) (column 26) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1205](../../lib/screens/admin/settings/account_screen.dart#L1205) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:1207](../../lib/screens/admin/settings/account_screen.dart#L1207) (column 41) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1210](../../lib/screens/admin/settings/account_screen.dart#L1210) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/settings/account_screen.dart:1274](../../lib/screens/admin/settings/account_screen.dart#L1274) (column 52) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1275](../../lib/screens/admin/settings/account_screen.dart#L1275) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:1544](../../lib/screens/admin/settings/account_screen.dart#L1544) (column 58) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1550](../../lib/screens/admin/settings/account_screen.dart#L1550) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:1577](../../lib/screens/admin/settings/account_screen.dart#L1577) (column 45) | `Color(0xFFD8DFD8)` | `#FFD8DFD8` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1581](../../lib/screens/admin/settings/account_screen.dart#L1581) (column 45) | `Color(0xFFD8DFD8)` | `#FFD8DFD8` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1614](../../lib/screens/admin/settings/account_screen.dart#L1614) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:1616](../../lib/screens/admin/settings/account_screen.dart#L1616) (column 41) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/settings/account_screen.dart:1619](../../lib/screens/admin/settings/account_screen.dart#L1619) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/settings/account_screen.dart:1639](../../lib/screens/admin/settings/account_screen.dart#L1639) (column 30) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/account_screen.dart:1646](../../lib/screens/admin/settings/account_screen.dart#L1646) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/account_screen.dart:1680](../../lib/screens/admin/settings/account_screen.dart#L1680) (column 34) | `Color(0xFF667085)` | `#FF667085` | inline literal | — |

### lib/screens/admin/settings/additional_information_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/additional_information_screen.dart:10](../../lib/screens/admin/settings/additional_information_screen.dart#L10) (column 37) | `Color(0xFF0F172A)` | `#FF0F172A` | local definition: kAdditionalTitleColor | — |
| [lib/screens/admin/settings/additional_information_screen.dart:11](../../lib/screens/admin/settings/additional_information_screen.dart#L11) (column 37) | `Color(0xFF64748B)` | `#FF64748B` | local definition: kAdditionalMutedColor | — |
| [lib/screens/admin/settings/additional_information_screen.dart:12](../../lib/screens/admin/settings/additional_information_screen.dart#L12) (column 38) | `Color(0xFF0D1F42)` | `#FF0D1F42` | local definition: kAdditionalAccentColor | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/additional_information_screen.dart:13](../../lib/screens/admin/settings/additional_information_screen.dart#L13) (column 38) | `Color(0xFFD8DFD8)` | `#FFD8DFD8` | local definition: kAdditionalBorderColor | — |
| [lib/screens/admin/settings/additional_information_screen.dart:14](../../lib/screens/admin/settings/additional_information_screen.dart#L14) (column 34) | `Colors.white` | `#FFFFFFFF` | local definition: kAdditionalFieldBg | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/additional_information_screen.dart:145](../../lib/screens/admin/settings/additional_information_screen.dart#L145) (column 21) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/settings/additional_information_screen.dart:146](../../lib/screens/admin/settings/additional_information_screen.dart#L146) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/settings/admin_settings_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/admin_settings_screen.dart:117](../../lib/screens/admin/settings/admin_settings_screen.dart#L117) (column 46) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/admin_settings_screen.dart:129](../../lib/screens/admin/settings/admin_settings_screen.dart#L129) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/settings/billing_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/billing_screen.dart:22](../../lib/screens/admin/settings/billing_screen.dart#L22) (column 36) | `Color(0xFF0F172A)` | `#FF0F172A` | local definition: _titleColor | — |
| [lib/screens/admin/settings/billing_screen.dart:23](../../lib/screens/admin/settings/billing_screen.dart#L23) (column 36) | `Color(0xFF64748B)` | `#FF64748B` | local definition: _mutedColor | — |
| [lib/screens/admin/settings/billing_screen.dart:24](../../lib/screens/admin/settings/billing_screen.dart#L24) (column 32) | `Color(0xFF0D1F42)` | `#FF0D1F42` | local definition: _accent | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/billing_screen.dart:25](../../lib/screens/admin/settings/billing_screen.dart#L25) (column 37) | `Color(0xFFD8DFD8)` | `#FFD8DFD8` | local definition: _borderColor | — |
| [lib/screens/admin/settings/billing_screen.dart:26](../../lib/screens/admin/settings/billing_screen.dart#L26) (column 33) | `Colors.white` | `#FFFFFFFF` | local definition: _fieldBg | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/billing_screen.dart:252](../../lib/screens/admin/settings/billing_screen.dart#L252) (column 48) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/settings/billing_screen.dart:345](../../lib/screens/admin/settings/billing_screen.dart#L345) (column 52) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/settings/billing_screen.dart:346](../../lib/screens/admin/settings/billing_screen.dart#L346) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/billing_screen.dart:422](../../lib/screens/admin/settings/billing_screen.dart#L422) (column 58) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |
| [lib/screens/admin/settings/billing_screen.dart:428](../../lib/screens/admin/settings/billing_screen.dart#L428) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/billing_screen.dart:528](../../lib/screens/admin/settings/billing_screen.dart#L528) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/billing_screen.dart:530](../../lib/screens/admin/settings/billing_screen.dart#L530) (column 41) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/settings/billing_screen.dart:540](../../lib/screens/admin/settings/billing_screen.dart#L540) (column 28) | `Color(0xFFFBFBFB)` | `#FFFBFBFB` | inline literal | — |
| [lib/screens/admin/settings/billing_screen.dart:542](../../lib/screens/admin/settings/billing_screen.dart#L542) (column 47) | `Color(0xFFE1E4E8)` | `#FFE1E4E8` | inline literal | — |
| [lib/screens/admin/settings/billing_screen.dart:550](../../lib/screens/admin/settings/billing_screen.dart#L550) (column 30) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |
| [lib/screens/admin/settings/billing_screen.dart:590](../../lib/screens/admin/settings/billing_screen.dart#L590) (column 46) | `Color(0xFF8CAD84)` | `#FF8CAD84` | inline literal | — |
| [lib/screens/admin/settings/billing_screen.dart:591](../../lib/screens/admin/settings/billing_screen.dart#L591) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/billing_screen.dart:613](../../lib/screens/admin/settings/billing_screen.dart#L613) (column 46) | `Color(0xFF9CA3AF)` | `#FF9CA3AF` | inline literal | — |
| [lib/screens/admin/settings/billing_screen.dart:614](../../lib/screens/admin/settings/billing_screen.dart#L614) (column 53) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |

### lib/screens/admin/settings/branding_identity_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/branding_identity_screen.dart:13](../../lib/screens/admin/settings/branding_identity_screen.dart#L13) (column 35) | `Color(0xFF0F172A)` | `#FF0F172A` | local definition: kBrandingTitleColor | — |
| [lib/screens/admin/settings/branding_identity_screen.dart:14](../../lib/screens/admin/settings/branding_identity_screen.dart#L14) (column 35) | `Color(0xFF64748B)` | `#FF64748B` | local definition: kBrandingMutedColor | — |
| [lib/screens/admin/settings/branding_identity_screen.dart:15](../../lib/screens/admin/settings/branding_identity_screen.dart#L15) (column 36) | `Color(0xFF0D1F42)` | `#FF0D1F42` | local definition: kBrandingAccentColor | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/branding_identity_screen.dart:16](../../lib/screens/admin/settings/branding_identity_screen.dart#L16) (column 36) | `Color(0xFFD8DFD8)` | `#FFD8DFD8` | local definition: kBrandingBorderColor | — |
| [lib/screens/admin/settings/branding_identity_screen.dart:292](../../lib/screens/admin/settings/branding_identity_screen.dart#L292) (column 21) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/settings/branding_identity_screen.dart:293](../../lib/screens/admin/settings/branding_identity_screen.dart#L293) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/branding_identity_screen.dart:454](../../lib/screens/admin/settings/branding_identity_screen.dart#L454) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/branding_identity_screen.dart:456](../../lib/screens/admin/settings/branding_identity_screen.dart#L456) (column 41) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/settings/branding_identity_screen.dart:465](../../lib/screens/admin/settings/branding_identity_screen.dart#L465) (column 28) | `Color(0xFFFBFBFB)` | `#FFFBFBFB` | inline literal | — |
| [lib/screens/admin/settings/branding_identity_screen.dart:467](../../lib/screens/admin/settings/branding_identity_screen.dart#L467) (column 47) | `Color(0xFFE1E4E8)` | `#FFE1E4E8` | inline literal | — |
| [lib/screens/admin/settings/branding_identity_screen.dart:475](../../lib/screens/admin/settings/branding_identity_screen.dart#L475) (column 30) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |
| [lib/screens/admin/settings/branding_identity_screen.dart:512](../../lib/screens/admin/settings/branding_identity_screen.dart#L512) (column 48) | `Color(0xFF8CAD84)` | `#FF8CAD84` | inline literal | — |
| [lib/screens/admin/settings/branding_identity_screen.dart:513](../../lib/screens/admin/settings/branding_identity_screen.dart#L513) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/branding_identity_screen.dart:535](../../lib/screens/admin/settings/branding_identity_screen.dart#L535) (column 48) | `Color(0xFF9CA3AF)` | `#FF9CA3AF` | inline literal | — |
| [lib/screens/admin/settings/branding_identity_screen.dart:536](../../lib/screens/admin/settings/branding_identity_screen.dart#L536) (column 55) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |

### lib/screens/admin/settings/business_settings_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/business_settings_screen.dart:12](../../lib/screens/admin/settings/business_settings_screen.dart#L12) (column 35) | `Color(0xFF0F172A)` | `#FF0F172A` | local definition: kBusinessTitleColor | — |
| [lib/screens/admin/settings/business_settings_screen.dart:13](../../lib/screens/admin/settings/business_settings_screen.dart#L13) (column 35) | `Color(0xFF64748B)` | `#FF64748B` | local definition: kBusinessMutedColor | — |
| [lib/screens/admin/settings/business_settings_screen.dart:14](../../lib/screens/admin/settings/business_settings_screen.dart#L14) (column 36) | `Color(0xFF0D1F42)` | `#FF0D1F42` | local definition: kBusinessAccentColor | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/business_settings_screen.dart:15](../../lib/screens/admin/settings/business_settings_screen.dart#L15) (column 36) | `Color(0xFFD8DFD8)` | `#FFD8DFD8` | local definition: kBusinessBorderColor | — |
| [lib/screens/admin/settings/business_settings_screen.dart:16](../../lib/screens/admin/settings/business_settings_screen.dart#L16) (column 32) | `Colors.white` | `#FFFFFFFF` | local definition: kBusinessFieldBg | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/business_settings_screen.dart:245](../../lib/screens/admin/settings/business_settings_screen.dart#L245) (column 21) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/settings/business_settings_screen.dart:246](../../lib/screens/admin/settings/business_settings_screen.dart#L246) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/business_settings_screen.dart:401](../../lib/screens/admin/settings/business_settings_screen.dart#L401) (column 58) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |
| [lib/screens/admin/settings/business_settings_screen.dart:407](../../lib/screens/admin/settings/business_settings_screen.dart#L407) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/settings/change_password_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/change_password_screen.dart:17](../../lib/screens/admin/settings/change_password_screen.dart#L17) (column 36) | `Color(0xFF0F172A)` | `#FF0F172A` | local definition: _titleColor | — |
| [lib/screens/admin/settings/change_password_screen.dart:18](../../lib/screens/admin/settings/change_password_screen.dart#L18) (column 36) | `Color(0xFF64748B)` | `#FF64748B` | local definition: _mutedColor | — |
| [lib/screens/admin/settings/change_password_screen.dart:19](../../lib/screens/admin/settings/change_password_screen.dart#L19) (column 37) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | local definition: _borderColor | — |
| [lib/screens/admin/settings/change_password_screen.dart:20](../../lib/screens/admin/settings/change_password_screen.dart#L20) (column 33) | `Colors.white` | `#FFFFFFFF` | local definition: _fieldBg | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/change_password_screen.dart:21](../../lib/screens/admin/settings/change_password_screen.dart#L21) (column 32) | `Color(0xFF0D1F42)` | `#FF0D1F42` | local definition: _accent | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/change_password_screen.dart:200](../../lib/screens/admin/settings/change_password_screen.dart#L200) (column 49) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/change_password_screen.dart:213](../../lib/screens/admin/settings/change_password_screen.dart#L213) (column 52) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/change_password_screen.dart:215](../../lib/screens/admin/settings/change_password_screen.dart#L215) (column 48) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/settings/change_password_screen.dart:268](../../lib/screens/admin/settings/change_password_screen.dart#L268) (column 49) | `Color(0xFFEF4444)` | `#FFEF4444` | inline literal | — |
| [lib/screens/admin/settings/change_password_screen.dart:325](../../lib/screens/admin/settings/change_password_screen.dart#L325) (column 26) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |

### lib/screens/admin/settings/company_settings_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/company_settings_screen.dart:31](../../lib/screens/admin/settings/company_settings_screen.dart#L31) (column 15) | `Color(0xFFEAF5D9)` | `#FFEAF5D9` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:32](../../lib/screens/admin/settings/company_settings_screen.dart#L32) (column 18) | `Color(0xFF567F19)` | `#FF567F19` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:38](../../lib/screens/admin/settings/company_settings_screen.dart#L38) (column 15) | `Color(0xFFE6F1FF)` | `#FFE6F1FF` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:39](../../lib/screens/admin/settings/company_settings_screen.dart#L39) (column 18) | `Color(0xFF3775D6)` | `#FF3775D6` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:45](../../lib/screens/admin/settings/company_settings_screen.dart#L45) (column 15) | `Color(0xFFFFF0D9)` | `#FFFFF0D9` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:46](../../lib/screens/admin/settings/company_settings_screen.dart#L46) (column 18) | `Color(0xFFDB8A00)` | `#FFDB8A00` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:52](../../lib/screens/admin/settings/company_settings_screen.dart#L52) (column 15) | `Color(0xFFF2E6FF)` | `#FFF2E6FF` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:53](../../lib/screens/admin/settings/company_settings_screen.dart#L53) (column 18) | `Color(0xFF8A50D1)` | `#FF8A50D1` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:59](../../lib/screens/admin/settings/company_settings_screen.dart#L59) (column 15) | `Color(0xFFE4F7F4)` | `#FFE4F7F4` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:60](../../lib/screens/admin/settings/company_settings_screen.dart#L60) (column 18) | `Color(0xFF1E9C90)` | `#FF1E9C90` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:66](../../lib/screens/admin/settings/company_settings_screen.dart#L66) (column 15) | `Color(0xFFFFF2E7)` | `#FFFFF2E7` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:67](../../lib/screens/admin/settings/company_settings_screen.dart#L67) (column 18) | `Color(0xFFF18A1A)` | `#FFF18A1A` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:73](../../lib/screens/admin/settings/company_settings_screen.dart#L73) (column 15) | `Color(0xFFEAF0FF)` | `#FFEAF0FF` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:74](../../lib/screens/admin/settings/company_settings_screen.dart#L74) (column 18) | `Color(0xFF5479E4)` | `#FF5479E4` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:80](../../lib/screens/admin/settings/company_settings_screen.dart#L80) (column 15) | `Color(0xFFE9F7F2)` | `#FFE9F7F2` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:81](../../lib/screens/admin/settings/company_settings_screen.dart#L81) (column 18) | `Color(0xFF1E9C90)` | `#FF1E9C90` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:87](../../lib/screens/admin/settings/company_settings_screen.dart#L87) (column 15) | `Color(0xFFFFECEF)` | `#FFFFECEF` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:88](../../lib/screens/admin/settings/company_settings_screen.dart#L88) (column 18) | `Color(0xFFFF4D6D)` | `#FFFF4D6D` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:94](../../lib/screens/admin/settings/company_settings_screen.dart#L94) (column 15) | `Color(0xFFF3E8FF)` | `#FFF3E8FF` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:95](../../lib/screens/admin/settings/company_settings_screen.dart#L95) (column 18) | `Color(0xFF8A50D1)` | `#FF8A50D1` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:101](../../lib/screens/admin/settings/company_settings_screen.dart#L101) (column 15) | `Color(0xFFE6F7F1)` | `#FFE6F7F1` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:102](../../lib/screens/admin/settings/company_settings_screen.dart#L102) (column 18) | `Color(0xFF1E9C90)` | `#FF1E9C90` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:256](../../lib/screens/admin/settings/company_settings_screen.dart#L256) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/settings/company_settings_screen.dart:269](../../lib/screens/admin/settings/company_settings_screen.dart#L269) (column 28) | `Color(0xFFEAF5D9)` | `#FFEAF5D9` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:274](../../lib/screens/admin/settings/company_settings_screen.dart#L274) (column 22) | `Color(0xFF567F19)` | `#FF567F19` | inline literal | — |
| [lib/screens/admin/settings/company_settings_screen.dart:353](../../lib/screens/admin/settings/company_settings_screen.dart#L353) (column 24) | `Colors.black` | `#FF000000` | Flutter palette reference | — |

### lib/screens/admin/settings/documents_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/documents_screen.dart:13](../../lib/screens/admin/settings/documents_screen.dart#L13) (column 36) | `Color(0xFF0F172A)` | `#FF0F172A` | local definition: kDocumentsTitleColor | — |
| [lib/screens/admin/settings/documents_screen.dart:14](../../lib/screens/admin/settings/documents_screen.dart#L14) (column 36) | `Color(0xFF64748B)` | `#FF64748B` | local definition: kDocumentsMutedColor | — |
| [lib/screens/admin/settings/documents_screen.dart:15](../../lib/screens/admin/settings/documents_screen.dart#L15) (column 37) | `Color(0xFF0D1F42)` | `#FF0D1F42` | local definition: kDocumentsAccentColor | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/documents_screen.dart:281](../../lib/screens/admin/settings/documents_screen.dart#L281) (column 21) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/settings/documents_screen.dart:282](../../lib/screens/admin/settings/documents_screen.dart#L282) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/documents_screen.dart:387](../../lib/screens/admin/settings/documents_screen.dart#L387) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/documents_screen.dart:389](../../lib/screens/admin/settings/documents_screen.dart#L389) (column 41) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/settings/documents_screen.dart:398](../../lib/screens/admin/settings/documents_screen.dart#L398) (column 28) | `Color(0xFFFBFBFB)` | `#FFFBFBFB` | inline literal | — |
| [lib/screens/admin/settings/documents_screen.dart:400](../../lib/screens/admin/settings/documents_screen.dart#L400) (column 47) | `Color(0xFFE1E4E8)` | `#FFE1E4E8` | inline literal | — |
| [lib/screens/admin/settings/documents_screen.dart:408](../../lib/screens/admin/settings/documents_screen.dart#L408) (column 30) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |
| [lib/screens/admin/settings/documents_screen.dart:445](../../lib/screens/admin/settings/documents_screen.dart#L445) (column 48) | `Color(0xFF8CAD84)` | `#FF8CAD84` | inline literal | — |
| [lib/screens/admin/settings/documents_screen.dart:446](../../lib/screens/admin/settings/documents_screen.dart#L446) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/documents_screen.dart:468](../../lib/screens/admin/settings/documents_screen.dart#L468) (column 48) | `Color(0xFF9CA3AF)` | `#FF9CA3AF` | inline literal | — |
| [lib/screens/admin/settings/documents_screen.dart:469](../../lib/screens/admin/settings/documents_screen.dart#L469) (column 55) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |

### lib/screens/admin/settings/general_information_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/general_information_screen.dart:16](../../lib/screens/admin/settings/general_information_screen.dart#L16) (column 38) | `Color(0xFF0F172A)` | `#FF0F172A` | local definition: kGeneralInfoTitleColor | — |
| [lib/screens/admin/settings/general_information_screen.dart:17](../../lib/screens/admin/settings/general_information_screen.dart#L17) (column 38) | `Color(0xFF64748B)` | `#FF64748B` | local definition: kGeneralInfoMutedColor | — |
| [lib/screens/admin/settings/general_information_screen.dart:18](../../lib/screens/admin/settings/general_information_screen.dart#L18) (column 39) | `Color(0xFF0D1F42)` | `#FF0D1F42` | local definition: kGeneralInfoAccentColor | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/general_information_screen.dart:29](../../lib/screens/admin/settings/general_information_screen.dart#L29) (column 37) | `Color(0xFFD8DFD8)` | `#FFD8DFD8` | local definition: _borderColor | — |
| [lib/screens/admin/settings/general_information_screen.dart:30](../../lib/screens/admin/settings/general_information_screen.dart#L30) (column 33) | `Colors.white` | `#FFFFFFFF` | local definition: _fieldBg | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/general_information_screen.dart:1007](../../lib/screens/admin/settings/general_information_screen.dart#L1007) (column 21) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/settings/general_information_screen.dart:1008](../../lib/screens/admin/settings/general_information_screen.dart#L1008) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/general_information_screen.dart:1161](../../lib/screens/admin/settings/general_information_screen.dart#L1161) (column 58) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |
| [lib/screens/admin/settings/general_information_screen.dart:1167](../../lib/screens/admin/settings/general_information_screen.dart#L1167) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/general_information_screen.dart:1224](../../lib/screens/admin/settings/general_information_screen.dart#L1224) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/general_information_screen.dart:1226](../../lib/screens/admin/settings/general_information_screen.dart#L1226) (column 41) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/settings/general_information_screen.dart:1238](../../lib/screens/admin/settings/general_information_screen.dart#L1238) (column 32) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/admin/settings/general_information_screen.dart:1240](../../lib/screens/admin/settings/general_information_screen.dart#L1240) (column 51) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/settings/general_information_screen.dart:1255](../../lib/screens/admin/settings/general_information_screen.dart#L1255) (column 34) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/settings/general_information_screen.dart:1331](../../lib/screens/admin/settings/general_information_screen.dart#L1331) (column 21) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |
| [lib/screens/admin/settings/general_information_screen.dart:1333](../../lib/screens/admin/settings/general_information_screen.dart#L1333) (column 33) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/settings/general_information_screen.dart:1333](../../lib/screens/admin/settings/general_information_screen.dart#L1333) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/settings/general_information_screen.dart:1366](../../lib/screens/admin/settings/general_information_screen.dart#L1366) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/general_information_screen.dart:1368](../../lib/screens/admin/settings/general_information_screen.dart#L1368) (column 41) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/settings/general_information_screen.dart:1371](../../lib/screens/admin/settings/general_information_screen.dart#L1371) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/settings/general_information_screen.dart:1391](../../lib/screens/admin/settings/general_information_screen.dart#L1391) (column 30) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/general_information_screen.dart:1398](../../lib/screens/admin/settings/general_information_screen.dart#L1398) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/general_information_screen.dart:1433](../../lib/screens/admin/settings/general_information_screen.dart#L1433) (column 34) | `Color(0xFF667085)` | `#FF667085` | inline literal | — |

### lib/screens/admin/settings/online_presence_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/online_presence_screen.dart:10](../../lib/screens/admin/settings/online_presence_screen.dart#L10) (column 41) | `Color(0xFF0F172A)` | `#FF0F172A` | local definition: kOnlinePresenceTitleColor | — |
| [lib/screens/admin/settings/online_presence_screen.dart:11](../../lib/screens/admin/settings/online_presence_screen.dart#L11) (column 41) | `Color(0xFF64748B)` | `#FF64748B` | local definition: kOnlinePresenceMutedColor | — |
| [lib/screens/admin/settings/online_presence_screen.dart:12](../../lib/screens/admin/settings/online_presence_screen.dart#L12) (column 42) | `Color(0xFF0D1F42)` | `#FF0D1F42` | local definition: kOnlinePresenceAccentColor | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/settings/online_presence_screen.dart:13](../../lib/screens/admin/settings/online_presence_screen.dart#L13) (column 42) | `Color(0xFFD8DFD8)` | `#FFD8DFD8` | local definition: kOnlinePresenceBorderColor | — |
| [lib/screens/admin/settings/online_presence_screen.dart:14](../../lib/screens/admin/settings/online_presence_screen.dart#L14) (column 38) | `Colors.white` | `#FFFFFFFF` | local definition: kOnlinePresenceFieldBg | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/online_presence_screen.dart:153](../../lib/screens/admin/settings/online_presence_screen.dart#L153) (column 21) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/settings/online_presence_screen.dart:154](../../lib/screens/admin/settings/online_presence_screen.dart#L154) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/settings/plans_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/settings/plans_screen.dart:158](../../lib/screens/admin/settings/plans_screen.dart#L158) (column 48) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/plans_screen.dart:274](../../lib/screens/admin/settings/plans_screen.dart#L274) (column 20) | `Color(0xFFFFFFFF)` | `#FFFFFFFF` | inline literal | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/plans_screen.dart:274](../../lib/screens/admin/settings/plans_screen.dart#L274) (column 39) | `Color(0xFFF4FBF1)` | `#FFF4FBF1` | inline literal | — |
| [lib/screens/admin/settings/plans_screen.dart:274](../../lib/screens/admin/settings/plans_screen.dart#L274) (column 58) | `Color(0xFFFFFFFF)` | `#FFFFFFFF` | inline literal | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/plans_screen.dart:287](../../lib/screens/admin/settings/plans_screen.dart#L287) (column 19) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/plans_screen.dart:333](../../lib/screens/admin/settings/plans_screen.dart#L333) (column 22) | `Color(0xFFFBFEFA)` | `#FFFBFEFA` | inline literal | — |
| [lib/screens/admin/settings/plans_screen.dart:396](../../lib/screens/admin/settings/plans_screen.dart#L396) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/plans_screen.dart:403](../../lib/screens/admin/settings/plans_screen.dart#L403) (column 38) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/plans_screen.dart:521](../../lib/screens/admin/settings/plans_screen.dart#L521) (column 49) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/settings/plans_screen.dart:527](../../lib/screens/admin/settings/plans_screen.dart#L527) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/settings/plans_screen.dart:551](../../lib/screens/admin/settings/plans_screen.dart#L551) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/suppliers/add_supplier_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:86](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L86) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:88](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L88) (column 53) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:91](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L91) (column 32) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:108](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L108) (column 40) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:117](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L117) (column 40) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:124](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L124) (column 57) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:223](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L223) (column 57) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:231](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L231) (column 56) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:232](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L232) (column 56) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:247](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L247) (column 56) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:248](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L248) (column 50) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:281](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L281) (column 20) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:288](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L288) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:313](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L313) (column 20) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:326](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L326) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:333](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L333) (column 51) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:337](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L337) (column 51) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:341](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L341) (column 51) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:361](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L361) (column 20) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:372](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L372) (column 20) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:376](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L376) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:383](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L383) (column 51) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:387](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L387) (column 51) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/suppliers/add_supplier_screen.dart:391](../../lib/screens/admin/suppliers/add_supplier_screen.dart#L391) (column 51) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |

### lib/screens/admin/suppliers/suppliers_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/suppliers/suppliers_screen.dart:62](../../lib/screens/admin/suppliers/suppliers_screen.dart#L62) (column 20) | `Color(0xFF15803D)` | `#FF15803D` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:63](../../lib/screens/admin/suppliers/suppliers_screen.dart#L63) (column 17) | `Color(0xFFF0FDF4)` | `#FFF0FDF4` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:207](../../lib/screens/admin/suppliers/suppliers_screen.dart#L207) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/suppliers_screen.dart:209](../../lib/screens/admin/suppliers/suppliers_screen.dart#L209) (column 57) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:212](../../lib/screens/admin/suppliers/suppliers_screen.dart#L212) (column 36) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:252](../../lib/screens/admin/suppliers/suppliers_screen.dart#L252) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:277](../../lib/screens/admin/suppliers/suppliers_screen.dart#L277) (column 59) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:323](../../lib/screens/admin/suppliers/suppliers_screen.dart#L323) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/suppliers_screen.dart:330](../../lib/screens/admin/suppliers/suppliers_screen.dart#L330) (column 49) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/suppliers/suppliers_screen.dart:334](../../lib/screens/admin/suppliers/suppliers_screen.dart#L334) (column 49) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/suppliers/suppliers_screen.dart:338](../../lib/screens/admin/suppliers/suppliers_screen.dart#L338) (column 49) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/suppliers/suppliers_screen.dart:348](../../lib/screens/admin/suppliers/suppliers_screen.dart#L348) (column 61) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/suppliers/suppliers_screen.dart:374](../../lib/screens/admin/suppliers/suppliers_screen.dart#L374) (column 32) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/suppliers/suppliers_screen.dart:375](../../lib/screens/admin/suppliers/suppliers_screen.dart#L375) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/suppliers_screen.dart:397](../../lib/screens/admin/suppliers/suppliers_screen.dart#L397) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:401](../../lib/screens/admin/suppliers/suppliers_screen.dart#L401) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/suppliers_screen.dart:408](../../lib/screens/admin/suppliers/suppliers_screen.dart#L408) (column 47) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/suppliers/suppliers_screen.dart:412](../../lib/screens/admin/suppliers/suppliers_screen.dart#L412) (column 47) | `Color(0xFFD1D5DB)` | `#FFD1D5DB` | inline literal | borderStrong |
| [lib/screens/admin/suppliers/suppliers_screen.dart:416](../../lib/screens/admin/suppliers/suppliers_screen.dart#L416) (column 47) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/suppliers/suppliers_screen.dart:469](../../lib/screens/admin/suppliers/suppliers_screen.dart#L469) (column 26) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:490](../../lib/screens/admin/suppliers/suppliers_screen.dart#L490) (column 22) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:514](../../lib/screens/admin/suppliers/suppliers_screen.dart#L514) (column 22) | `Color(0xFFFAFAFA)` | `#FFFAFAFA` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:516](../../lib/screens/admin/suppliers/suppliers_screen.dart#L516) (column 41) | `Color(0xFFF1F5F9)` | `#FFF1F5F9` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:528](../../lib/screens/admin/suppliers/suppliers_screen.dart#L528) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/suppliers_screen.dart:530](../../lib/screens/admin/suppliers/suppliers_screen.dart#L530) (column 53) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:538](../../lib/screens/admin/suppliers/suppliers_screen.dart#L538) (column 30) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/suppliers_screen.dart:554](../../lib/screens/admin/suppliers/suppliers_screen.dart#L554) (column 34) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/suppliers_screen.dart:563](../../lib/screens/admin/suppliers/suppliers_screen.dart#L563) (column 34) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:579](../../lib/screens/admin/suppliers/suppliers_screen.dart#L579) (column 24) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/suppliers_screen.dart:590](../../lib/screens/admin/suppliers/suppliers_screen.dart#L590) (column 24) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/suppliers_screen.dart:601](../../lib/screens/admin/suppliers/suppliers_screen.dart#L601) (column 24) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/suppliers_screen.dart:612](../../lib/screens/admin/suppliers/suppliers_screen.dart#L612) (column 24) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/suppliers_screen.dart:644](../../lib/screens/admin/suppliers/suppliers_screen.dart#L644) (column 57) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:656](../../lib/screens/admin/suppliers/suppliers_screen.dart#L656) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/suppliers/suppliers_screen.dart:658](../../lib/screens/admin/suppliers/suppliers_screen.dart#L658) (column 41) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:661](../../lib/screens/admin/suppliers/suppliers_screen.dart#L661) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:679](../../lib/screens/admin/suppliers/suppliers_screen.dart#L679) (column 51) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:703](../../lib/screens/admin/suppliers/suppliers_screen.dart#L703) (column 32) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/suppliers_screen.dart:712](../../lib/screens/admin/suppliers/suppliers_screen.dart#L712) (column 32) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:724](../../lib/screens/admin/suppliers/suppliers_screen.dart#L724) (column 26) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:786](../../lib/screens/admin/suppliers/suppliers_screen.dart#L786) (column 20) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:798](../../lib/screens/admin/suppliers/suppliers_screen.dart#L798) (column 20) | `Color(0xFF111827)` | `#FF111827` | inline literal | textPrimary, deliveryInk |
| [lib/screens/admin/suppliers/suppliers_screen.dart:833](../../lib/screens/admin/suppliers/suppliers_screen.dart#L833) (column 29) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/suppliers/suppliers_screen.dart:834](../../lib/screens/admin/suppliers/suppliers_screen.dart#L834) (column 29) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:845](../../lib/screens/admin/suppliers/suppliers_screen.dart#L845) (column 41) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/admin/suppliers/suppliers_screen.dart:845](../../lib/screens/admin/suppliers/suppliers_screen.dart#L845) (column 61) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:866](../../lib/screens/admin/suppliers/suppliers_screen.dart#L866) (column 16) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:917](../../lib/screens/admin/suppliers/suppliers_screen.dart#L917) (column 35) | `Color(0xFF15803D)` | `#FF15803D` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:917](../../lib/screens/admin/suppliers/suppliers_screen.dart#L917) (column 61) | `Color(0xFFDC2626)` | `#FFDC2626` | inline literal | statusInactiveText, red, deliveryRed |
| [lib/screens/admin/suppliers/suppliers_screen.dart:918](../../lib/screens/admin/suppliers/suppliers_screen.dart#L918) (column 32) | `Color(0xFFF0FDF4)` | `#FFF0FDF4` | inline literal | — |
| [lib/screens/admin/suppliers/suppliers_screen.dart:918](../../lib/screens/admin/suppliers/suppliers_screen.dart#L918) (column 58) | `Color(0xFFFEE2E2)` | `#FFFEE2E2` | inline literal | — |

### lib/screens/admin/users/add_staff_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/users/add_staff_screen.dart:959](../../lib/screens/admin/users/add_staff_screen.dart#L959) (column 43) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/users/add_staff_screen.dart:977](../../lib/screens/admin/users/add_staff_screen.dart#L977) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:983](../../lib/screens/admin/users/add_staff_screen.dart#L983) (column 43) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:1012](../../lib/screens/admin/users/add_staff_screen.dart#L1012) (column 39) | `Color(0xFFD8DFE6)` | `#FFD8DFE6` | inline literal | — |
| [lib/screens/admin/users/add_staff_screen.dart:1118](../../lib/screens/admin/users/add_staff_screen.dart#L1118) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:1134](../../lib/screens/admin/users/add_staff_screen.dart#L1134) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:1165](../../lib/screens/admin/users/add_staff_screen.dart#L1165) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:1438](../../lib/screens/admin/users/add_staff_screen.dart#L1438) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:1908](../../lib/screens/admin/users/add_staff_screen.dart#L1908) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:1910](../../lib/screens/admin/users/add_staff_screen.dart#L1910) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:1912](../../lib/screens/admin/users/add_staff_screen.dart#L1912) (column 21) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:1963](../../lib/screens/admin/users/add_staff_screen.dart#L1963) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:2241](../../lib/screens/admin/users/add_staff_screen.dart#L2241) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:2243](../../lib/screens/admin/users/add_staff_screen.dart#L2243) (column 41) | `Color(0xFFDDE3EA)` | `#FFDDE3EA` | inline literal | — |
| [lib/screens/admin/users/add_staff_screen.dart:2253](../../lib/screens/admin/users/add_staff_screen.dart#L2253) (column 28) | `Color(0xFFFBFBFB)` | `#FFFBFBFB` | inline literal | — |
| [lib/screens/admin/users/add_staff_screen.dart:2255](../../lib/screens/admin/users/add_staff_screen.dart#L2255) (column 47) | `Color(0xFFE1E4E8)` | `#FFE1E4E8` | inline literal | — |
| [lib/screens/admin/users/add_staff_screen.dart:2263](../../lib/screens/admin/users/add_staff_screen.dart#L2263) (column 30) | `Color(0xFF98A2B3)` | `#FF98A2B3` | inline literal | — |
| [lib/screens/admin/users/add_staff_screen.dart:2279](../../lib/screens/admin/users/add_staff_screen.dart#L2279) (column 42) | `Color(0xFF8CAD84)` | `#FF8CAD84` | inline literal | — |
| [lib/screens/admin/users/add_staff_screen.dart:2280](../../lib/screens/admin/users/add_staff_screen.dart#L2280) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:2300](../../lib/screens/admin/users/add_staff_screen.dart#L2300) (column 42) | `Color(0xFF9CA3AF)` | `#FF9CA3AF` | inline literal | — |
| [lib/screens/admin/users/add_staff_screen.dart:2301](../../lib/screens/admin/users/add_staff_screen.dart#L2301) (column 49) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/users/add_staff_screen.dart:2380](../../lib/screens/admin/users/add_staff_screen.dart#L2380) (column 43) | `Color(0xFFEF4444)` | `#FFEF4444` | inline literal | — |
| [lib/screens/admin/users/add_staff_screen.dart:2417](../../lib/screens/admin/users/add_staff_screen.dart#L2417) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:2523](../../lib/screens/admin/users/add_staff_screen.dart#L2523) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/add_staff_screen.dart:2570](../../lib/screens/admin/users/add_staff_screen.dart#L2570) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/users/admin_user_list_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/users/admin_user_list_screen.dart:44](../../lib/screens/admin/users/admin_user_list_screen.dart#L44) (column 36) | `Color(0xFFE3E7EC)` | `#FFE3E7EC` | local definition: _cardBorder | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:45](../../lib/screens/admin/users/admin_user_list_screen.dart#L45) (column 32) | `Colors.white` | `#FFFFFFFF` | local definition: _cardBg | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/admin_user_list_screen.dart:301](../../lib/screens/admin/users/admin_user_list_screen.dart#L301) (column 35) | `Color(0xFFE9F8EF)` | `#FFE9F8EF` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:302](../../lib/screens/admin/users/admin_user_list_screen.dart#L302) (column 35) | `Color(0xFFFFF1F1)` | `#FFFFF1F1` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:306](../../lib/screens/admin/users/admin_user_list_screen.dart#L306) (column 37) | `Color(0xFFBFE8CC)` | `#FFBFE8CC` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:307](../../lib/screens/admin/users/admin_user_list_screen.dart#L307) (column 37) | `Color(0xFFF0C6C6)` | `#FFF0C6C6` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:314](../../lib/screens/admin/users/admin_user_list_screen.dart#L314) (column 37) | `Color(0xFF107C41)` | `#FF107C41` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:349](../../lib/screens/admin/users/admin_user_list_screen.dart#L349) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/admin_user_list_screen.dart:495](../../lib/screens/admin/users/admin_user_list_screen.dart#L495) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/admin_user_list_screen.dart:634](../../lib/screens/admin/users/admin_user_list_screen.dart#L634) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/admin_user_list_screen.dart:643](../../lib/screens/admin/users/admin_user_list_screen.dart#L643) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:649](../../lib/screens/admin/users/admin_user_list_screen.dart#L649) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/admin_user_list_screen.dart:768](../../lib/screens/admin/users/admin_user_list_screen.dart#L768) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:786](../../lib/screens/admin/users/admin_user_list_screen.dart#L786) (column 34) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:810](../../lib/screens/admin/users/admin_user_list_screen.dart#L810) (column 33) | `Color(0xFF22C55E)` | `#FF22C55E` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:811](../../lib/screens/admin/users/admin_user_list_screen.dart#L811) (column 33) | `Color(0xFFCBD5E1)` | `#FFCBD5E1` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:813](../../lib/screens/admin/users/admin_user_list_screen.dart#L813) (column 47) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/users/admin_user_list_screen.dart:880](../../lib/screens/admin/users/admin_user_list_screen.dart#L880) (column 36) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:881](../../lib/screens/admin/users/admin_user_list_screen.dart#L881) (column 46) | `Color(0xFFEAF0FF)` | `#FFEAF0FF` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:889](../../lib/screens/admin/users/admin_user_list_screen.dart#L889) (column 36) | `Color(0xFF0F766E)` | `#FF0F766E` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:890](../../lib/screens/admin/users/admin_user_list_screen.dart#L890) (column 46) | `Color(0xFFE7FFFB)` | `#FFE7FFFB` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:897](../../lib/screens/admin/users/admin_user_list_screen.dart#L897) (column 36) | `Color(0xFFB45309)` | `#FFB45309` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:898](../../lib/screens/admin/users/admin_user_list_screen.dart#L898) (column 46) | `Color(0xFFFFF4E5)` | `#FFFFF4E5` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:906](../../lib/screens/admin/users/admin_user_list_screen.dart#L906) (column 46) | `Color(0xFFFFE8EA)` | `#FFFFE8EA` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:943](../../lib/screens/admin/users/admin_user_list_screen.dart#L943) (column 20) | `Color(0xFFF3F4F6)` | `#FFF3F4F6` | inline literal | — |
| [lib/screens/admin/users/admin_user_list_screen.dart:1257](../../lib/screens/admin/users/admin_user_list_screen.dart#L1257) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/admin/vehicles/vehicle_stock_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:255](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L255) (column 19) | `Color(0xFFF8FAF9)` | `#FFF8FAF9` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:476](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L476) (column 22) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:478](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L478) (column 41) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:545](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L545) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:578](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L578) (column 21) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:657](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L657) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:798](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L798) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:810](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L810) (column 24) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:822](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L822) (column 28) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:823](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L823) (column 33) | `Color(0xFFEAF3FF)` | `#FFEAF3FF` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:933](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L933) (column 22) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:981](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L981) (column 19) | `Color(0xFFF8FAF9)` | `#FFF8FAF9` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1273](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1273) (column 26) | `Color(0xFFF9FBFA)` | `#FFF9FBFA` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1343](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1343) (column 32) | `Color(0xFFF9FBFA)` | `#FFF9FBFA` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1516](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1516) (column 24) | `Color(0xFF0D7A24)` | `#FF0D7A24` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1517](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1517) (column 29) | `Color(0xFFE9F7EA)` | `#FFE9F7EA` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1524](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1524) (column 28) | `Color(0xFF065F1B)` | `#FF065F1B` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1610](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1610) (column 35) | `Color(0xFF4A546B)` | `#FF4A546B` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1661](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1661) (column 24) | `Color(0xFF0D7A24)` | `#FF0D7A24` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1861](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1861) (column 22) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1914](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1914) (column 22) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1916](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1916) (column 41) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1964](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1964) (column 22) | `Color(0xFFF3FBF4)` | `#FFF3FBF4` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1966](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1966) (column 41) | `Color(0xFFD8EEDD)` | `#FFD8EEDD` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1972](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1972) (column 20) | `Color(0xFF0D7A24)` | `#FF0D7A24` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1973](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1973) (column 25) | `Color(0xFFE9F7EA)` | `#FFE9F7EA` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:1983](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L1983) (column 28) | `Color(0xFF065F1B)` | `#FF065F1B` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:2007](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L2007) (column 26) | `Color(0xFF065F1B)` | `#FF065F1B` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:2016](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L2016) (column 26) | `Color(0xFF065F1B)` | `#FF065F1B` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:2042](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L2042) (column 34) | `Color(0xFF0D8C28)` | `#FF0D8C28` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:2210](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L2210) (column 22) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:2212](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L2212) (column 41) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:2238](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L2238) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/admin/vehicles/vehicle_stock_screen.dart:2243](../../lib/screens/admin/vehicles/vehicle_stock_screen.dart#L2243) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |

### lib/screens/auth/login_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/auth/login_screen.dart:74](../../lib/screens/auth/login_screen.dart#L74) (column 36) | `Color(0x14063B00)` | `#14063B00` | local definition: shadowColor | — |
| [lib/screens/auth/login_screen.dart:321](../../lib/screens/auth/login_screen.dart#L321) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/auth/login_screen.dart:479](../../lib/screens/auth/login_screen.dart#L479) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/auth/login_screen.dart:549](../../lib/screens/auth/login_screen.dart#L549) (column 44) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/auth/login_screen.dart:570](../../lib/screens/auth/login_screen.dart#L570) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/auth/login_screen.dart:626](../../lib/screens/auth/login_screen.dart#L626) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/auth/login_screen.dart:638](../../lib/screens/auth/login_screen.dart#L638) (column 61) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/auth/login_screen.dart:644](../../lib/screens/auth/login_screen.dart#L644) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/auth/login_screen.dart:669](../../lib/screens/auth/login_screen.dart#L669) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/auth/register_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/auth/register_screen.dart:38](../../lib/screens/auth/register_screen.dart#L38) (column 36) | `Color(0x14063B00)` | `#14063B00` | local definition: shadowColor | — |
| [lib/screens/auth/register_screen.dart:303](../../lib/screens/auth/register_screen.dart#L303) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/auth/register_screen.dart:349](../../lib/screens/auth/register_screen.dart#L349) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/auth/register_screen.dart:388](../../lib/screens/auth/register_screen.dart#L388) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/auth/register_screen.dart:400](../../lib/screens/auth/register_screen.dart#L400) (column 61) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/auth/register_screen.dart:406](../../lib/screens/auth/register_screen.dart#L406) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:50](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L50) (column 30) | `Color(0xFFF8FAF9)` | `#FFF8FAF9` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:124](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L124) (column 22) | `Color(0xFF15803D)` | `#FF15803D` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:126](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L126) (column 22) | `Color(0xFFB7791F)` | `#FFB7791F` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:243](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L243) (column 33) | `Color(0xFF15803D)` | `#FF15803D` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:247](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L247) (column 33) | `Color(0xFFB7791F)` | `#FFB7791F` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:277](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L277) (column 17) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:281](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L281) (column 14) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:289](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L289) (column 48) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:339](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L339) (column 22) | `Color(0xFFF4F7F5)` | `#FFF4F7F5` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:375](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L375) (column 37) | `Color(0xFFFFECEE)` | `#FFFFECEE` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:409](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L409) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:411](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L411) (column 37) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:414](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L414) (column 22) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:737](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L737) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart:742](../../lib/screens/delivery/attendance/delivery_attendance_calendar_screen.dart#L742) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |

### lib/screens/delivery/attendance/delivery_attendance_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:105](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L105) (column 30) | `Color(0xFFF8FAF9)` | `#FFF8FAF9` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:345](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L345) (column 38) | `Color(0xFFFFF1F1)` | `#FFFFF1F1` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:376](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L376) (column 25) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:463](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L463) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:475](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L475) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:494](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L494) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:496](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L496) (column 35) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:499](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L499) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:514](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L514) (column 35) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:549](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L549) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:716](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L716) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:750](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L750) (column 37) | `Color(0xFFFFECEE)` | `#FFFFECEE` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:784](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L784) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:786](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L786) (column 37) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:789](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L789) (column 22) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:989](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L989) (column 47) | `Color(0xFFE9EDF5)` | `#FFE9EDF5` | inline literal | deliveryCardBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:1095](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L1095) (column 22) | `Color(0xFFFFF1F1)` | `#FFFFF1F1` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:1097](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L1097) (column 41) | `Color(0xFFFF6B6B)` | `#FFFF6B6B` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:1111](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L1111) (column 24) | `Color(0xFFB00000)` | `#FFB00000` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:1219](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L1219) (column 37) | `Color(0xFF0D8C28)` | `#FF0D8C28` | inline literal | — |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:1316](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L1316) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/attendance/delivery_attendance_screen.dart:1321](../../lib/screens/delivery/attendance/delivery_attendance_screen.dart#L1321) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |

### lib/screens/delivery/collections/delivery_collection_list_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/collections/delivery_collection_list_screen.dart:348](../../lib/screens/delivery/collections/delivery_collection_list_screen.dart#L348) (column 28) | `Color(0xFFF0F7EC)` | `#FFF0F7EC` | inline literal | — |
| [lib/screens/delivery/collections/delivery_collection_list_screen.dart:610](../../lib/screens/delivery/collections/delivery_collection_list_screen.dart#L610) (column 50) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/delivery/customers/create_delivery_customer_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/customers/create_delivery_customer_screen.dart:670](../../lib/screens/delivery/customers/create_delivery_customer_screen.dart#L670) (column 46) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/customers/create_delivery_customer_screen.dart:806](../../lib/screens/delivery/customers/create_delivery_customer_screen.dart#L806) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |

### lib/screens/delivery/customers/customer_location_picker_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/customers/customer_location_picker_screen.dart:318](../../lib/screens/delivery/customers/customer_location_picker_screen.dart#L318) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/customers/customer_location_picker_screen.dart:339](../../lib/screens/delivery/customers/customer_location_picker_screen.dart#L339) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/customers/customer_location_picker_screen.dart:351](../../lib/screens/delivery/customers/customer_location_picker_screen.dart#L351) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/customers/customer_location_picker_screen.dart:432](../../lib/screens/delivery/customers/customer_location_picker_screen.dart#L432) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |

### lib/screens/delivery/customers/delivery_customer_detail_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/customers/delivery_customer_detail_screen.dart:624](../../lib/screens/delivery/customers/delivery_customer_detail_screen.dart#L624) (column 31) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/delivery/customers/delivery_customer_detail_screen.dart:715](../../lib/screens/delivery/customers/delivery_customer_detail_screen.dart#L715) (column 14) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |

### lib/screens/delivery/customers/delivery_customers_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/customers/delivery_customers_screen.dart:340](../../lib/screens/delivery/customers/delivery_customers_screen.dart#L340) (column 34) | `Color(0xFF4F5870)` | `#FF4F5870` | inline literal | — |
| [lib/screens/delivery/customers/delivery_customers_screen.dart:483](../../lib/screens/delivery/customers/delivery_customers_screen.dart#L483) (column 28) | `Color(0xFF586176)` | `#FF586176` | inline literal | — |
| [lib/screens/delivery/customers/delivery_customers_screen.dart:604](../../lib/screens/delivery/customers/delivery_customers_screen.dart#L604) (column 14) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |

### lib/screens/delivery/dashboard/delivery_company_orders_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/dashboard/delivery_company_orders_screen.dart:100](../../lib/screens/delivery/dashboard/delivery_company_orders_screen.dart#L100) (column 30) | `Color(0xFFF8FAF9)` | `#FFF8FAF9` | inline literal | — |
| [lib/screens/delivery/dashboard/delivery_company_orders_screen.dart:219](../../lib/screens/delivery/dashboard/delivery_company_orders_screen.dart#L219) (column 34) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/delivery/dashboard/delivery_company_orders_screen.dart:312](../../lib/screens/delivery/dashboard/delivery_company_orders_screen.dart#L312) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/dashboard/delivery_company_orders_screen.dart:334](../../lib/screens/delivery/dashboard/delivery_company_orders_screen.dart#L334) (column 24) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/delivery/dashboard/delivery_company_orders_screen.dart:471](../../lib/screens/delivery/dashboard/delivery_company_orders_screen.dart#L471) (column 22) | `Color(0xFFF8FAFC)` | `#FFF8FAFC` | inline literal | — |
| [lib/screens/delivery/dashboard/delivery_company_orders_screen.dart:655](../../lib/screens/delivery/dashboard/delivery_company_orders_screen.dart#L655) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/dashboard/delivery_company_orders_screen.dart:660](../../lib/screens/delivery/dashboard/delivery_company_orders_screen.dart#L660) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |

### lib/screens/delivery/deliveries/assigned_deliveries_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:400](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L400) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:530](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L530) (column 30) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:869](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L869) (column 28) | `Color(0xFFE5F6E7)` | `#FFE5F6E7` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:896](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L896) (column 28) | `Color(0xFF4F5870)` | `#FF4F5870` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:924](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L924) (column 28) | `Color(0xFF31394D)` | `#FF31394D` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1107](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1107) (column 48) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1488](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1488) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1502](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1502) (column 34) | `Color(0xFFD9DEE8)` | `#FFD9DEE8` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1519](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1519) (column 32) | `Color(0xFF586176)` | `#FF586176` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1538](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1538) (column 36) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1541](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1541) (column 57) | `Color(0xFFE1E6EF)` | `#FFE1E6EF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1545](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1545) (column 57) | `Color(0xFFE1E6EF)` | `#FFE1E6EF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1580](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1580) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1610](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1610) (column 30) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1737](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1737) (column 32) | `Color(0xFF586176)` | `#FF586176` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1748](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1748) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1781](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1781) (column 30) | `Color(0xFFE5F6E7)` | `#FFE5F6E7` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:1806](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L1806) (column 24) | `Color(0xFF586176)` | `#FF586176` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2314](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2314) (column 21) | `Color(0xFF155EC7)` | `#FF155EC7` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2315](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2315) (column 21) | `Color(0xFFEAF3FF)` | `#FFEAF3FF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2316](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2316) (column 17) | `Color(0xFFD4E8FF)` | `#FFD4E8FF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2320](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2320) (column 21) | `Color(0xFF155EC7)` | `#FF155EC7` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2321](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2321) (column 21) | `Color(0xFFEAF3FF)` | `#FFEAF3FF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2322](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2322) (column 17) | `Color(0xFFD4E8FF)` | `#FFD4E8FF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2326](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2326) (column 21) | `Color(0xFF15803D)` | `#FF15803D` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2327](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2327) (column 21) | `Color(0xFFE8F7E8)` | `#FFE8F7E8` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2328](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2328) (column 17) | `Color(0xFFD4EFD3)` | `#FFD4EFD3` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2332](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2332) (column 21) | `Color(0xFFF26B12)` | `#FFF26B12` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2333](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2333) (column 21) | `Color(0xFFFFF1DF)` | `#FFFFF1DF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2334](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2334) (column 17) | `Color(0xFFFFDDB6)` | `#FFFFDDB6` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2338](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2338) (column 21) | `Color(0xFF6D35D7)` | `#FF6D35D7` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2339](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2339) (column 21) | `Color(0xFFF0E9FF)` | `#FFF0E9FF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2340](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2340) (column 17) | `Color(0xFFE2D2FF)` | `#FFE2D2FF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2344](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2344) (column 21) | `Color(0xFF155EC7)` | `#FF155EC7` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2345](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2345) (column 21) | `Color(0xFFEAF3FF)` | `#FFEAF3FF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2346](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2346) (column 17) | `Color(0xFFD4E8FF)` | `#FFD4E8FF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2350](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2350) (column 21) | `Color(0xFF15803D)` | `#FF15803D` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2351](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2351) (column 21) | `Color(0xFFE8F7E8)` | `#FFE8F7E8` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2352](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2352) (column 17) | `Color(0xFFD4EFD3)` | `#FFD4EFD3` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2356](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2356) (column 21) | `Color(0xFF4F5870)` | `#FF4F5870` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2357](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2357) (column 21) | `Color(0xFFF1F4F8)` | `#FFF1F4F8` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2358](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2358) (column 17) | `Color(0xFFE1E6EF)` | `#FFE1E6EF` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2399](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2399) (column 12) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2401](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2401) (column 37) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:2404](../../lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L2404) (column 16) | `Colors.black` | `#FF000000` | Flutter palette reference | — |

### lib/screens/delivery/deliveries/delivery_detail_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:403](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L403) (column 30) | `Color(0xFFF7FAF8)` | `#FFF7FAF8` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:693](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L693) (column 50) | `Color(0xFFE1F6EA)` | `#FFE1F6EA` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:703](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L703) (column 50) | `Color(0xFF356B4B)` | `#FF356B4B` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:713](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L713) (column 54) | `Color(0xFF123D28)` | `#FF123D28` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:758](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L758) (column 52) | `Color(0xFF40536A)` | `#FF40536A` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:798](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L798) (column 56) | `Color(0xFF40536A)` | `#FF40536A` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:830](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L830) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:914](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L914) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:973](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L973) (column 44) | `Color(0xFFECF8F2)` | `#FFECF8F2` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1105](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1105) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1112](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1112) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1183](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1183) (column 28) | `Color(0xFFEAF5E9)` | `#FFEAF5E9` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1191](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1191) (column 26) | `Color(0xFF246936)` | `#FF246936` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1198](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1198) (column 30) | `Color(0xFF174F28)` | `#FF174F28` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1207](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1207) (column 28) | `Color(0xFF24713A)` | `#FF24713A` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1230](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1230) (column 25) | `Color(0xFF21854A)` | `#FF21854A` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1246](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1246) (column 28) | `Color(0xFFEAF5E9)` | `#FFEAF5E9` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1253](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1253) (column 33) | `Color(0xFF19652D)` | `#FF19652D` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1262](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1262) (column 28) | `Color(0xFFF0F7ED)` | `#FFF0F7ED` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1270](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1270) (column 26) | `Color(0xFF246936)` | `#FF246936` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1300](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1300) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1443](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1443) (column 22) | `Color(0xFFF0F7ED)` | `#FFF0F7ED` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1446](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1446) (column 54) | `Color(0xFF357343)` | `#FF357343` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1490](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1490) (column 31) | `Color(0xFFFFEEF0)` | `#FFFFEEF0` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1490](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1490) (column 57) | `Color(0xFFFFF5F6)` | `#FFFFF5F6` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1499](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1499) (column 22) | `Color(0xFFFF4358)` | `#FFFF4358` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1506](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1506) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1518](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1518) (column 63) | `Color(0xFF31536B)` | `#FF31536B` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1530](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1530) (column 34) | `Color(0xFFFFE4E8)` | `#FFFFE4E8` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1532](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1532) (column 53) | `Color(0xFFFFD2D8)` | `#FFFFD2D8` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1538](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1538) (column 63) | `Color(0xFF213B50)` | `#FF213B50` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1684](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1684) (column 26) | `Color(0xFFD8E4DC)` | `#FFD8E4DC` | local definition: pendingColor | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1702](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1702) (column 31) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1713](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1713) (column 31) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1728](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1728) (column 51) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1744](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1744) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1853](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1853) (column 10) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:1857](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L1857) (column 22) | `Color(0x12063B00)` | `#12063B00` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:2059](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L2059) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:2200](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L2200) (column 30) | `Color(0xFFF0F5F7)` | `#FFF0F5F7` | inline literal | — |
| [lib/screens/delivery/deliveries/delivery_detail_screen.dart:2203](../../lib/screens/delivery/deliveries/delivery_detail_screen.dart#L2203) (column 56) | `Color(0xFF35566B)` | `#FF35566B` | inline literal | — |

### lib/screens/delivery/end_of_day/end_of_day_return_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/end_of_day/end_of_day_return_screen.dart:180](../../lib/screens/delivery/end_of_day/end_of_day_return_screen.dart#L180) (column 30) | `Color(0xFFF8FAF9)` | `#FFF8FAF9` | inline literal | — |

### lib/screens/delivery/end_of_day/widgets/end_of_day_empty_state.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_empty_state.dart:22](../../lib/screens/delivery/end_of_day/widgets/end_of_day_empty_state.dart#L22) (column 24) | `Color(0xFFEAF7EC)` | `#FFEAF7EC` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_empty_state.dart:27](../../lib/screens/delivery/end_of_day/widgets/end_of_day_empty_state.dart#L27) (column 24) | `Color(0xFF0D7A24)` | `#FF0D7A24` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_empty_state.dart:69](../../lib/screens/delivery/end_of_day/widgets/end_of_day_empty_state.dart#L69) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart:21](../../lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart#L21) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart:26](../../lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart#L26) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart:52](../../lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart#L52) (column 22) | `Color(0xFFFFF1F1)` | `#FFFFF1F1` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart:54](../../lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart#L54) (column 41) | `Color(0xFFFFB4B4)` | `#FFFFB4B4` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart:68](../../lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart#L68) (column 24) | `Color(0xFFB00000)` | `#FFB00000` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart:100](../../lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart#L100) (column 22) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart:102](../../lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart#L102) (column 41) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart:136](../../lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart#L136) (column 17) | `Color(0xFF0D8C28)` | `#FF0D8C28` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart:138](../../lib/screens/delivery/end_of_day/widgets/end_of_day_shared.dart#L138) (column 17) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |

### lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart:43](../../lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart#L43) (column 47) | `Color(0xFFE9EDF5)` | `#FFE9EDF5` | inline literal | deliveryCardBorder |
| [lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart:99](../../lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart#L99) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart:141](../../lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart#L141) (column 47) | `Color(0xFFE9EDF5)` | `#FFE9EDF5` | inline literal | deliveryCardBorder |
| [lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart:200](../../lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart#L200) (column 43) | `Color(0xFF0D7A24)` | `#FF0D7A24` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart:228](../../lib/screens/delivery/end_of_day/widgets/reconciliation_summary.dart#L228) (column 22) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |

### lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart:115](../../lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart#L115) (column 47) | `Color(0xFFE9EDF5)` | `#FFE9EDF5` | inline literal | deliveryCardBorder |
| [lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart:153](../../lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart#L153) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart:156](../../lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart#L156) (column 57) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart:160](../../lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart#L160) (column 57) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart:176](../../lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart#L176) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart:183](../../lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart#L183) (column 38) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart:276](../../lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart#L276) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart:283](../../lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart#L283) (column 61) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart:308](../../lib/screens/delivery/end_of_day/widgets/stock_reconciliation_form.dart#L308) (column 22) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |

### lib/screens/delivery/end_of_day/widgets/stock_return_form.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/end_of_day/widgets/stock_return_form.dart:118](../../lib/screens/delivery/end_of_day/widgets/stock_return_form.dart#L118) (column 47) | `Color(0xFFE9EDF5)` | `#FFE9EDF5` | inline literal | deliveryCardBorder |
| [lib/screens/delivery/end_of_day/widgets/stock_return_form.dart:143](../../lib/screens/delivery/end_of_day/widgets/stock_return_form.dart#L143) (column 38) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/end_of_day/widgets/stock_return_form.dart:150](../../lib/screens/delivery/end_of_day/widgets/stock_return_form.dart#L150) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/end_of_day/widgets/stock_return_form.dart:251](../../lib/screens/delivery/end_of_day/widgets/stock_return_form.dart#L251) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/end_of_day/widgets/stock_return_form.dart:258](../../lib/screens/delivery/end_of_day/widgets/stock_return_form.dart#L258) (column 61) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/end_of_day/widgets/stock_return_form.dart:303](../../lib/screens/delivery/end_of_day/widgets/stock_return_form.dart#L303) (column 22) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |

### lib/screens/delivery/expenses/delivery_expenses_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:133](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L133) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:388](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L388) (column 38) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:426](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L426) (column 28) | `Color(0xFFE5F6E7)` | `#FFE5F6E7` | inline literal | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:453](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L453) (column 34) | `Color(0xFF4F5870)` | `#FF4F5870` | inline literal | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:598](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L598) (column 28) | `Color(0xFF586176)` | `#FF586176` | inline literal | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:646](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L646) (column 32) | `Color(0xFFF1F6EF)` | `#FFF1F6EF` | inline literal | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:845](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L845) (column 48) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:1042](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L1042) (column 22) | `Color(0xFFF3F5F2)` | `#FFF3F5F2` | inline literal | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:1083](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L1083) (column 30) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:1088](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L1088) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:1148](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L1148) (column 30) | `Color(0xFF111411)` | `#FF111411` | inline literal | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:1150](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L1150) (column 32) | `Color(0xFF111411)` | `#FF111411` | inline literal | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:1151](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L1151) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:1171](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L1171) (column 60) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:1179](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L1179) (column 30) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/delivery/expenses/delivery_expenses_screen.dart:1186](../../lib/screens/delivery/expenses/delivery_expenses_screen.dart#L1186) (column 47) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |

### lib/screens/delivery/leaves/delivery_leaves_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:93](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L93) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:728](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L728) (column 14) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:740](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L740) (column 24) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:891](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L891) (column 46) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:1337](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L1337) (column 21) | `Color(0xFFEAF7EE)` | `#FFEAF7EE` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:1389](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L1389) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:1540](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L1540) (column 50) | `Color(0xFFE5EAF1)` | `#FFE5EAF1` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:1550](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L1550) (column 24) | `Color(0xFF536074)` | `#FF536074` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2025](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2025) (column 21) | `Color(0xFFB7791F)` | `#FFB7791F` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2026](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2026) (column 21) | `Color(0xFFFFF7E6)` | `#FFFFF7E6` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2027](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2027) (column 17) | `Color(0xFFFFE0A8)` | `#FFFFE0A8` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2033](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2033) (column 17) | `Color(0xFFD4EFD3)` | `#FFD4EFD3` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2039](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2039) (column 17) | `Color(0xFFF6C7C7)` | `#FFF6C7C7` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2043](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2043) (column 21) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2044](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2044) (column 21) | `Color(0xFFF1F5F9)` | `#FFF1F5F9` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2045](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2045) (column 17) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2049](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2049) (column 21) | `Color(0xFF4F5870)` | `#FF4F5870` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2050](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2050) (column 21) | `Color(0xFFF1F4F8)` | `#FFF1F4F8` | inline literal | — |
| [lib/screens/delivery/leaves/delivery_leaves_screen.dart:2051](../../lib/screens/delivery/leaves/delivery_leaves_screen.dart#L2051) (column 17) | `Color(0xFFE1E6EF)` | `#FFE1E6EF` | inline literal | — |

### lib/screens/delivery/orders/create_delivery_order_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/orders/create_delivery_order_screen.dart:416](../../lib/screens/delivery/orders/create_delivery_order_screen.dart#L416) (column 29) | `Colors.deepOrange` | `#FFFF5722` | Flutter palette reference | — |
| [lib/screens/delivery/orders/create_delivery_order_screen.dart:907](../../lib/screens/delivery/orders/create_delivery_order_screen.dart#L907) (column 57) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/orders/create_delivery_order_screen.dart:1468](../../lib/screens/delivery/orders/create_delivery_order_screen.dart#L1468) (column 18) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/orders/create_delivery_order_screen.dart:1977](../../lib/screens/delivery/orders/create_delivery_order_screen.dart#L1977) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/orders/create_delivery_order_screen.dart:2720](../../lib/screens/delivery/orders/create_delivery_order_screen.dart#L2720) (column 33) | `Colors.deepOrange` | `#FFFF5722` | Flutter palette reference | — |

### lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:541](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L541) (column 30) | `Color(0xFFF7FAF8)` | `#FFF7FAF8` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:699](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L699) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:730](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L730) (column 33) | `Color(0xFFFFB020)` | `#FFFFB020` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:760](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L760) (column 35) | `Color(0xFFFFB020)` | `#FFFFB020` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:782](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L782) (column 19) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:787](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L787) (column 29) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:969](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L969) (column 39) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:974](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L974) (column 42) | `Color(0xFFF4F7F5)` | `#FFF4F7F5` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1025](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1025) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1144](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1144) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1265](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1265) (column 42) | `Color(0xFFF4F7F5)` | `#FFF4F7F5` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1268](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1268) (column 39) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1305](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1305) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1443](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1443) (column 41) | `Color(0xFFE9EDF2)` | `#FFE9EDF2` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1446](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1446) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1502](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1502) (column 34) | `Color(0xFFFAFBFC)` | `#FFFAFBFC` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1505](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1505) (column 55) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1509](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1509) (column 55) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1567](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1567) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1706](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1706) (column 46) | `Color(0xFFF4F7F5)` | `#FFF4F7F5` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1709](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1709) (column 43) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1853](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1853) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1861](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1861) (column 22) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1873](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1873) (column 30) | `Color(0xFFF7FBF8)` | `#FFF7FBF8` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1875](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1875) (column 49) | `Color(0xFFDCEEE1)` | `#FFDCEEE1` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1898](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1898) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1914](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1914) (column 50) | `Color(0xFF06783D)` | `#FF06783D` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1915](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1915) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:1971](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L1971) (column 28) | `Color(0xFF08733A)` | `#FF08733A` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2026](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2026) (column 61) | `Color(0xFF4B5668)` | `#FF4B5668` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2047](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2047) (column 20) | `Color(0xFFFBFCFD)` | `#FFFBFCFD` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2057](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2057) (column 45) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2061](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2061) (column 39) | `Color(0xFF313846)` | `#FF313846` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2069](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2069) (column 28) | `Color(0xFF4B5668)` | `#FF4B5668` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2076](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2076) (column 45) | `Color(0xFF303746)` | `#FF303746` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2104](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2104) (column 26) | `Color(0xFFEAF7ED)` | `#FFEAF7ED` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2107](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2107) (column 42) | `Color(0xFF087333)` | `#FF087333` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2135](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2135) (column 20) | `Color(0xFF39A04D)` | `#FF39A04D` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2142](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2142) (column 22) | `Color(0xFFF1F7F3)` | `#FFF1F7F3` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2144](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2144) (column 41) | `Color(0xFFE2EDE6)` | `#FFE2EDE6` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2191](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2191) (column 22) | `Color(0xFFF8FAFB)` | `#FFF8FAFB` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2193](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2193) (column 41) | `Color(0xFFE8EDF2)` | `#FFE8EDF2` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2251](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2251) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2256](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2256) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2361](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2361) (column 35) | `Color(0xFF718096)` | `#FF718096` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2364](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2364) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2368](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2368) (column 43) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |
| [lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart:2372](../../lib/screens/delivery/vehicle_stock/delivery_vehicle_loading_screen.dart#L2372) (column 43) | `Color(0xFFE2E7F0)` | `#FFE2E7F0` | inline literal | — |

### lib/screens/payment_collection_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/payment_collection_screen.dart:304](../../lib/screens/payment_collection_screen.dart#L304) (column 21) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/payment_collection_screen.dart:306](../../lib/screens/payment_collection_screen.dart#L306) (column 26) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/payment_collection_screen.dart:502](../../lib/screens/payment_collection_screen.dart#L502) (column 34) | `Color(0xFF7C8491)` | `#FF7C8491` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:535](../../lib/screens/payment_collection_screen.dart#L535) (column 32) | `Color(0xFFD93838)` | `#FFD93838` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:653](../../lib/screens/payment_collection_screen.dart#L653) (column 44) | `Color(0xFF30343B)` | `#FF30343B` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:655](../../lib/screens/payment_collection_screen.dart#L655) (column 51) | `Color(0xFFC9CED6)` | `#FFC9CED6` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:706](../../lib/screens/payment_collection_screen.dart#L706) (column 24) | `Color(0xFFFBFCFE)` | `#FFFBFCFE` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:708](../../lib/screens/payment_collection_screen.dart#L708) (column 29) | `Color(0xFFE1E6EE)` | `#FFE1E6EE` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:709](../../lib/screens/payment_collection_screen.dart#L709) (column 36) | `Color(0xFFE1E6EE)` | `#FFE1E6EE` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:711](../../lib/screens/payment_collection_screen.dart#L711) (column 34) | `Color(0xFFDC2626)` | `#FFDC2626` | inline literal | statusInactiveText, red, deliveryRed |
| [lib/screens/payment_collection_screen.dart:712](../../lib/screens/payment_collection_screen.dart#L712) (column 41) | `Color(0xFFDC2626)` | `#FFDC2626` | inline literal | statusInactiveText, red, deliveryRed |
| [lib/screens/payment_collection_screen.dart:750](../../lib/screens/payment_collection_screen.dart#L750) (column 28) | `Color(0xFFD44A4A)` | `#FFD44A4A` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:759](../../lib/screens/payment_collection_screen.dart#L759) (column 28) | `Color(0xFFD93838)` | `#FFD93838` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:772](../../lib/screens/payment_collection_screen.dart#L772) (column 38) | `Color(0xFF172033)` | `#FF172033` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:773](../../lib/screens/payment_collection_screen.dart#L773) (column 38) | `Color(0xFFF4F5F7)` | `#FFF4F5F7` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:789](../../lib/screens/payment_collection_screen.dart#L789) (column 38) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/screens/payment_collection_screen.dart:790](../../lib/screens/payment_collection_screen.dart#L790) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/payment_collection_screen.dart:791](../../lib/screens/payment_collection_screen.dart#L791) (column 46) | `Color(0xFF9AB99B)` | `#FF9AB99B` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:802](../../lib/screens/payment_collection_screen.dart#L802) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/payment_collection_screen.dart:829](../../lib/screens/payment_collection_screen.dart#L829) (column 41) | `Color(0xFFE7EAEF)` | `#FFE7EAEF` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:832](../../lib/screens/payment_collection_screen.dart#L832) (column 20) | `Color(0x0F24352A)` | `#0F24352A` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:856](../../lib/screens/payment_collection_screen.dart#L856) (column 41) | `Color(0xFF4B515B)` | `#FF4B515B` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:864](../../lib/screens/payment_collection_screen.dart#L864) (column 20) | `Color(0xFF15191F)` | `#FF15191F` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:905](../../lib/screens/payment_collection_screen.dart#L905) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/payment_collection_screen.dart:908](../../lib/screens/payment_collection_screen.dart#L908) (column 53) | `Color(0xFFD4DAE2)` | `#FFD4DAE2` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:928](../../lib/screens/payment_collection_screen.dart#L928) (column 34) | `Color(0xFF6D6D6D)` | `#FF6D6D6D` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:940](../../lib/screens/payment_collection_screen.dart#L940) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/payment_collection_screen.dart:962](../../lib/screens/payment_collection_screen.dart#L962) (column 28) | `Color(0xFF7C8491)` | `#FF7C8491` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:976](../../lib/screens/payment_collection_screen.dart#L976) (column 28) | `Color(0xFFD93838)` | `#FFD93838` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:1011](../../lib/screens/payment_collection_screen.dart#L1011) (column 22) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/payment_collection_screen.dart:1019](../../lib/screens/payment_collection_screen.dart#L1019) (column 24) | `Color(0xFF334155)` | `#FF334155` | inline literal | — |

### lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart:213](../../lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart#L213) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart:285](../../lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart#L285) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart:309](../../lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart#L309) (column 43) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart:313](../../lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart#L313) (column 47) | `Color(0xFFE5E7EB)` | `#FFE5E7EB` | inline literal | — |
| [lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart:378](../../lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart#L378) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart:396](../../lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart#L396) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart:422](../../lib/screens/sales_manager/attendance/sales_manager_attendance_screen.dart#L422) (column 14) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |

### lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:574](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L574) (column 15) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:581](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L581) (column 15) | `Color(0xFFF97316)` | `#FFF97316` | inline literal | orange, deliveryOrange |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:588](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L588) (column 15) | `Color(0xFF16A34A)` | `#FF16A34A` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:628](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L628) (column 22) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:629](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L629) (column 27) | `Color(0xFFEAF2FF)` | `#FFEAF2FF` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:635](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L635) (column 22) | `Color(0xFFD38B16)` | `#FFD38B16` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:636](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L636) (column 27) | `Color(0xFFFFF9E8)` | `#FFFFF9E8` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:683](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L683) (column 28) | `Color(0xFFF1F5FB)` | `#FFF1F5FB` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:685](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L685) (column 47) | `Color(0xFFE4EAF3)` | `#FFE4EAF3` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:739](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L739) (column 38) | `Color(0xFFDDEFE4)` | `#FFDDEFE4` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:870](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L870) (column 15) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:878](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L878) (column 15) | `Color(0xFFF97316)` | `#FFF97316` | inline literal | orange, deliveryOrange |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:921](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L921) (column 15) | `Color(0xFF7C3AED)` | `#FF7C3AED` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:927](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L927) (column 15) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1102](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1102) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1176](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1176) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1417](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1417) (column 22) | `Color(0xFFE8F1FF)` | `#FFE8F1FF` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1419](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1419) (column 41) | `Color(0xFFD6E6FF)` | `#FFD6E6FF` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1425](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1425) (column 18) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1474](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1474) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1479](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1479) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1924](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1924) (column 43) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1927](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1927) (column 16) | `Color(0xFF7C3AED)` | `#FF7C3AED` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1933](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1933) (column 47) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart:1934](../../lib/screens/sales_manager/dashboard/sales_manager_dashboard_screen.dart#L1934) (column 56) | `Color(0xFFF97316)` | `#FFF97316` | inline literal | orange, deliveryOrange |

### lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:206](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L206) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:246](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L246) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:417](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L417) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:496](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L496) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:539](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L539) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:641](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L641) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1007](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1007) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1012](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1012) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1024](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1024) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1033](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1033) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1041](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1041) (column 50) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1060](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1060) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1227](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1227) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1243](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1243) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1403](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1403) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1476](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1476) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart:1529](../../lib/screens/sales_manager/follow_ups/sales_manager_follow_ups_screen.dart#L1529) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/sales_manager/leads/add_lead_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:406](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L406) (column 30) | `Color(0xFFF7FAF8)` | `#FFF7FAF8` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:490](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L490) (column 22) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:500](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L500) (column 43) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:608](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L608) (column 42) | `Color(0xFF334155)` | `#FF334155` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:609](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L609) (column 49) | `Color(0xFFD7DEE8)` | `#FFD7DEE8` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:629](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L629) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:639](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L639) (column 42) | `Color(0xFF08783D)` | `#FF08783D` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:640](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L640) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:687](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L687) (column 28) | `Color(0xFFF59E0B)` | `#FFF59E0B` | inline literal | amber, deliveryYellow |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:702](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L702) (column 28) | `Color(0xFF08783D)` | `#FF08783D` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:722](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L722) (column 28) | `Color(0xFF2563EB)` | `#FF2563EB` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:731](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L731) (column 24) | `Color(0xFF475569)` | `#FF475569` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:765](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L765) (column 26) | `Color(0xFF08783D)` | `#FF08783D` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:774](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L774) (column 26) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:782](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L782) (column 47) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:792](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L792) (column 36) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:793](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L793) (column 43) | `Color(0xFFD7DEE8)` | `#FFD7DEE8` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:922](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L922) (column 18) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:999](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L999) (column 24) | `Color(0xFF94A3B8)` | `#FF94A3B8` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1010](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1010) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1012](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1012) (column 49) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1022](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1022) (column 32) | `Color(0xFF08783D)` | `#FF08783D` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1034](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1034) (column 32) | `Color(0xFF08783D)` | `#FF08783D` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1053](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1053) (column 30) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1057](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1057) (column 44) | `Color(0xFFEFF8F2)` | `#FFEFF8F2` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1058](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1058) (column 51) | `Color(0xFFCDECD7)` | `#FFCDECD7` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1126](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1126) (column 28) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1153](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1153) (column 50) | `Color(0xFF08783D)` | `#FF08783D` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1158](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1158) (column 45) | `Color(0xFF475569)` | `#FF475569` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1184](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1184) (column 45) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1192](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1192) (column 24) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1215](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1215) (column 22) | `Color(0xFFFEF2F2)` | `#FFFEF2F2` | inline literal | statusInactiveBg, deliveryRedSoft |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1217](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1217) (column 41) | `Color(0xFFFECACA)` | `#FFFECACA` | inline literal | statusInactiveBorder |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1221](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1221) (column 58) | `Color(0xFFDC2626)` | `#FFDC2626` | inline literal | statusInactiveText, red, deliveryRed |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1227](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1227) (column 24) | `Color(0xFF991B1B)` | `#FF991B1B` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1263](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1263) (column 22) | `Color(0xFFDC2626)` | `#FFDC2626` | inline literal | statusInactiveText, red, deliveryRed |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1299](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1299) (column 37) | `Color(0xFF08783D)` | `#FF08783D` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1304](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1304) (column 24) | `Color(0xFF0F172A)` | `#FF0F172A` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1313](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1313) (column 45) | `Color(0xFF64748B)` | `#FF64748B` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1368](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1368) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1372](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1372) (column 43) | `Color(0xFFD7DEE8)` | `#FFD7DEE8` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1378](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1378) (column 21) | `Color(0xFFD7DEE8)` | `#FFD7DEE8` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1379](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1379) (column 21) | `Color(0xFFDC2626)` | `#FFDC2626` | inline literal | statusInactiveText, red, deliveryRed |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1384](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1384) (column 43) | `Color(0xFF08783D)` | `#FF08783D` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1388](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1388) (column 43) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1396](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1396) (column 12) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1398](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1398) (column 37) | `Color(0xFFE2E8F0)` | `#FFE2E8F0` | inline literal | — |
| [lib/screens/sales_manager/leads/add_lead_screen.dart:1401](../../lib/screens/sales_manager/leads/add_lead_screen.dart#L1401) (column 16) | `Colors.black` | `#FF000000` | Flutter palette reference | — |

### lib/screens/sales_manager/performance/sales_manager_performance_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/sales_manager/performance/sales_manager_performance_screen.dart:248](../../lib/screens/sales_manager/performance/sales_manager_performance_screen.dart#L248) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/performance/sales_manager_performance_screen.dart:337](../../lib/screens/sales_manager/performance/sales_manager_performance_screen.dart#L337) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/performance/sales_manager_performance_screen.dart:342](../../lib/screens/sales_manager/performance/sales_manager_performance_screen.dart#L342) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/performance/sales_manager_performance_screen.dart:354](../../lib/screens/sales_manager/performance/sales_manager_performance_screen.dart#L354) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/performance/sales_manager_performance_screen.dart:363](../../lib/screens/sales_manager/performance/sales_manager_performance_screen.dart#L363) (column 28) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/sales_manager/performance/sales_manager_performance_screen.dart:375](../../lib/screens/sales_manager/performance/sales_manager_performance_screen.dart#L375) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/performance/sales_manager_performance_screen.dart:383](../../lib/screens/sales_manager/performance/sales_manager_performance_screen.dart#L383) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/performance/sales_manager_performance_screen.dart:390](../../lib/screens/sales_manager/performance/sales_manager_performance_screen.dart#L390) (column 43) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/sales_manager/performance/sales_manager_performance_screen.dart:412](../../lib/screens/sales_manager/performance/sales_manager_performance_screen.dart#L412) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/sales_manager/stock/sales_manager_stock_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/sales_manager/stock/sales_manager_stock_screen.dart:437](../../lib/screens/sales_manager/stock/sales_manager_stock_screen.dart#L437) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/stock/sales_manager_stock_screen.dart:470](../../lib/screens/sales_manager/stock/sales_manager_stock_screen.dart#L470) (column 35) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/sales_manager/stock/sales_manager_stock_screen.dart:563](../../lib/screens/sales_manager/stock/sales_manager_stock_screen.dart#L563) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/stock/sales_manager_stock_screen.dart:591](../../lib/screens/sales_manager/stock/sales_manager_stock_screen.dart#L591) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/stock/sales_manager_stock_screen.dart:714](../../lib/screens/sales_manager/stock/sales_manager_stock_screen.dart#L714) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/stock/sales_manager_stock_screen.dart:783](../../lib/screens/sales_manager/stock/sales_manager_stock_screen.dart#L783) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/sales_manager/visits/sales_manager_visits_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:380](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L380) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:382](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L382) (column 41) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:386](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L386) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:398](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L398) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:407](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L407) (column 28) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:419](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L419) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:427](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L427) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:434](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L434) (column 43) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:499](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L499) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:548](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L548) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:594](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L594) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:616](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L616) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:641](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L641) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/sales_manager/visits/sales_manager_visits_screen.dart:707](../../lib/screens/sales_manager/visits/sales_manager_visits_screen.dart#L707) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/shared/lead_detail_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/shared/lead_detail_screen.dart:308](../../lib/screens/shared/lead_detail_screen.dart#L308) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:429](../../lib/screens/shared/lead_detail_screen.dart#L429) (column 48) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:540](../../lib/screens/shared/lead_detail_screen.dart#L540) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:593](../../lib/screens/shared/lead_detail_screen.dart#L593) (column 21) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:607](../../lib/screens/shared/lead_detail_screen.dart#L607) (column 21) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:628](../../lib/screens/shared/lead_detail_screen.dart#L628) (column 21) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:742](../../lib/screens/shared/lead_detail_screen.dart#L742) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:747](../../lib/screens/shared/lead_detail_screen.dart#L747) (column 44) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:764](../../lib/screens/shared/lead_detail_screen.dart#L764) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:769](../../lib/screens/shared/lead_detail_screen.dart#L769) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:865](../../lib/screens/shared/lead_detail_screen.dart#L865) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:918](../../lib/screens/shared/lead_detail_screen.dart#L918) (column 24) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:1024](../../lib/screens/shared/lead_detail_screen.dart#L1024) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1026](../../lib/screens/shared/lead_detail_screen.dart#L1026) (column 45) | `Colors.white24` | `#3DFFFFFF` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:1044](../../lib/screens/shared/lead_detail_screen.dart#L1044) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1055](../../lib/screens/shared/lead_detail_screen.dart#L1055) (column 34) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:1064](../../lib/screens/shared/lead_detail_screen.dart#L1064) (column 38) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:1076](../../lib/screens/shared/lead_detail_screen.dart#L1076) (column 65) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1088](../../lib/screens/shared/lead_detail_screen.dart#L1088) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1098](../../lib/screens/shared/lead_detail_screen.dart#L1098) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1110](../../lib/screens/shared/lead_detail_screen.dart#L1110) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1122](../../lib/screens/shared/lead_detail_screen.dart#L1122) (column 56) | `Colors.white24` | `#3DFFFFFF` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:1141](../../lib/screens/shared/lead_detail_screen.dart#L1141) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1142](../../lib/screens/shared/lead_detail_screen.dart#L1142) (column 29) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1149](../../lib/screens/shared/lead_detail_screen.dart#L1149) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1150](../../lib/screens/shared/lead_detail_screen.dart#L1150) (column 29) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1157](../../lib/screens/shared/lead_detail_screen.dart#L1157) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1158](../../lib/screens/shared/lead_detail_screen.dart#L1158) (column 29) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1165](../../lib/screens/shared/lead_detail_screen.dart#L1165) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1166](../../lib/screens/shared/lead_detail_screen.dart#L1166) (column 29) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1173](../../lib/screens/shared/lead_detail_screen.dart#L1173) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1174](../../lib/screens/shared/lead_detail_screen.dart#L1174) (column 29) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1206](../../lib/screens/shared/lead_detail_screen.dart#L1206) (column 28) | `Colors.white70` | `#B3FFFFFF` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:1215](../../lib/screens/shared/lead_detail_screen.dart#L1215) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:1400](../../lib/screens/shared/lead_detail_screen.dart#L1400) (column 28) | `Color(0xFF586176)` | `#FF586176` | inline literal | — |
| [lib/screens/shared/lead_detail_screen.dart:1478](../../lib/screens/shared/lead_detail_screen.dart#L1478) (column 35) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:2115](../../lib/screens/shared/lead_detail_screen.dart#L2115) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:2159](../../lib/screens/shared/lead_detail_screen.dart#L2159) (column 11) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:2165](../../lib/screens/shared/lead_detail_screen.dart#L2165) (column 14) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:2298](../../lib/screens/shared/lead_detail_screen.dart#L2298) (column 24) | `Color(0x080F172A)` | `#080F172A` | inline literal | — |
| [lib/screens/shared/lead_detail_screen.dart:2321](../../lib/screens/shared/lead_detail_screen.dart#L2321) (column 24) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:2333](../../lib/screens/shared/lead_detail_screen.dart#L2333) (column 26) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/shared/lead_detail_screen.dart:2561](../../lib/screens/shared/lead_detail_screen.dart#L2561) (column 38) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:2674](../../lib/screens/shared/lead_detail_screen.dart#L2674) (column 38) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/shared/lead_detail_screen.dart:2852](../../lib/screens/shared/lead_detail_screen.dart#L2852) (column 38) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/shared/map_location_view_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/shared/map_location_view_screen.dart:100](../../lib/screens/shared/map_location_view_screen.dart#L100) (column 32) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/shared/map_location_view_screen.dart:160](../../lib/screens/shared/map_location_view_screen.dart#L160) (column 46) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:501](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L501) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:516](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L516) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:571](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L571) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:576](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L576) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:642](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L642) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:647](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L647) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:808](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L808) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:813](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L813) (column 22) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:843](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L843) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:857](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L857) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:991](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L991) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:996](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L996) (column 26) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1148](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1148) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1153](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1153) (column 26) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1172](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1172) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1254](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1254) (column 22) | `Color(0xFFF2F4F3)` | `#FFF2F4F3` | inline literal | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1290](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1290) (column 25) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1290](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1290) (column 40) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1298](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1298) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1298](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1298) (column 46) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1301](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1301) (column 52) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1355](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1355) (column 22) | `Color(0xFFFDFDFD)` | `#FFFDFDFD` | inline literal | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1519](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1519) (column 32) | `Color(0xFFF2F4F3)` | `#FFF2F4F3` | inline literal | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1543](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1543) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1595](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1595) (column 21) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1599](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1599) (column 28) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1621](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1621) (column 25) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1621](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1621) (column 40) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1629](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1629) (column 31) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1629](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1629) (column 46) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1632](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1632) (column 52) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1667](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1667) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1672](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1672) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1853](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1853) (column 14) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1860](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1860) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:1990](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L1990) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2051](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2051) (column 46) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2112](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2112) (column 24) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2171](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2171) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2183](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2183) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2198](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2198) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2241](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2241) (column 22) | `Color(0xFFFDFDFD)` | `#FFFDFDFD` | inline literal | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2368](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2368) (column 14) | `Color(0xFFF59E0B)` | `#FFF59E0B` | inline literal | amber, deliveryYellow |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2497](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2497) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2502](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2502) (column 24) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2566](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2566) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2571](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2571) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2618](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2618) (column 43) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2638](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2638) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2643](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2643) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2991](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2991) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:2992](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L2992) (column 25) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3101](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3101) (column 14) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3106](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3106) (column 24) | `Color(0xFFF8FAF7)` | `#FFF8FAF7` | inline literal | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3111](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3111) (column 22) | `Color(0x22000000)` | `#22000000` | inline literal | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3127](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3127) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3184](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3184) (column 42) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3297](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3297) (column 58) | `Color(0xFFA3B896)` | `#FFA3B896` | inline literal | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3298](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3298) (column 52) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3438](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3438) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3443](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3443) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3457](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3457) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3511](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3511) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3615](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3615) (column 44) | `Color(0xFFA3B896)` | `#FFA3B896` | inline literal | — |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3616](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3616) (column 38) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3716](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3716) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3778](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3778) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart:3939](../../lib/screens/super_admin/dashboard/super_admin_dashboard_screen.dart#L3939) (column 65) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/theme/app_theme.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/theme/app_theme.dart:22](../../lib/theme/app_theme.dart#L22) (column 20) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/theme/app_theme.dart:23](../../lib/theme/app_theme.dart#L23) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/theme/app_theme.dart:31](../../lib/theme/app_theme.dart#L31) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/theme/app_theme.dart:32](../../lib/theme/app_theme.dart#L32) (column 27) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/theme/app_theme.dart:40](../../lib/theme/app_theme.dart#L40) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/theme/app_theme.dart:45](../../lib/theme/app_theme.dart#L45) (column 27) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/theme/app_theme.dart:75](../../lib/theme/app_theme.dart#L75) (column 45) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/theme/app_theme.dart:80](../../lib/theme/app_theme.dart#L80) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/theme/app_theme.dart:94](../../lib/theme/app_theme.dart#L94) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/widgets/admin/app_drawer.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/admin/app_drawer.dart:375](../../lib/widgets/admin/app_drawer.dart#L375) (column 16) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/admin/app_drawer.dart:384](../../lib/widgets/admin/app_drawer.dart#L384) (column 59) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/admin/app_drawer.dart:433](../../lib/widgets/admin/app_drawer.dart#L433) (column 24) | `Color(0xFF9AA0B1)` | `#FF9AA0B1` | inline literal | — |
| [lib/widgets/admin/app_drawer.dart:455](../../lib/widgets/admin/app_drawer.dart#L455) (column 22) | `Color(0xFF0D1F42)` | `#FF0D1F42` | inline literal | primary, statusActiveText, statusActiveIcon, teal, green, blue, deliveryBlue, deliveryGreen, deliveryDashboardHeaderMid, deliveryDashboardHeaderEnd, deliveryDashboardNavEnd, deliveryDashboardOnlineDot, deliveryDashboardText, deliveryKpiMintIcon, deliveryKpiGreenIcon, deliveryKpiAquaIcon, deliveryCheckInButton, deliveryCustomerSales |
| [lib/widgets/admin/app_drawer.dart:459](../../lib/widgets/admin/app_drawer.dart#L459) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/widgets/admin/app_drawer.dart:474](../../lib/widgets/admin/app_drawer.dart#L474) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/admin/app_drawer.dart:479](../../lib/widgets/admin/app_drawer.dart#L479) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/admin/app_drawer.dart:488](../../lib/widgets/admin/app_drawer.dart#L488) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/admin/app_drawer.dart:500](../../lib/widgets/admin/app_drawer.dart#L500) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/admin/app_drawer.dart:519](../../lib/widgets/admin/app_drawer.dart#L519) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/admin/app_drawer.dart:585](../../lib/widgets/admin/app_drawer.dart#L585) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/widgets/app_calendar_date_picker.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/app_calendar_date_picker.dart:23](../../lib/widgets/app_calendar_date_picker.dart#L23) (column 19) | `Colors.black26` | `#42000000` | Flutter palette reference | — |
| [lib/widgets/app_calendar_date_picker.dart:215](../../lib/widgets/app_calendar_date_picker.dart#L215) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/app_calendar_date_picker.dart:265](../../lib/widgets/app_calendar_date_picker.dart#L265) (column 14) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/app_calendar_date_picker.dart:278](../../lib/widgets/app_calendar_date_picker.dart#L278) (column 25) | `Color(0xFFF6F8FB)` | `#FFF6F8FB` | inline literal | — |
| [lib/widgets/app_calendar_date_picker.dart:279](../../lib/widgets/app_calendar_date_picker.dart#L279) (column 25) | `Color(0xFFFBFCFE)` | `#FFFBFCFE` | inline literal | — |
| [lib/widgets/app_calendar_date_picker.dart:318](../../lib/widgets/app_calendar_date_picker.dart#L318) (column 60) | `Color(0xFFF2F4F7)` | `#FFF2F4F7` | inline literal | — |

### lib/widgets/completion_feedback_sheet.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/completion_feedback_sheet.dart:15](../../lib/widgets/completion_feedback_sheet.dart#L15) (column 22) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/completion_feedback_sheet.dart:86](../../lib/widgets/completion_feedback_sheet.dart#L86) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/widgets/delivery/customer_search_dialog.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/delivery/customer_search_dialog.dart:96](../../lib/widgets/delivery/customer_search_dialog.dart#L96) (column 25) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/delivery/customer_search_dialog.dart:304](../../lib/widgets/delivery/customer_search_dialog.dart#L304) (column 42) | `Color(0xFFD93838)` | `#FFD93838` | inline literal | — |

### lib/widgets/delivery/delivery_bottom_navigation.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/delivery/delivery_bottom_navigation.dart:41](../../lib/widgets/delivery/delivery_bottom_navigation.dart#L41) (column 21) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/widgets/delivery/delivery_bottom_navigation.dart:410](../../lib/widgets/delivery/delivery_bottom_navigation.dart#L410) (column 49) | `Colors.black54` | `#8A000000` | Flutter palette reference | — |
| [lib/widgets/delivery/delivery_bottom_navigation.dart:452](../../lib/widgets/delivery/delivery_bottom_navigation.dart#L452) (column 17) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |

### lib/widgets/delivery/delivery_image_upload_field.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/delivery/delivery_image_upload_field.dart:20](../../lib/widgets/delivery/delivery_image_upload_field.dart#L20) (column 22) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_image_upload_field.dart:33](../../lib/widgets/delivery/delivery_image_upload_field.dart#L33) (column 28) | `Color(0xFFD7DCE4)` | `#FFD7DCE4` | inline literal | — |
| [lib/widgets/delivery/delivery_image_upload_field.dart:115](../../lib/widgets/delivery/delivery_image_upload_field.dart#L115) (column 22) | `Color(0xFFF2F3F6)` | `#FFF2F3F6` | inline literal | — |
| [lib/widgets/delivery/delivery_image_upload_field.dart:117](../../lib/widgets/delivery/delivery_image_upload_field.dart#L117) (column 41) | `Color(0xFFCDD3DC)` | `#FFCDD3DC` | inline literal | — |
| [lib/widgets/delivery/delivery_image_upload_field.dart:154](../../lib/widgets/delivery/delivery_image_upload_field.dart#L154) (column 34) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/widgets/delivery/delivery_image_upload_field.dart:159](../../lib/widgets/delivery/delivery_image_upload_field.dart#L159) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/widgets/delivery/delivery_partner_search_dialog.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/delivery/delivery_partner_search_dialog.dart:80](../../lib/widgets/delivery/delivery_partner_search_dialog.dart#L80) (column 25) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |

### lib/widgets/delivery/delivery_partner_sidebar.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/delivery/delivery_partner_sidebar.dart:18](../../lib/widgets/delivery/delivery_partner_sidebar.dart#L18) (column 30) | `Color(0xFFF7F9FC)` | `#FFF7F9FC` | inline literal | — |
| [lib/widgets/delivery/delivery_partner_sidebar.dart:133](../../lib/widgets/delivery/delivery_partner_sidebar.dart#L133) (column 28) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_partner_sidebar.dart:167](../../lib/widgets/delivery/delivery_partner_sidebar.dart#L167) (column 16) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_partner_sidebar.dart:169](../../lib/widgets/delivery/delivery_partner_sidebar.dart#L169) (column 35) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_partner_sidebar.dart:193](../../lib/widgets/delivery/delivery_partner_sidebar.dart#L193) (column 54) | `Color(0xFF4F5870)` | `#FF4F5870` | inline literal | — |
| [lib/widgets/delivery/delivery_partner_sidebar.dart:198](../../lib/widgets/delivery/delivery_partner_sidebar.dart#L198) (column 50) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/delivery/delivery_partner_sidebar.dart:210](../../lib/widgets/delivery/delivery_partner_sidebar.dart#L210) (column 39) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/delivery/delivery_partner_sidebar.dart:226](../../lib/widgets/delivery/delivery_partner_sidebar.dart#L226) (column 43) | `Color(0xFF31394D)` | `#FF31394D` | inline literal | — |

### lib/widgets/delivery/delivery_top_bar.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/delivery/delivery_top_bar.dart:108](../../lib/widgets/delivery/delivery_top_bar.dart#L108) (column 26) | `Color(0xFFFF4D4F)` | `#FFFF4D4F` | inline literal | — |
| [lib/widgets/delivery/delivery_top_bar.dart:175](../../lib/widgets/delivery/delivery_top_bar.dart#L175) (column 32) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_top_bar.dart:188](../../lib/widgets/delivery/delivery_top_bar.dart#L188) (column 34) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_top_bar.dart:284](../../lib/widgets/delivery/delivery_top_bar.dart#L284) (column 14) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_top_bar.dart:292](../../lib/widgets/delivery/delivery_top_bar.dart#L292) (column 36) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_top_bar.dart:337](../../lib/widgets/delivery/delivery_top_bar.dart#L337) (column 20) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/widgets/delivery/delivery_top_bar.dart:359](../../lib/widgets/delivery/delivery_top_bar.dart#L359) (column 49) | `Color(0xFFFF4D4F)` | `#FFFF4D4F` | inline literal | — |
| [lib/widgets/delivery/delivery_top_bar.dart:364](../../lib/widgets/delivery/delivery_top_bar.dart#L364) (column 26) | `Color(0xFFFF4D4F)` | `#FFFF4D4F` | inline literal | — |
| [lib/widgets/delivery/delivery_top_bar.dart:377](../../lib/widgets/delivery/delivery_top_bar.dart#L377) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_top_bar.dart:379](../../lib/widgets/delivery/delivery_top_bar.dart#L379) (column 37) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_top_bar.dart:393](../../lib/widgets/delivery/delivery_top_bar.dart#L393) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/delivery_top_bar.dart:403](../../lib/widgets/delivery/delivery_top_bar.dart#L403) (column 26) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/widgets/delivery/order_progress_tracker.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/delivery/order_progress_tracker.dart:36](../../lib/widgets/delivery/order_progress_tracker.dart#L36) (column 18) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/order_progress_tracker.dart:41](../../lib/widgets/delivery/order_progress_tracker.dart#L41) (column 22) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/widgets/delivery/order_progress_tracker.dart:149](../../lib/widgets/delivery/order_progress_tracker.dart#L149) (column 26) | `Color(0xFFD8E4DC)` | `#FFD8E4DC` | local definition: pendingColor | — |
| [lib/widgets/delivery/order_progress_tracker.dart:167](../../lib/widgets/delivery/order_progress_tracker.dart#L167) (column 31) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/delivery/order_progress_tracker.dart:178](../../lib/widgets/delivery/order_progress_tracker.dart#L178) (column 31) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/delivery/order_progress_tracker.dart:193](../../lib/widgets/delivery/order_progress_tracker.dart#L193) (column 51) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/delivery/order_progress_tracker.dart:209](../../lib/widgets/delivery/order_progress_tracker.dart#L209) (column 40) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/widgets/delivery/voice_input_sheet.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/delivery/voice_input_sheet.dart:285](../../lib/widgets/delivery/voice_input_sheet.dart#L285) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/widgets/list_pagination_bar.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/list_pagination_bar.dart:90](../../lib/widgets/list_pagination_bar.dart#L90) (column 43) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |

### lib/widgets/sales_manager/sales_manager_bottom_navigation.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/sales_manager/sales_manager_bottom_navigation.dart:42](../../lib/widgets/sales_manager/sales_manager_bottom_navigation.dart#L42) (column 21) | `Colors.black` | `#FF000000` | Flutter palette reference | — |
| [lib/widgets/sales_manager/sales_manager_bottom_navigation.dart:378](../../lib/widgets/sales_manager/sales_manager_bottom_navigation.dart#L378) (column 49) | `Colors.black54` | `#8A000000` | Flutter palette reference | — |
| [lib/widgets/sales_manager/sales_manager_bottom_navigation.dart:420](../../lib/widgets/sales_manager/sales_manager_bottom_navigation.dart#L420) (column 17) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |

### lib/widgets/sales_manager/sales_manager_sidebar.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/sales_manager/sales_manager_sidebar.dart:96](../../lib/widgets/sales_manager/sales_manager_sidebar.dart#L96) (column 28) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/sales_manager/sales_manager_sidebar.dart:105](../../lib/widgets/sales_manager/sales_manager_sidebar.dart#L105) (column 33) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/sales_manager/sales_manager_sidebar.dart:118](../../lib/widgets/sales_manager/sales_manager_sidebar.dart#L118) (column 37) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/sales_manager/sales_manager_sidebar.dart:130](../../lib/widgets/sales_manager/sales_manager_sidebar.dart#L130) (column 41) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |

### lib/widgets/sidebar_logout_button.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/sidebar_logout_button.dart:63](../../lib/widgets/sidebar_logout_button.dart#L63) (column 16) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |

### lib/widgets/super_admin/super_admin_sidebar.dart

| Location | Expression | Base ARGB | Classification | Matching shared constants |
| --- | --- | --- | --- | --- |
| [lib/widgets/super_admin/super_admin_sidebar.dart:70](../../lib/widgets/super_admin/super_admin_sidebar.dart#L70) (column 30) | `Colors.white` | `#FFFFFFFF` | Flutter palette reference | background, surface, deliveryProfileAvatarBorder |
| [lib/widgets/super_admin/super_admin_sidebar.dart:125](../../lib/widgets/super_admin/super_admin_sidebar.dart#L125) (column 28) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/super_admin/super_admin_sidebar.dart:138](../../lib/widgets/super_admin/super_admin_sidebar.dart#L138) (column 33) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/super_admin/super_admin_sidebar.dart:151](../../lib/widgets/super_admin/super_admin_sidebar.dart#L151) (column 37) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |
| [lib/widgets/super_admin/super_admin_sidebar.dart:163](../../lib/widgets/super_admin/super_admin_sidebar.dart#L163) (column 41) | `Colors.transparent` | `#00000000` | Flutter palette reference | — |

## Explicit platform/web colors

| Location | Expression | Source |
| --- | --- | --- |
| [android/app/src/main/res/drawable/launch_background.xml:4](../../android/app/src/main/res/drawable/launch_background.xml#L4) | `@android:color/white` | `<item android:drawable="@android:color/white" />` |
| [ios/Runner/Base.lproj/LaunchScreen.storyboard:22](../../ios/Runner/Base.lproj/LaunchScreen.storyboard#L22) | `<color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>` | `<color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>` |
| [ios/Runner/Base.lproj/Main.storyboard:19](../../ios/Runner/Base.lproj/Main.storyboard#L19) | `<color key="backgroundColor" white="1" alpha="1" colorSpace="custom" customColorSpace="calibratedWhite"/>` | `<color key="backgroundColor" white="1" alpha="1" colorSpace="custom" customColorSpace="calibratedWhite"/>` |
| [web/manifest.json:6](../../web/manifest.json#L6) | `#0175C2` | `"background_color": "#0175C2",` |
| [web/manifest.json:7](../../web/manifest.json#L7) | `#0175C2` | `"theme_color": "#0175C2",` |

## Dynamic/theme expressions

- [lib/screens/delivery/customers/customer_location_picker_screen.dart:428](../../lib/screens/delivery/customers/customer_location_picker_screen.dart#L428): `color: Theme.of(context).colorScheme.surface,`
- [lib/screens/shared/map_location_view_screen.dart:96](../../lib/screens/shared/map_location_view_screen.dart#L96): `color: Theme.of(context).colorScheme.surface,`
- [lib/theme/app_theme.dart:17](../../lib/theme/app_theme.dart#L17): `colorScheme: const ColorScheme.light(`
- [lib/widgets/app_pagination.dart:27](../../lib/widgets/app_pagination.dart#L27): `final colors = Theme.of(context).colorScheme;`
- [lib/widgets/app_pagination.dart:36](../../lib/widgets/app_pagination.dart#L36): `color: colors.surface,`
- [lib/widgets/app_pagination.dart:38](../../lib/widgets/app_pagination.dart#L38): `border: Border.all(color: colors.outlineVariant.withValues(alpha: .7)),`
- [lib/widgets/app_pagination.dart:45](../../lib/widgets/app_pagination.dart#L45): `color: colors.onSurfaceVariant,`
- [lib/widgets/app_pagination.dart:60](../../lib/widgets/app_pagination.dart#L60): `color: colors.onSurface,`

## Notes for consolidation

Exact hex matches are candidates for review, not automatic replacement instructions: choose constants by intended role. Several differently named palette members intentionally resolve to the same value. Named `green`, `teal`, `blue`, `deliveryGreen` and similar aliases currently resolve to navy; their names do not describe their actual color. Theme-generated colors should be reviewed through their theme roles rather than assigned guessed hex codes.
