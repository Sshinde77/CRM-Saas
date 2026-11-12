# Delivery Person Module – Manual Testing Issues Report

**Date:** 2026-11-11  
**Tested by:** Claude Code (automated + static analysis)  
**App:** Beassuite CRM – Delivery Partner Role  
**Flutter version:** 3.41.2 (web, CanvasKit renderer)  
**Test environment:** Flutter `web-server` dev build at `localhost:3456`

---

## Testing Method

The app uses Flutter's **CanvasKit renderer** which requires WebGL/GPU. Because automated headless Chrome (Playwright) cannot render WebGL in a sandboxed environment, the UI screenshots captured only loading states. Issues were identified through:

1. **Static code analysis** of all delivery module screens
2. **Network and bundle analysis** via Playwright
3. **DOM/routing analysis** via headless browser
4. **Code logic review** of data models and calculations

---

## Issues Summary

| # | Severity | Screen | Title |
|---|----------|--------|-------|
| 1 | 🔴 CRITICAL | App Load | Flutter web app blank in headless/no-GPU environments |
| 2 | 🔴 HIGH | Delivery Dashboard | Incorrect "Total Amount to Collect" calculation |
| 3 | 🔴 HIGH | App Performance | Extremely slow initial page load (10+ seconds) |
| 4 | 🔴 HIGH | End of Day Return | `_isSavingReturn` is `final bool` — loading state never updates |
| 5 | 🟠 MEDIUM | Delivery Dashboard | "Canceled Orders" stat actually shows failed deliveries count |
| 6 | 🟠 MEDIUM | Delivery Dashboard | "Accepted Orders" and "Pending Orders" show identical values |
| 7 | 🟠 MEDIUM | Delivery Dashboard | "Total Orders (Company)" duplicates "My Deliveries" count |
| 8 | 🟠 MEDIUM | General | Currency formatting uses Western comma format, not Indian |
| 9 | 🟠 MEDIUM | Collections Screen | Fetches ALL customers when loading pending collections |
| 10 | 🟡 LOW | Delivery Detail | Multiple API calls on every delivery detail open |
| 11 | 🟡 LOW | App Performance | 16MB+ JavaScript bundle (dart_sdk.js alone is 16,350 KB) |
| 12 | 🟡 LOW | General | Missing `viewport` meta tag for mobile responsiveness |
| 13 | 🟡 LOW | Assigned Deliveries | Unnecessary double fetch: auth/me + delivery list on each load |
| 14 | 🟡 LOW | Create Order | Delivery date defaults to today even for future orders |

---

## Detailed Issue Reports

---

### Issue 1 — 🔴 CRITICAL: Flutter web app blank in headless / no-GPU environments

**Screen:** App Load  
**File:** `web/flutter_bootstrap.js`, `web/index.html`

**Description:**  
The app is configured to use exclusively the **CanvasKit renderer** (`"renderer":"canvaskit"`). CanvasKit requires WebGL/GPU support. In environments without hardware acceleration (CI/CD pipelines, headless Chrome, screen readers, low-end devices, Safari on some iOS versions), the app renders a completely blank white page. No fallback to the HTML renderer is available.

**Evidence from bootstrap:**
```json
"builds": [{"compileTarget":"dartdevc","renderer":"canvaskit","mainJsPath":"main.dart.js"}]
```
WebGL check in headless mode:
```
webgl: false, webgl2: false
```
Result: blank white page — no content, no error message, no loading indicator.

**Steps to reproduce:**
1. Open app in headless Chrome, or on a device with software rendering
2. App renders entirely blank — no login form, no loading spinner, nothing

**Impact:** Users on unsupported devices/environments cannot use the app at all with no explanation.

**Recommendation:**
- Add an HTML renderer fallback build to `flutter_bootstrap.js`
- Or configure the build to include both `canvaskit` and HTML renderer builds
- Display a user-friendly error when WebGL is unavailable

---

### Issue 2 — 🔴 HIGH: Incorrect "Total Amount to Collect" calculation

**Screen:** Delivery Dashboard → Collections Card  
**File:** [lib/screens/delivery/dashboard/delivery_dashboard_screen.dart:2162](lib/screens/delivery/dashboard/delivery_dashboard_screen.dart#L2162)

**Description:**  
The `amountToCollect` getter on `_DeliveryItem` uses an incorrect formula:

```dart
// WRONG: adds amount already collected to outstanding balance
double get amountToCollect => amountDue + amountCollected;
```

This means the "Total Amount to Collect" on the dashboard includes money already received. For example, if a customer owes Rs 1,000 and has already paid Rs 400, the system shows Rs 1,400 as "to collect" instead of Rs 600.

**Expected:**
```dart
// CORRECT: only the outstanding amount
double get amountToCollect => amountDue;
// OR if amountDue represents only the remaining balance, it's already correct alone
```

**Impact:** Delivery persons see inflated collection targets; financial reporting is incorrect.

---

### Issue 3 — 🔴 HIGH: Extremely slow initial page load (10+ seconds to network idle)

**Screen:** General  
**Evidence:** Playwright network idle timing: **10,343ms**

**Description:**  
The app takes over 10 seconds to reach network idle on a local dev server. The largest asset is `dart_sdk.js` at **16,350 KB** (16MB). Other large bundles include `vector_math_64.dart.lib.js` (1,011 KB), `keyboard_key.g.dart.lib.js` (545 KB). This is a **development build** — production would be better, but the dev build performance affects the development feedback loop significantly.

**Large resources detected:**
| Resource | Size |
|----------|------|
| dart_sdk.js | 16,350 KB |
| vector_math_64.dart.lib.js | 1,011 KB |
| keyboard_key.g.dart.lib.js | 545 KB |
| _platform_web.dart.lib.js | 496 KB |

**Recommendation:**
- Production builds will be smaller (tree-shaken) but should still be tested
- Consider using `flutter build web --wasm` for smaller WASM-based production builds
- Add a visible loading indicator so users know the app is loading

---

### Issue 4 — 🔴 HIGH: `_isSavingReturn` is `final` — save spinner never shows

**Screen:** End of Day Return  
**File:** [lib/screens/delivery/end_of_day/end_of_day_return_screen.dart:31](lib/screens/delivery/end_of_day/end_of_day_return_screen.dart#L31)

**Description:**  
The loading state variable for the stock return step is declared `final`:

```dart
final bool _isSavingReturn = false;  // BUG: final — can never be set to true
```

This means the "saving" spinner/disabled state passed to the `StockReturnForm` widget (`isSaving: _isSavingReturn`) is **always `false`**. Users can re-submit the return form while a submission is already in progress, potentially creating duplicate stock return records.

Compare with the reconciliation state which is correctly declared as mutable:
```dart
bool _isSavingReconciliation = false;  // correct — can be updated
```

**Fix:**
```dart
bool _isSavingReturn = false;  // remove 'final'
```
Then set it to `true` before the API call and `false` in the `finally` block.

**Impact:** Duplicate stock return submissions possible; no visual feedback during save.

---

### Issue 5 — 🟠 MEDIUM: "Canceled Orders" stat shows failed deliveries count, not canceled

**Screen:** Delivery Dashboard → Stats Grid  
**File:** [lib/screens/delivery/dashboard/delivery_dashboard_screen.dart:1953](lib/screens/delivery/dashboard/delivery_dashboard_screen.dart#L1953)

**Description:**  
The `canceledOrders` getter maps to `summary.failed`:

```dart
int get canceledOrders => summary.failed;  // "failed" ≠ "canceled"
```

Failed deliveries (delivery attempted but could not be completed) and canceled orders (order never attempted, canceled before dispatch) are distinct states. The dashboard mislabels the failed count as "Canceled Orders."

**Impact:** Delivery person sees wrong count in the "Canceled Orders" KPI tile; can cause confusion and incorrect reporting.

**Recommendation:** Add a `canceled` field to the summary API response and map it correctly.

---

### Issue 6 — 🟠 MEDIUM: "Accepted Orders" and "Pending Orders" show identical values

**Screen:** Delivery Dashboard → Stats Grid  
**File:** [lib/screens/delivery/dashboard/delivery_dashboard_screen.dart:1947-1949](lib/screens/delivery/dashboard/delivery_dashboard_screen.dart#L1947-L1949)

**Description:**  
Both `acceptedOrders` and `pendingOrders` return `summary.pending`:

```dart
int get acceptedOrders => summary.pending;  // wrong label
int get pendingOrders => summary.pending;   // duplicate
```

Accepted orders (delivery partner acknowledged the assignment) and pending orders (waiting to be accepted/processed) are different. The dashboard shows two KPI tiles with the same number and different labels, which is confusing and misleading.

**Fix:** Use separate summary fields (e.g., `summary.accepted` for accepted, `summary.pending` for pending), or remove one of the duplicate tiles.

---

### Issue 7 — 🟠 MEDIUM: "Total Orders (Company)" equals "My Deliveries" value

**Screen:** Delivery Dashboard → Stats Grid  
**File:** [lib/screens/delivery/dashboard/delivery_dashboard_screen.dart:1937-1939](lib/screens/delivery/dashboard/delivery_dashboard_screen.dart#L1937-L1939)

**Description:**  
Both `totalOrdersCompany` and `deliveriesToday` read from `summary.deliveries`:

```dart
int get deliveriesToday => summary.deliveries;      // my deliveries
int get totalOrdersCompany => summary.deliveries;   // company total — WRONG
```

A delivery person should see the company-wide total order count (useful for context) vs. their own assigned deliveries. Currently both tiles show identical numbers, making one redundant.

**Fix:** Add a `company_total` field to the dashboard API response and use it for `totalOrdersCompany`.

---

### Issue 8 — 🟠 MEDIUM: Currency uses Western comma format instead of Indian number system

**Screen:** All screens with money values  
**File:** [lib/screens/delivery/dashboard/delivery_dashboard_screen.dart:2394-2406](lib/screens/delivery/dashboard/delivery_dashboard_screen.dart#L2394-L2406)

**Description:**  
The `_formatMoney` function applies a simple every-3-digit comma rule:

```dart
String _formatMoney(double value) {
  final rounded = value.round();
  final source = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < source.length; i++) {
    final remaining = source.length - i;
    buffer.write(source[i]);
    if (remaining > 1 && remaining % 3 == 1) {  // Western format
      buffer.write(',');
    }
  }
  return '${rounded < 0 ? '-' : ''}Rs ${buffer.toString()}';
}
```

This produces `Rs 1,000,000` for 10 lakh but the Indian system expects `Rs 10,00,000`.

**Examples of incorrect output:**
- `1000000` → `Rs 1,000,000` (should be `Rs 10,00,000`)
- `100000` → `Rs 100,000` (should be `Rs 1,00,000`)
- `10000` → `Rs 10,000` (correct by coincidence)

Additionally, the function always rounds to integers, dropping paise (e.g., Rs 99.50 shows as `Rs 100`).

**Fix:** Use `NumberFormat.currency(locale: 'en_IN', symbol: 'Rs ')` from the `intl` package, or implement the Indian number formatting correctly (last 3 digits, then groups of 2).

---

### Issue 9 — 🟠 MEDIUM: Collections screen fetches ALL active customers unnecessarily

**Screen:** Delivery Collections  
**File:** [lib/screens/delivery/collections/delivery_collection_list_screen.dart:67-88](lib/screens/delivery/collections/delivery_collection_list_screen.dart#L67-L88)

**Description:**  
`_loadCollections()` calls `fetchCustomers(isActive: true)` to find customers with an outstanding balance. This fetches the entire active customer list just to filter by `outstanding > 0`:

```dart
final customers = results[1] as List<CustomerModel>;
return _CollectionDashboardData(
  pendingCustomers: customers
      .where((customer) => (customer.outstanding ?? 0) > 0)
      .map(_CollectionDelivery.fromCustomer)
      .toList(),
);
```

For businesses with hundreds or thousands of customers, this is a heavy operation. The API should ideally support a `has_outstanding=true` filter, or this screen should use the delivery collections endpoint alone.

**Impact:** Unnecessary bandwidth usage; slower collection screen load for large customer bases.

---

### Issue 10 — 🟡 LOW: Delivery detail screen makes multiple sequential API calls on open

**Screen:** Delivery Detail  
**File:** [lib/screens/delivery/deliveries/delivery_detail_screen.dart:54-80](lib/screens/delivery/deliveries/delivery_detail_screen.dart#L54-L80)

**Description:**  
Opening a delivery detail triggers up to 4 sequential API calls:
1. `fetchDeliveryById` (main data)
2. `fetchDeliveryCapacity` (only for `in_transit` / `partially_delivered`)
3. `fetchOrders(search: orderNumber)` (to resolve customer profile image — only if not already on the delivery)
4. `fetchProducts()` (to resolve product prices)

Calls 3 and 4 are expensive fallbacks that should ideally be included in the main delivery detail API response. Each call adds latency and the UI shows a loading skeleton until all complete.

**Recommendation:** Include `customer.profile_image_url` and `product_prices` in the delivery detail API response to eliminate the fallback fetches.

---

### Issue 11 — 🟡 LOW: 16MB JavaScript bundle (dart_sdk.js)

**Screen:** App Load  
**Evidence:** Playwright resource timing: `dart_sdk.js` = 16,350 KB

**Description:**  
The development build ships the full Dart SDK as a JavaScript file (`dart_sdk.js` at 16MB). This is expected in `flutter run` dev mode (DDC compiler), but the app should be tested in production mode (`flutter build web`) to verify the final bundle size. Production CanvasKit builds are typically 2–3MB gzipped.

**Risk:** If a production build is not regularly tested, bundle-size regressions may go unnoticed.

**Recommendation:** Add a CI step that runs `flutter build web --release` and checks gzipped bundle size stays below a threshold (e.g., 5MB gzipped).

---

### Issue 12 — 🟡 LOW: Web index.html missing `viewport` meta tag

**Screen:** General  
**File:** `web/index.html`

**Description:**  
The `web/index.html` does not include a `<meta name="viewport">` tag. Without it, mobile browsers use a default wide layout (typically 980px), causing the app to appear zoomed out on mobile devices.

```html
<!-- Currently missing from web/index.html: -->
<meta name="viewport" content="width=device-width, initial-scale=1.0">
```

The standard Flutter web template includes this — it may have been accidentally removed.

---

### Issue 13 — 🟡 LOW: Double auth/me fetch in Assigned Deliveries on each load

**Screen:** Assigned Deliveries  
**File:** [lib/screens/delivery/deliveries/assigned_deliveries_screen.dart:87-92](lib/screens/delivery/deliveries/assigned_deliveries_screen.dart#L87-L92)

**Description:**  
`_loadDeliveries()` calls `provider.fetchAuthMe()` on every list load (including pagination and pull-to-refresh) to retrieve the delivery partner ID:

```dart
final authMe = await provider.fetchAuthMe();
final currentUser = provider.currentUser ?? authMe?.user;
final deliveryPartnerId = currentUser?.id?.trim();
```

The same pattern appears in `_loadInitialData` in the vehicle loading screen, expense screen, etc. If the user's ID is already cached in `provider.currentUser`, the extra `fetchAuthMe()` call is wasted. This same pattern exists in at least 4 screens.

**Fix:** Check `provider.currentUser?.id` first; call `fetchAuthMe()` only if it is null.

---

### Issue 14 — 🟡 LOW: Delivery date defaults to today for all new orders

**Screen:** Create Delivery Order  
**File:** [lib/screens/delivery/orders/create_delivery_order_screen.dart:68-69](lib/screens/delivery/orders/create_delivery_order_screen.dart#L68-L69)

**Description:**  
Both `_orderDate` and `_deliveryDate` default to today:

```dart
DateTime _orderDate = DateUtils.dateOnly(DateTime.now());
DateTime _deliveryDate = DateUtils.dateOnly(DateTime.now());
```

For end-of-day scenarios (e.g., orders entered at 11 PM for next-day delivery), the delivery person must always manually change the delivery date. There is no smart default or minimum delivery date enforced. Additionally, users can set a delivery date in the past (before today) with no validation warning.

**Recommendation:**
- Default `_deliveryDate` to `DateTime.now().add(Duration(days: 1))` for home delivery orders
- Validate that delivery date is not in the past before submission, or at least show a warning

---

## Notes on Testing Environment

> **Why no live screenshots:** The Flutter web app uses CanvasKit which requires WebGL. The automated Playwright test runner (headless Chrome in a sandboxed environment) has no GPU/WebGL access, so the app renders blank in automated tests. All issues above were found through **static code analysis** and **DOM/network inspection** rather than visual screenshot comparison. For screenshot-based testing, run the app on a real browser with GPU support (`flutter run -d chrome`).

---

## Recommended Priority Order

1. **Issue 4** (End of Day `final` bug) — correctness bug, risk of data duplication
2. **Issue 2** (Amount to collect calculation) — financial data integrity
3. **Issues 5, 6, 7** (Dashboard stat mapping) — user-visible misinformation
4. **Issue 8** (Currency format) — Indian market compliance
5. **Issue 1** (Blank on no-GPU) — accessibility/compatibility
6. **Issue 3, 11** (Performance) — user experience
7. **Issues 9, 13** (Unnecessary API calls) — performance/efficiency
8. **Issues 10, 12, 14** (Minor UX) — polish
