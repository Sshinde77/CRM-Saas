# Test Plan — Beassuite CRM SaaS (Delivery Partner Role)

**Tester:** Manual QA  
**Date:** 2026-11-15  
**App version:** 1.0.0+1  
**Platform:** Flutter Web (Chrome)  
**Test account:** delivery@demo.com / Delivery@123  
**Role under test:** Delivery Partner  

---

## 1. Scope

### In-scope
- Authentication (email/password login, register, phone OTP tab)
- Delivery Partner workspace — all sidebar and bottom-nav screens
  - Dashboard
  - My Deliveries (schedule / order list)
  - Customers (list, create, detail, map)
  - Collections (payment collection)
  - Vehicle Stock
  - Vehicle Loading
  - Attendance
  - Leaves (apply & cancel)
  - Expenses (add receipt, approval flow)
  - End-of-Day return & reconciliation
  - Profile

### Out-of-scope (not testable with this credential)
- Admin dashboard and all admin-only screens
- Super-admin dashboard
- Accountant screens
- Backend API internals / database state

---

## 2. Test Environment

| Window Size | Label | Notes |
|---|---|---|
| 1440 × 900 | Desktop | Primary viewport |
| 768 × 1024 | Tablet | Mid-breakpoint |
| 390 × 844 | Mobile | Smallest supported |

---

## 3. Smoke Tests (must pass before deeper testing)

| ID | Description | Expected |
|---|---|---|
| SM-01 | App loads in Chrome without blank screen | Login page renders |
| SM-02 | Login with valid credentials navigates to Delivery Dashboard | Dashboard visible, no error |
| SM-03 | Sidebar opens and shows all 8 menu items | Menu items listed |
| SM-04 | Bottom navigation tabs work (Dashboard, Deliveries, +, Attendance, Collections) | Each tab navigates |
| SM-05 | Logout from sidebar | Returns to login screen |

---

## 4. Authentication

| ID | Description | Input | Expected |
|---|---|---|---|
| AUTH-01 | Login — valid credentials | delivery@demo.com / Delivery@123 | Navigates to Delivery Dashboard |
| AUTH-02 | Login — wrong password | delivery@demo.com / wrongpass | Error snackbar, stays on login |
| AUTH-03 | Login — empty email | (blank) / password | Validation error on email field |
| AUTH-04 | Login — empty password | email / (blank) | Validation error on password field |
| AUTH-05 | Login — malformed email | notanemail / password | Validation error |
| AUTH-06 | Password visibility toggle | click eye icon | Password shows/hides |
| AUTH-07 | Phone OTP tab | click Phone tab | Phone input + country code dropdown appears |
| AUTH-08 | Phone OTP — invalid number | submit without number | Error state |
| AUTH-09 | Register page navigation | click "Sign up" | Register page opens |
| AUTH-10 | Register — submit empty form | click Create organization | No crash; API or inline error |
| AUTH-11 | Register — navigate back to login | click Sign in | Login page opens |
| AUTH-12 | Google Sign-In button renders | visible | Google button visible |

---

## 5. Delivery Dashboard

| ID | Description | Expected |
|---|---|---|
| DASH-01 | Dashboard loads without error | Summary cards / tiles visible |
| DASH-02 | Loading state shown while API fetches | Skeleton loader or spinner |
| DASH-03 | Pull-to-refresh triggers reload | Data refreshed |
| DASH-04 | "Company Orders" shortcut tile navigates to company orders screen | Orders list opens |
| DASH-05 | Empty state: no data scenario (if applicable) | Empty state illustration shown |

---

## 6. My Deliveries

| ID | Description | Expected |
|---|---|---|
| DEL-01 | Screen loads; delivery schedule list shown | Cards or list items rendered |
| DEL-02 | Search/filter by order number | List filters correctly |
| DEL-03 | Status filter (All / Pending / Completed etc.) | Correct orders shown per status |
| DEL-04 | Tap a delivery card | Detail / order detail screen opens |
| DEL-05 | Order detail shows products, customer, address | All fields populated |
| DEL-06 | Mark delivery status action (if available) | Status updated or confirmation dialog |
| DEL-07 | Empty state when no deliveries | Empty state card visible |
| DEL-08 | Error state (network off) | Retry button and error message shown |

---

## 7. Customers

| ID | Description | Expected |
|---|---|---|
| CUST-01 | Customer list loads | List renders with avatars |
| CUST-02 | Search by name | List filters live |
| CUST-03 | Tap a customer card | Customer detail screen opens |
| CUST-04 | Customer detail shows address, contact, orders | Fields visible |
| CUST-05 | Phone call button (url_launcher) | Dial intent fires or link opens |
| CUST-06 | View on map button | Map screen opens with pin |
| CUST-07 | Create new customer via FAB / bottom nav + | Create customer screen opens |
| CUST-08 | Create customer — empty form submit | Validation messages shown |
| CUST-09 | Create customer — valid data | Success, returns to list |
| CUST-10 | Pagination — next/prev page | Page changes, different records |
| CUST-11 | Empty state (no customers) | Empty state shown |

---

## 8. Collections (Payment Collection)

| ID | Description | Expected |
|---|---|---|
| COL-01 | Collections screen loads | List of collections or empty state |
| COL-02 | Create new collection via + action | Form/sheet opens |
| COL-03 | Collection form — select customer | Customer picker works |
| COL-04 | Collection form — enter amount | Numeric input accepted |
| COL-05 | Collection form — select payment mode | Dropdown works |
| COL-06 | Submit valid collection | Success, record appears in list |
| COL-07 | Submit empty collection form | Validation errors |
| COL-08 | Filter by status | Filtered results shown |

---

## 9. Vehicle Stock

| ID | Description | Expected |
|---|---|---|
| VS-01 | Vehicle Stock screen loads | Products list or stock table visible |
| VS-02 | Product rows show name, quantity | Data populated |
| VS-03 | Search by product name | Filters list |
| VS-04 | Empty state | Appropriate empty state |

---

## 10. Vehicle Loading

| ID | Description | Expected |
|---|---|---|
| VL-01 | Vehicle Loading screen loads | Form / list visible |
| VL-02 | Select products to load | Product selection works |
| VL-03 | Submit loading | Success confirmation |

---

## 11. Attendance

| ID | Description | Expected |
|---|---|---|
| ATT-01 | Attendance screen loads | List of attendance records |
| ATT-02 | Calendar view opens | Month calendar with colored day cells |
| ATT-03 | Day selection shows details | Detail card for selected date |
| ATT-04 | Previous/Next month navigation | Calendar updates |
| ATT-05 | Check-in action (if available) | Check-in recorded |
| ATT-06 | Empty state (no records) | Proper message |

---

## 12. Leaves

| ID | Description | Expected |
|---|---|---|
| LEAVE-01 | Leaves screen loads | Leave list or empty state |
| LEAVE-02 | Apply for leave — open form | Date picker and type selector |
| LEAVE-03 | Apply leave — empty form submit | Validation errors |
| LEAVE-04 | Apply leave — valid dates | Submitted, appears pending |
| LEAVE-05 | Cancel a pending leave | Confirmation dialog, then removed/cancelled |
| LEAVE-06 | Filter by status (all / pending / approved) | Filtered list |
| LEAVE-07 | Pagination | Next/prev page works |

---

## 13. Expenses

| ID | Description | Expected |
|---|---|---|
| EXP-01 | Expenses screen loads | Expense list or empty state |
| EXP-02 | Add expense — form opens | Fields visible |
| EXP-03 | Add expense — empty submit | Validation messages |
| EXP-04 | Add expense — valid data with receipt photo | Submission succeeds |
| EXP-05 | Filter by status (All / Pending / Approved etc.) | Correct records shown |
| EXP-06 | Expense detail / approval status visible | Status pill shown |
| EXP-07 | Search by description | Filters list |

---

## 14. End-of-Day Return

| ID | Description | Expected |
|---|---|---|
| EOD-01 | End of Day screen loads | Step 1 (Return Stock) visible |
| EOD-02 | Enter return quantities | Input accepts numbers |
| EOD-03 | Proceed to Reconcile step | Step 2 visible |
| EOD-04 | Reconciliation form fills expected vs actual | Fields editable |
| EOD-05 | Proceed to Summary step | Summary screen shown |
| EOD-06 | No active vehicle session — empty state | "No active session" message |
| EOD-07 | Submit reconciliation | Success, locked state |

---

## 15. Profile

| ID | Description | Expected |
|---|---|---|
| PROF-01 | Profile screen loads | Name, email, role visible |
| PROF-02 | Edit profile details (if available) | Form opens |
| PROF-03 | Change password (if available) | Fields and submit work |

---

## 16. Cross-Cutting / Layout

| ID | Description | Expected |
|---|---|---|
| LAYOUT-01 | Desktop (1440px) — sidebar visible | Sidebar nav renders correctly |
| LAYOUT-02 | Tablet (768px) — sidebar vs bottom nav behavior | Appropriate layout |
| LAYOUT-03 | Mobile (390px) — bottom nav visible | Bottom bar shown, no overflow |
| LAYOUT-04 | No horizontal scroll at any size | Content contained |
| LAYOUT-05 | Text truncation on long names | Ellipsis, no overflow |
| LAYOUT-06 | Dark mode (if available) | Colors adapt |

---

## 17. Error & Network States

| ID | Description | Expected |
|---|---|---|
| NET-01 | Throttle/block network — any screen | Error state card with retry button |
| NET-02 | Retry after restoring network | Data loads successfully |
| NET-03 | Expired/invalid session | Redirected to login |
| NET-04 | 500 error from API | User-friendly error, not raw exception |

---

## 18. Console / JS Errors

- After each screen visit, check Chrome DevTools console for errors, warnings, and failed network requests.
- Record any `Uncaught`, `TypeError`, `null dereference`, or red-network entries.

---

## Evidence
- Screenshots saved to: `d:\crm_saas\test_screenshots\`
- Bug report: `BUG_REPORT.md`
