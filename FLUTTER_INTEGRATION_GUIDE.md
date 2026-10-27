# Flutter Integration Guide — Staff OTP Login (Twilio) and the New Backend APIs

**From:** Backend team · **To:** Flutter developer · **Backend changes as of:** 2026-10-26

This guide explains, end to end, how the backend works for the features added recently, and
what the Flutter app must send and handle. It covers everything listed as new or changed in
**API_LIST.md** and **API_USAGE_GUIDE.md** ("Action required" A–G), with the backend flow
behind each one.

If the backend's actual response ever differs from this guide, report it to the backend team as
a bug rather than coding around it.

---

## Contents
1. [Basics: base URL, headers, errors](#1-basics-base-url-headers-errors)
2. [Sessions and tokens (shared by every login method)](#2-sessions-and-tokens-shared-by-every-login-method)
3. [Staff mobile OTP login (Twilio Verify)](#3-staff-mobile-otp-login-twilio-verify)
4. [Forgot / reset password by email link](#4-forgot--reset-password-by-email-link)
5. [GET /auth/me: new fields](#5-get-authme-new-fields)
6. [Staff mobile numbers are unique](#6-staff-mobile-numbers-are-unique)
7. [Category → Brand in the product form](#7-category--brand-in-the-product-form)
8. [Removed endpoints](#8-removed-endpoints)
9. [Fixed endpoints (no app change)](#9-fixed-endpoints-no-app-change)
10. [Quick reference: every new or changed endpoint](#10-quick-reference-every-new-or-changed-endpoint)
11. [Testing checklist for the Flutter app](#11-testing-checklist-for-the-flutter-app)

---

## 1. Basics: base URL, headers, errors

- **Base URL:** `https://crm-saas-backend.bsmart.workers.dev`
- **Body:** JSON, `Content-Type: application/json`, field names in `snake_case`.
- **Auth header:** `Authorization: Bearer <access_token>` on every call **except** the public
  ones: `/auth/login`, `/auth/register`, `/auth/refresh`, `/auth/forgot-password`,
  `/auth/reset-password`, `/auth/phone/send-otp`, `/auth/phone/verify-otp` and the Google
  sign-in endpoints.
- **Error body:** every error has a `detail` field. It's usually a string:
  ```json
  { "detail": "Invalid or expired OTP" }
  ```
  Schema-validation errors (422) return a list instead:
  ```json
  { "detail": [ { "loc": ["body", "phone"], "msg": "Field required", "type": "missing" } ] }
  ```
  Handle both: if `detail` is a `String`, show it; if it's a `List`, map each `loc` to a form
  field and show its `msg`.

**What each status code means for the app:**

| Code | Meaning | App behaviour |
|---|---|---|
| 200 / 201 | Success | — |
| 400 | Bad input or a business rule failed (e.g. wrong OTP) | Show `detail` on the form. **Never log out.** |
| 401 | Session invalid or expired | Try `/auth/refresh` once; if that fails, go to Login |
| 403 | Not allowed (permissions, or a locked trial) | Show `detail`. Don't retry |
| 404 | Not found, or it belongs to another firm | Show "not found" |
| 409 | Conflict (duplicate value, concurrent edit) | Show `detail` on the field, or reload |
| 422 | Validation | Field errors (see above) |
| 429 | Rate limited | Show `detail`, disable the button, let the user try later. **Don't auto-retry** |
| 502 | Upstream provider (Twilio) failed | "Temporarily unavailable"; offer another way in |
| 503 | Feature not configured on the server | Hide or disable that feature |

> **Important:** the backend uses **401 only** for "your session is invalid". A wrong OTP, a
> bad reset token or a wrong form value is **never** 401. So a Dio/HTTP interceptor that refreshes
> or logs out on 401 is safe, as long as it reacts to 401 only.

---

## 2. Sessions and tokens (shared by every login method)

Password login, Google login and the new **phone OTP login** all end in exactly the same backend
step, so they return **the same response** and create the same kind of session.

**Login response** (from `POST /auth/login` and `POST /auth/phone/verify-otp`):
```json
{
  "user": { "id": "…", "name": "…", "email": "…", "phone": "…", "system_role": "staff",
            "phone_verified": true, "last_login": "2026-10-26T10:15:00Z", "...": "..." },
  "organization": { "id": "…", "name": "…", "status": "trial", "...": "..." },
  "tokens": { "access_token": "eyJ…", "refresh_token": "eyJ…", "token_type": "bearer" }
}
```

| Token | Lifetime | Use |
|---|---|---|
| `access_token` | **30 minutes** | `Authorization: Bearer …` on every API call |
| `refresh_token` | **30 days** | Get a new access token via `/auth/refresh` |

**Refresh:** `POST /auth/refresh` with `{ "refresh_token": "…" }` returns
`{ "access_token": "…", "refresh_token": "…", "token_type": "bearer" }`. The refresh token is not
rotated (you get the same one back). A 401 here means log the user out.

**Logout:** `POST /auth/logout` with `{ "refresh_token": "…" }`. It always succeeds; clear the
tokens on the device.

**After any login:** call `GET /auth/me` (section 5) to load the role, permissions and workspace.

Store tokens in secure storage (e.g. `flutter_secure_storage`), not in plain preferences.

---

## 3. Staff mobile OTP login (Twilio Verify)

### 3.1 What it is and who can use it
- Staff sign in with **their mobile number and a 6-digit SMS code**, with no password.
- **Staff accounts only.** Admins and Super Admins can **never** sign in this way: they use
  email/password or Google. If an admin tries OTP, the backend behaves as if the number weren't
  registered (no SMS is sent).
- OTP never creates accounts. The staff member must already exist, with their mobile number
  set by an admin.
- Indian mobile numbers only.

### 3.2 How the backend does it

```
 Flutter app                       CRM backend                                Twilio Verify
 ───────────                       ───────────                                ─────────────
 [Enter mobile]
     │ POST /auth/phone/send-otp {phone}
     ├──────────────────────────────►│ 1. Normalize number → +91XXXXXXXXXX
     │                               │ 2. Check rate limits (per number + per IP)
     │                               │ 3. Find exactly ONE active staff account
     │                               │    with this number
     │                               │      ├─ found ──► 4. Ask Twilio to text a code ──►│ sends SMS
     │                               │      └─ not found / admin / ambiguous: no SMS     │ (code made,
     │◄──────────────────────────────┤ 5. Same generic 200 either way                    │ stored and
     │  200 {detail, resend_after:30}│                                                    │ expired by
 [Enter 6-digit code]                                                                    │ Twilio)
     │ POST /auth/phone/verify-otp {phone, code}                                          │
     ├──────────────────────────────►│ 1. Normalize number; check code is 6 digits
     │                               │ 2. Check failed-attempt limit for this number
     │                               │ 3. Find the ONE eligible staff account again
     │                               │ 4. Ask Twilio "is this code right?" ──────────────►│
     │                               │◄──────────────────────────── approved / rejected ──┤
     │                               │ 5a. Rejected → count a failed attempt → 400
     │                               │ 5b. Approved → re-check the account is still active,
     │                               │     set phone_verified=true and last_login=now,
     │                               │     write audit "Logged in via phone OTP",
     │                               │     issue tokens exactly like password login
     │◄──────────────────────────────┤ 200 {user, organization, tokens}
 [Store tokens → GET /auth/me → home]
```

Key points:
- **The backend never sees or stores the code.** Twilio Verify generates it, texts it, expires
  it (validity is set on the Twilio Verify service; Twilio's default is 10 minutes) and checks
  it. The backend only passes the user's attempt through.
- **The app never tells the backend who the user is.** Only `phone` and `code` are sent; the
  backend works out the account from the number. Never send a user id, org id or role.
- **The send step never reveals whether a number is registered.** A registered and an
  unregistered number get the same 200. So never show "number not found"; always say
  "If this number is registered, an OTP has been sent."

### 3.3 Phone number input
The backend accepts any of these spellings and normalizes them to `+91XXXXXXXXXX`:

| User types | Accepted |
|---|---|
| `9876543210` | ✅ |
| `+91 98765-43210` | ✅ |
| `09876543210` | ✅ |
| `919876543210` | ✅ |
| `080 2345 6789` (landline) | ❌ 422 |
| `+1 415 555 0100` (non-Indian) | ❌ 422 |
| `12345` | ❌ 422 |

Recommended UI: a `+91` prefix label plus a 10-digit numeric field. Send the 10 digits, or
`+91…`. Both work. **Send the same value in step 1 and step 2.**

### 3.4 Step 1 — `POST /auth/phone/send-otp`

**Request**
```json
{ "phone": "9876543210" }
```

**Responses**

| Status | Body | Flutter action |
|---|---|---|
| **200** | `{"detail": "If this number is registered, an OTP has been sent.", "resend_after": 30}` | Go to the code screen. Start a **`resend_after`-second countdown** before enabling "Resend OTP". |
| 422 | validation detail | "Enter a valid 10-digit Indian mobile number" |
| 429 | `{"detail": "Too many attempts. Please try again later."}` | Show `detail`; keep Send/Resend disabled |
| 400 | `{"detail": "Invalid phone number or OTP"}` | Show `detail` (Twilio rejected the number) |
| 502 | `{"detail": "Phone login is temporarily unavailable"}` | Show it; suggest email/password login |
| 503 | `{"detail": "Phone login not configured"}` | Hide the "Login with mobile" option |

**Send limits** (checked before anything else, the same for every number):
- 1 request per number per **30 seconds**: that's what `resend_after` is for
- 5 requests per number per **15 minutes**
- 10 requests per number per **day**
- 30 requests per device IP per **hour**

### 3.5 Step 2 — `POST /auth/phone/verify-otp`

**Request**
```json
{ "phone": "9876543210", "code": "123456" }
```
`code` must be **exactly 6 digits** (validate in the UI: numeric keyboard, `maxLength: 6`).

**Responses**

| Status | Body | Flutter action |
|---|---|---|
| **200** | Same as `/auth/login`: `{user, organization, tokens}` | Save the tokens, call `GET /auth/me`, go home |
| **400** | `{"detail": "Invalid or expired OTP"}` | Show it under the code field; let them retry or resend. **Do not log out or refresh tokens.** |
| 429 | `{"detail": "Too many attempts. Please try again later."}` | 5 **wrong** codes per number per 15 minutes; the 6th try is blocked (even with the right code) until the window passes |
| 502 / 503 | as in step 1 | as in step 1 |

400 "Invalid or expired OTP" covers: a wrong code, an expired code, a code already used, a code
that isn't 6 digits, and a number that isn't an eligible staff account. A successful verify does
**not** count against the limit.

### 3.6 Example (Dart, using `dio`)
```dart
Future<int?> sendOtp(Dio dio, String phone) async {
  try {
    final r = await dio.post('/auth/phone/send-otp', data: {'phone': phone});
    return r.data['resend_after'] as int; // start the countdown
  } on DioException catch (e) {
    final code = e.response?.statusCode;
    final detail = e.response?.data?['detail'];
    if (code == 503) { /* hide mobile login */ }
    throw OtpError(detail is String ? detail : 'Enter a valid 10-digit Indian mobile number');
  }
}

Future<void> verifyOtp(Dio dio, String phone, String code) async {
  final r = await dio.post('/auth/phone/verify-otp', data: {'phone': phone, 'code': code});
  final tokens = r.data['tokens'];
  await secureStorage.write(key: 'access_token', value: tokens['access_token']);
  await secureStorage.write(key: 'refresh_token', value: tokens['refresh_token']);
  // then: GET /auth/me → route to the workspace, exactly as after password login
}
```
Make sure your 401 interceptor does **not** run for these two calls; they never return 401.

### 3.7 Screens to build
1. Login screen: add a "Login with mobile" button. Hide it if send-otp ever returns 503.
2. Mobile screen: `+91` plus 10 digits → **Send OTP**.
3. Code screen: 6 boxes or a numeric field, "Verify", and "Resend OTP (30s)" with a countdown.
4. On success, reuse the existing password-login success path.

---

## 4. Forgot / reset password by email link

### 4.1 How the backend does it
```
 App: "Forgot password?" → enter email
   │ POST /auth/forgot-password {email}
   ▼
 Backend: rate-limit check → finds the account (case-insensitive) → if active, creates a single-use
          token (only its hash is stored) → emails the link  <FRONTEND_RESET_URL>?token=<token>
          → always answers the same generic 200
   │
 User opens the email → taps the link → reset page (web, or the app if it handles the link)
   │ POST /auth/reset-password {token, new_password, confirm_password}
   ▼
 Backend: consumes the token (one use only) → sets the new password → signs out ALL of that
          user's existing sessions → 200. It does NOT sign the user in.
   │
 App → Login screen → the user signs in with the new password
```

### 4.2 `POST /auth/forgot-password`
**Request:** `{ "email": "user@firm.com" }`

| Status | Body | Action |
|---|---|---|
| 200 | `{"detail": "If that email is registered, a reset link has been sent.", "reset_token": null}` | Show the `detail` text. Never say whether the account exists |
| 429 | `{"detail": "Too many attempts. Please try again later."}` | Limits: 3 per email per 15 min (10 per day), 10 per IP per hour |
| 422 | validation | "Enter a valid email" |

### 4.3 The reset link
- Format: **`<FRONTEND_RESET_URL>?token=<token>`**. The backend sets `FRONTEND_RESET_URL`; it's
  one URL for all clients.
- Valid for **30 minutes**, usable **once**. Requesting a new link cancels older ones.
- **Flutter:** if the app should open these links itself, register that URL's host and path as
  an Android App Link / iOS Universal Link and read `token` from the query string. Otherwise the
  link opens the web reset page and the user then signs in on the app. Tell the backend team
  the final path either way.

### 4.4 `POST /auth/reset-password`
**Request**
```json
{ "token": "<from the link>", "new_password": "NewPass@123", "confirm_password": "NewPass@123" }
```
`confirm_password` is optional, but if you send it, it must match. Check in the UI as well that
the passwords match and have at least 8 characters.

| Status | Body | Action |
|---|---|---|
| 200 | `{"detail": "Password has been reset. Please log in."}` | Clear any stored tokens (they're revoked) and go to **Login** |
| 400 | `{"detail": "Invalid or expired reset token"}` | "This link has expired or was already used", plus "Send a new link" |
| 422 | validation | Password under 8 characters, or confirm mismatch |

---

## 5. `GET /auth/me`: new fields

Call it after every login and on app start. These fields were **added** (nothing was removed):

| Field | Type | Meaning |
|---|---|---|
| `phone_verified` (top level) | bool | `true` once this account has signed in by OTP. Resets to `false` if an admin changes the staff member's number |
| `user.phone_verified` | bool | Same value, inside `user` |
| `user.last_login` | ISO datetime or `null` | Last sign-in by any method (password, Google, OTP) |

The rest is unchanged: `id`, `organization_id`, `name`, `role` (with `workspace`), `permissions`,
`full_access`, `data_scope`, `user`, `organization`, `theme`.

---

## 6. Staff mobile numbers are unique

Because the mobile number identifies the account for OTP login, **each staff mobile number can
belong to only one staff account, across all firms**.

- `POST /users` (create staff) and `PATCH /users/{id}` (edit staff) answer:
  **409** `{"detail": "This mobile number is already assigned to another staff account"}`.
  Show it on the mobile-number field.
- Every spelling of a number counts as the same number (`9876543210` = `+91 98765-43210`).
- **Admin** numbers may be shared and never cause this error.
- Saving a staff member without changing their number never triggers it.

---

## 7. Category → Brand in the product form

### 7.1 How the backend decides which brands a category allows
- An admin can limit a **top-level category** to certain brands.
- **No brands configured for a category** means **every active brand** is allowed.
- **Some brands configured** means only those (and only the active ones) are offered.
- **Sub categories** never take brand mappings; they have Product Types instead.

### 7.2 Product form: pick Category first, then Brand
`GET /categories/{category_id}/brands` → **200** list of brands (same shape as `GET /brands`
items), active only, sorted by name.

```json
[ { "id": "…", "organization_id": "…", "name": "Havells", "description": null,
    "is_active": true, "created_at": "…", "updated_at": "…" } ]
```
- 404: category not found (or another firm's). 422: it's a sub category.
- Call it whenever the selected **top-level** Category changes, and fill the Brand dropdown with
  the result as given.

### 7.3 Saving a product
`POST /products` and `PATCH /products/{id}` can answer **422** with:
- `"Brand is not mapped to the selected category."`
- `"This brand is inactive and cannot be chosen"`

Show these on the Brand field. Existing products keep their current brand even if it was later
unmapped or deactivated; only *changing* the category or brand is checked.

### 7.4 Managing the mapping (Category settings, admin)
`PUT /categories/{category_id}/brands` with `{ "brand_ids": ["…", "…"] }` (needs `products.edit`):
- **Replaces** the whole list. `[]` removes the restriction (every active brand again).
- 200 → the mapped brands, inactive ones included, sorted by name.
- 400: a brand id is unknown or from another firm. 422: sub category. 409: someone saved at
  the same moment (reload and retry).

### 7.5 Brands list
Each item of `GET /brands` now includes `"categories": [{"id": "…", "name": "Fans"}]`. Show them as
chips; there's no need for a call per brand.

### 7.6 Other changes
- `POST /brands/{id}/categories` (link from the brand side) answers **422** for a sub category.
- Linking a product to a supplier no longer creates category–brand mappings automatically.

---

## 8. Removed endpoints
These now answer **404**. Remove any calls to them:
- `POST /auth/reset-password-direct` (it reset a password from just an email; that was insecure)
- `POST /auth/check-email`

Use the email-link flow in section 4.

---

## 9. Fixed endpoints (no app change)
These used to fail with **HTTP 500** on production and now work. Their request and response
shapes didn't change:
- `POST /grns/{id}/confirm` (confirm a Goods Receipt)
- `POST /supplier-invoices/{id}/record`
- `POST /supplier-payments` and `POST /supplier-payments/{id}/void`
- Legacy `POST` / `DELETE /suppliers/{id}/payments`
- `POST /invoices/{id}/payment-link` (create a Razorpay payment link)

If the app added workarounds for these errors, remove them.

---

## 10. Quick reference: every new or changed endpoint

| Method | Path | Auth | Body | Success | Errors |
|---|---|---|---|---|---|
| POST | `/auth/phone/send-otp` 🆕 | none | `{phone}` | 200 `{detail, resend_after}` | 400, 422, 429, 502, 503 |
| POST | `/auth/phone/verify-otp` 🆕 | none | `{phone, code}` | 200 login response | 400, 429, 502, 503 |
| POST | `/auth/forgot-password` ⚠️ | none | `{email}` | 200 generic | 422, 429 |
| POST | `/auth/reset-password` ⚠️ | none | `{token, new_password, confirm_password?}` | 200 | 400, 422 |
| GET | `/auth/me` ⚠️ | Bearer | — | 200 (+ `phone_verified`) | 401 |
| POST/PATCH | `/users`, `/users/{id}` ⚠️ | Bearer (admin) | staff profile | 201 / 200 | 409 duplicate staff mobile |
| GET | `/categories/{id}/brands` 🆕 | Bearer | — | 200 list of brands | 404, 422 |
| PUT | `/categories/{id}/brands` 🆕 | Bearer (`products.edit`) | `{brand_ids}` | 200 mapped brands | 400, 409, 422 |
| GET | `/brands` ⚠️ | Bearer | — | 200 (+ `categories` per brand) | — |
| POST | `/brands/{id}/categories` ⚠️ | Bearer | `{category_id}` | 201 | 400, 404, 422 sub category |
| POST/PATCH | `/products`, `/products/{id}` ⚠️ | Bearer | product | 201 / 200 | 422 brand not mapped / inactive |
| POST | `/auth/reset-password-direct` ❌ | — | — | removed (404) | — |
| POST | `/auth/check-email` ❌ | — | — | removed (404) | — |

🆕 new · ⚠️ changed · ❌ removed

---

## 11. Testing checklist for the Flutter app

**OTP login**
- [ ] Valid staff number → SMS arrives → correct code → logged in; `/auth/me` shows `phone_verified: true`
- [ ] Wrong code → 400 shown on the code field, user **not** logged out
- [ ] "Resend OTP" disabled for 30 s; tapping too early → 429 handled
- [ ] 5 wrong codes → 6th attempt shows the 429 message
- [ ] Admin's number → generic message, no SMS, can't log in by OTP
- [ ] Unregistered number → the same generic message (never "not found")
- [ ] `+91 98765-43210` and `09876543210` work the same as `9876543210`
- [ ] Landline or foreign number → 422 message

**Password reset**
- [ ] Forgot password → generic message for both known and unknown emails
- [ ] Reset link opens the reset page (or app); new password works; old one doesn't
- [ ] Using the same link twice → "link expired or already used"
- [ ] After a reset, sessions on other devices are signed out (their next refresh → 401 → Login)

**Products**
- [ ] Picking a category loads its brands; unmapped categories show all active brands
- [ ] A 422 brand error shows on the Brand field
- [ ] Brands list shows category chips

**Staff management**
- [ ] Giving a staff member another staff member's number → 409 shown on the field
