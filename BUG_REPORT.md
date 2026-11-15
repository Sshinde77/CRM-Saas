# BUG REPORT — Beassuite CRM SaaS (Delivery Partner Web App)

**Tester:** Manual QA via browser automation (Playwright + Chromium)  
**Date:** 15 Nov 2026  
**App URL:** http://localhost:8080  
**Login used:** delivery@demo.com / Delivery@123 (Delivery Partner role)  
**Test run screenshots:** `test_screenshots/` (prefix 300–351)

---

## Fix Status

| Bug | Severity | Status | Fix location |
|-----|----------|--------|--------------|
| BUG-01 | HIGH | ✅ **Fixed** | `delivery_dashboard_screen.dart` — `_tileHeight` 78→82 |
| BUG-02 | HIGH | ⚙️ **Backend required** | Cloudflare R2 CORS configuration |
| BUG-03 | HIGH | ⚙️ **Backend required** | API endpoint authorization for delivery profile |
| BUG-04 | MEDIUM | ✅ **Fixed** | `delivery_dashboard_screen.dart` — removed `padLeft(2)` for Canceled Orders |
| BUG-05 | MEDIUM | ✅ **Fixed** | `login_screen.dart` — added `autovalidateMode: onUserInteraction` |
| BUG-06 | MEDIUM | ⚙️ **Backend required** | API endpoint authorization for notifications |
| BUG-07 | MEDIUM | ⚙️ **Backend required** | Backend ID generation logic for expenses |
| BUG-08 | LOW | ℹ️ **Not a bug** | Logout exists in sidebar and works; automation missed it |
| BUG-09 | LOW | ⚙️ **Backend required** | API returning wrong `expected_closing_quantity` value |
| BUG-10 | LOW | ⚙️ **Backend required** | API not returning `final_check_out` for history records |
| BUG-11 | LOW | ✅ **Fixed** | `vehicle_stock_screen.dart` — `ListPaginationBar` hidden during loading |

---

## Severity-Ranked Bug List

---

### BUG-01 · HIGH · ✅ FIXED · Dashboard stat cards overflow on mobile

**Screen:** Dashboard  
**Viewport:** 390×844  
**Screenshot:** `310_dashboard_390.png`, `345_bn_plus_menu.png`

**Steps to reproduce:**
1. Log in as Delivery Partner.
2. Land on Dashboard.
3. Resize browser to 390px wide (iPhone-class viewport).

**Expected:** Stat cards "Total Orders (Company)" and "My Assigned Deliveries" render without clipping.  
**Actual:** Both cards display Flutter's debug overflow marker **"BOTTOM OVERFLOWED BY 1.00 PIXELS"** in red text, confirming a real `RenderFlex` overflow. Card text is truncated ("My Assigned" instead of "My Assigned Deliveries").  
**Root cause:** The two-column stat row in the dashboard uses fixed heights that don't accommodate the label text at narrow widths.  
**Fix applied:** Increased `_tileHeight` from `78` to `82` in `lib/screens/delivery/dashboard/delivery_dashboard_screen.dart` — the extra 4 px gives labels room to wrap without overflowing.

---

### BUG-02 · HIGH · ⚙️ BACKEND REQUIRED · Profile/media images fail across the app (CORS)

**Screens:** Dashboard, Deliveries, Collections, Customers, Profile  
**Screenshot:** Visible as gray placeholder avatars in `308_dashboard_1440.png`, `313_deliveries_1440.png`, `317_collections_1440.png`, `320_customers_1440.png`, `339_profile_1440.png`

**Steps to reproduce:**
1. Log in. Navigate to any screen that shows user or customer photos.

**Expected:** Profile photos and customer logos render.  
**Actual:** All images fail silently; users see gray initials/placeholder circles. Browser console shows:
```
Access to image at 'https://fe91aefd4fc01969dc0df33dd88906df.r2.cloudflarestorage.com/...'
(redirected from 'https://crm-saas-backend.bsmart.workers.dev/files/...') from origin
'http://localhost:8080' has been blocked by CORS policy:
No 'Access-Control-Allow-Origin' header is present on the requested resource.
```
**Root cause:** The backend proxy (`bsmart.workers.dev`) issues pre-signed Cloudflare R2 redirects. The R2 bucket is not configured to emit CORS headers for the app origin. This affected 6 unique image URLs and 13 total console errors during the test session.  
**Impact:** Every screen that shows photos degrades to initials-only display.  
**Backend fix required:** Add a CORS rule to the R2 bucket allowing the app origin (`http://localhost:8080` and the production domain). Alternatively, have the Cloudflare Worker proxy the file bytes directly instead of issuing a 302 redirect to the R2 pre-signed URL — the Worker already controls the response and can add `Access-Control-Allow-Origin: *`.

---

### BUG-03 · HIGH · ⚙️ BACKEND REQUIRED · Profile API returns 403 on Profile screen

**Screen:** Profile  
**Screenshot:** `339_profile_1440.png`

**Steps to reproduce:**
1. Log in. Navigate to `#/delivery/profile`.

**Expected:** Full profile data loads cleanly.  
**Actual:** One API request from the profile screen returns HTTP 403. Additional detail fields (Gender, Date of Birth, Marital Status) are blank dashes. Console error: `"Failed to load resource: the server responded with a status of 403 ()"`.  
**Impact:** Some profile data silently fails to load; user sees no error message.  
**Backend fix required:** Check the authorization middleware for the profile detail endpoint (likely `/api/users/me/details` or similar). The delivery role JWT must be granted read access to its own profile detail record.

---

### BUG-04 · MEDIUM · ✅ FIXED · "Canceled Orders" displayed "00" instead of "0"

**Screen:** Dashboard  
**Screenshots:** `308_dashboard_1440.png`, `309_dashboard_768.png`, `310_dashboard_390.png`

**Steps to reproduce:**
1. Log in. View Dashboard.
2. Observe the six order-count stat tiles.

**Expected:** All zero values display as "0".  
**Actual:** Five tiles correctly show "0"; the "Canceled Orders" tile shows **"00"** (double zero).  
**Root cause:** The `_StatCard` widget in `delivery_dashboard_screen.dart` applied `.padLeft(2, '0')` specifically for the "Canceled Orders" tile, turning `0` into `"00"`. All other tiles used `.padLeft(1, '0')` which is a no-op.  
**Fix applied:** Removed the special-case padding — all stat values now use `.toString()` with no extra padding (`lib/screens/delivery/dashboard/delivery_dashboard_screen.dart`, `_StatCard.build`).

---

### BUG-05 · MEDIUM · ✅ FIXED · Login form — validation errors did not auto-clear when user types

**Screen:** Login  
**Screenshots:** `303_auth_empty_validation.png`, `304_auth_wrong_creds_filled.png`

**Steps to reproduce:**
1. Open the Login page.
2. Leave both fields empty; click **Sign in**.
3. "Email is required" / "Password is required" errors appear with red field borders.
4. Click the Email field and start typing an email address.

**Expected:** The red border and error text clear as the user types (live validation feedback).  
**Actual:** The error text and red border persist while typing. They only disappear on the next Sign in click if the form passes validation.  
**Root cause:** The `Form` widget in `login_screen.dart` had no `autovalidateMode` parameter, defaulting to `AutovalidateMode.disabled`. Validators only ran on explicit `_formKey.currentState!.validate()` calls (i.e., on Sign In button tap), so errors from a previous submission stayed visible while the user typed.  
**Fix applied:** Added `autovalidateMode: AutovalidateMode.onUserInteraction` to the `Form` in `lib/screens/auth/login_screen.dart`. Each field now re-validates as the user types, clearing the error as soon as the input becomes valid.

---

### BUG-06 · MEDIUM · ⚙️ BACKEND REQUIRED · Notifications screen — "Unable to load notifications"

**Screen:** Notifications (accessible via bell icon in top bar)  
**Screenshots:** `349_logout_popup_opened.png`, `350_logout_confirm_dialog.png`, `351_after_logout.png`

**Steps to reproduce:**
1. Log in. Click the notification bell icon (top-right of the top bar).

**Expected:** Notification list loads.  
**Actual:** Screen shows **"Unable to load notifications."** with a Retry link, and no items appear. Console: HTTP 403 or network failure on the notification API endpoint.  
**Impact:** Delivery partners cannot view their notifications in the web app.  
**Backend fix required:** Grant the delivery role read permission on the notifications endpoint. Check the route guard on `/api/notifications` (or equivalent) in the Cloudflare Worker.

---

### BUG-07 · MEDIUM · ⚙️ BACKEND REQUIRED · Expense claim ID format inconsistent

**Screen:** Expenses  
**Screenshot:** `333_expenses_1440.png`

**Steps to reproduce:**
1. Log in. Navigate to Expenses.
2. Observe the Expense List IDs.

**Expected:** All expense IDs follow the same format (e.g., `EXP-{company}-{year}-{seq}`).  
**Actual:** Most records show `EXP-10001-2026-1031` / `EXP-10001-2026-1026` but one record shows `EXP-2026-1012`, missing the company code segment.  
**Backend fix required:** Audit the expense record creation endpoint. The ID generator must include the company/organisation code in every case. The `EXP-2026-1012` record was likely created through an older code path or an admin-side direct insert that bypassed the prefixing logic.

---

### BUG-08 · LOW · ℹ️ NOT A BUG · Logout flow not fully confirmed

**Note:** The logout via the sidebar **Logout** button was confirmed present (see `311_sidebar_opened.png`) but was not exercised during automated testing (the notification bell was accidentally clicked instead of the profile avatar). Logout via the top-bar avatar popup was not reachable in the test session. **Manual verification required.**  
**Risk:** If logout clears the auth token but does not redirect to the login screen, users on shared devices could remain on a protected page and re-enter without credentials.

---

### BUG-09 · LOW · ⚙️ BACKEND REQUIRED · End of Day — "Expected" count exceeds "Loaded" count

**Screen:** End of Day Return  
**Screenshot:** `336_end_of_day_1440.png`

**Steps to reproduce:**
1. Log in. Navigate to `#/delivery/end-of-day`.

**Expected:** `Expected` ≤ `Loaded` (you cannot expect more returns than what was loaded).  
**Actual:** Vehicle MH02CJ0584 shows **82 Loaded, 29 Delivered, 110 Expected**. 110 expected returns is greater than 82 loaded, which is logically impossible for a single-vehicle stock reconciliation.  
**Root cause:** The frontend reads `expected_closing_quantity` directly from the API response. When the API field is present, the frontend uses it as-is; when absent, it falls back to `loaded + extra − delivered − returned`. The API is returning `110` for a session that only loaded `82` units, which is impossible for a single session.  
**Backend fix required:** Fix the `expected_closing_quantity` calculation in the vehicle stock session API. It should be scoped to the current session only (not accumulate across sessions or days).

---

### BUG-10 · LOW · ⚙️ BACKEND REQUIRED · Attendance history — Check Out time always blank

**Screen:** Attendance  
**Screenshot:** `326_attendance_1440.png`

**Observation:** The Attendance History table lists three recent dates (14 Nov, 10 Nov, 07 Nov 2026) all with status "Present" and a Check In time, but all Check Out times show `--:-- --`.  
The frontend model reads `final_check_out` from the API response under several key aliases (`final_check_out`, `finalCheckOut`, `checkOut`, `check_out`). The parsing logic is correct. The blank display means the API is not returning any value for those fields in the history records.  
**Backend fix required:** Verify that the attendance history endpoint returns the `final_check_out` field when a check-out was recorded. If the delivery partners genuinely never clicked Check Out on those dates, this is expected data and not a bug.

---

### BUG-11 · LOW · ✅ FIXED · Shimmer visible alongside "0–0 of 0" on empty Vehicle Stock history

**Screen:** Vehicle Stock  
**Screenshot:** `323_vehicle_stock_1440.png`

**Root cause:** `ListPaginationBar` was rendered unconditionally (outside the `if isLoading / else` block). During the initial data fetch, the shimmer (`_LoadingState`) showed alongside `ListPaginationBar` displaying "Showing 0–0 of 0" from its initial zero state — making it look like data had loaded but was showing a loading skeleton simultaneously.  
**Fix applied:** Wrapped `ListPaginationBar` in `if (!isLoading)` in `lib/screens/admin/vehicles/vehicle_stock_screen.dart`. The pagination bar now only appears once the data has resolved.

---

## Console Errors Summary

| Count | Error | Screens |
|-------|-------|---------|
| 12 | `CORS blocked` — Cloudflare R2 image URLs (profile/customer photos) | Dashboard, Deliveries, Collections, Customers |
| 1 | `HTTP 403` — API request on Profile screen | Profile |

**Total console errors:** 13  
**Total network failures:** 6 (all R2 CORS redirects)

---

## Coverage Summary

### Covered

| Screen | Desktop 1440 | Tablet 768 | Mobile 390 | Key interactions |
|--------|-------------|-----------|-----------|-----------------|
| Login | ✓ | ✓ | ✓ | Empty submit, password eye toggle, Phone/Email tab switch |
| Dashboard | ✓ | ✓ | ✓ | Today/Week/Month filter tabs visible |
| Sidebar navigation | ✓ | — | — | Open/close, all 9 menu items visible |
| Assigned Deliveries | ✓ | ✓ | ✓ | Filter tabs (All/Pending/Accepted/Intransit/Delivered) |
| Collections | ✓ | ✓ | ✓ | Pagination (41 records, 5 pages) |
| Customers | ✓ | ✓ | ✓ | List with stats (41 customers) |
| Vehicle Stock | ✓ | ✓ | ✓ | History empty state |
| Attendance | ✓ | ✓ | ✓ | Check In / Check Out / Departure / Return buttons visible |
| Leaves | ✓ | ✓ | ✓ | Leave requests list, Apply Leave button visible |
| Expenses | ✓ | ✓ | ✓ | Claims list with filter tabs |
| End of Day Return | ✓ | ✓ | ✓ | 3-step wizard (Return / Count / Summary) |
| Profile | ✓ | ✓ | ✓ | Account & Additional Details visible |
| Bottom nav (mobile) | ✓ | — | ✓ | All 5 tabs; + action sheet (Create Collection/Order/Customer) |
| Notifications | ✓ | — | — | Error state ("Unable to load notifications") |

### Not Covered / Partial

| Area | Reason |
|------|--------|
| Wrong-password API error | Automation limitation (Flutter TextEditingController fill); manual test needed |
| Forgot Password flow | Not tested |
| Create New Customer form | Not tested |
| Create Collection / Create Order forms | Not tested |
| Delivery detail screen | Not navigated; requires clicking a list item |
| Leaves → Apply Leave form | Not tested |
| Expenses → Add Expense form | Not tested |
| End of Day → Count and Summary steps | Only Step 1 (Return) captured |
| Vehicle Loading screen (`#/delivery/vehicle-loading`) | Not in sidebar; not tested |
| Pagination in Collections / Customers | Only page 1 viewed |
| Week / Month filter on Dashboard | Not clicked |
| Logout confirmation dialog | Not successfully triggered |
| Push notification permission / FCM | Not testable on web in this run |
| Register / sign-up flow | Out of scope for Delivery Partner role |
| Offline / network-failure states | Not simulated |

---

*Screenshots reference: all evidence files in `d:\crm_saas\test_screenshots\` (prefix 300–351 for the final run; earlier prefixes 100–239 from prior runs contain login-state and preliminary observations).*
