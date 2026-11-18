# Delivery Collection Status — Problem & Fix Guide

**For:** Backend Developer  
**From:** Flutter Frontend Team  
**Topic:** Collection approval flow for the Delivery Partner app

---

## The Problem (Plain English)

Right now, when a delivery partner collects payment from a customer, the app only shows two states:

- **Pending** — customer has an outstanding balance (needs collection)
- **Collected** — payment was collected and approved by admin

**What is missing** is the middle state:

> "Payment has been submitted by the delivery partner — waiting for admin to approve"

So currently the flow looks like this in the app:

```
Customer has balance  →  Collect button  →  [NOTHING VISIBLE]  →  Appears in Collected list
```

What it should look like:

```
Customer has balance  →  Collect button  →  "Pending Approval" badge  →  Appears in Collected list
```

---

## Why This Is a Problem

### Problem 1 — Delivery partner has no feedback
After submitting a collection, the customer **still shows the "Collect" button** in the Pending list.  
The delivery partner does not know if their submission went through or is waiting for admin.

### Problem 2 — Double collection risk
Because the customer's outstanding balance does not change until admin approves, **every delivery partner** sees the same customer as "needs collection."  
If Delivery Man A collects from Customer X, Delivery Man B still sees Customer X with a Collect button and can collect again — resulting in a **double collection**.

---

## How the App Currently Works (Frontend)

The Pending list screen makes **two API calls** on load:

| Call | Endpoint | What it returns |
|---|---|---|
| Delivery collections | `GET /deliveries/collections` | Collections submitted by **this delivery partner only** (auth-scoped) |
| Customers with balance | `GET /customers?is_active=true` | **All** customers with `outstanding > 0` (global, not scoped) |

The Pending tab shows customers from the second call.  
The Collected tab shows records from the first call where `amountCollected > 0`.

There is no way on the frontend to know if another delivery partner already submitted a collection for a customer — because `/customers` just returns outstanding balance for everyone.

---

## What We Need From the Backend

### Fix 1 — Add `collection_status` to the customer list (Most Important)

In the `GET /customers` response (or a new delivery-scoped endpoint), add a field per customer that tells the app whether a collection is already in progress:

```json
{
  "id": "cust_123",
  "name": "ABC Traders",
  "outstanding": 5000,
  "collection_status": "pending_approval"
}
```

**Possible values for `collection_status`:**

| Value | Meaning |
|---|---|
| `null` or field absent | No collection submitted — show Collect button |
| `"pending_approval"` | A collection has been submitted, waiting for admin to approve |
| `"approved"` | Admin approved — balance will clear soon |

This one field on the customer list solves **both problems** at once:
- The delivery partner who collected sees "Pending Approval" — no confusion
- Other delivery partners also see "Pending Approval" — no double collection

---

### Fix 2 — Add `reconciliation_status` to `/deliveries/collections` response (Already Partially Done)

The app already reads `reconciliation_status` from the collections API. We just need consistent values so the Collected tab can show the right badge.

Please return one of these values for each collection:

| Value | Meaning | UI |
|---|---|---|
| `"recorded"` or `"pending_approval"` | Submitted, admin has not approved yet | Amber "Awaiting Approval" badge |
| `"approved"` or `"reconciled"` | Admin approved | Green "Collected" badge |
| `"voided"` | Rejected/cancelled | Not shown (already filtered out) |

---

## Recommended API Changes Summary

### Option A — Minimal change (Recommended)

Add `collection_status` to the existing `GET /customers` response:

```
GET /customers?is_active=true

Response per customer:
{
  "id": "...",
  "name": "...",
  "outstanding": 5000.00,
  "collection_status": "pending_approval" | "approved" | null
}
```

Logic on backend:
- If a payment collection record exists for this customer with status = pending/recorded → return `"pending_approval"`
- If status = approved/reconciled and balance not yet cleared → return `"approved"`
- Otherwise → return `null`

---

### Option B — New delivery-scoped customer endpoint

Create a new endpoint specifically for the delivery partner app that returns only the customers assigned to or reachable by that delivery partner, with collection status baked in:

```
GET /delivery/customers?include_collection_status=true
```

This is cleaner long-term but more work. Option A is enough to solve both problems immediately.

---

## What the Frontend Will Do After Backend Sends This

Once `collection_status` is available on the customer object, the Flutter app will:

1. **Pending List tile** — check `collection_status`:
   - `null` → show **Collect** button (current behavior)
   - `"pending_approval"` → show amber **"Awaiting Approval"** chip, no Collect button
   - `"approved"` → show green **"Approved"** chip, no Collect button

2. **No double-collection** — since the Collect button is hidden when `collection_status` is set, another delivery partner cannot re-submit.

3. **Collected List tile** — use `reconciliation_status` from `/deliveries/collections` to show:
   - Amber clock icon → `"pending_approval"` / `"recorded"`
   - Green checkmark → `"approved"` / `"reconciled"`

---

## Summary Table

| Issue | Root Cause | Fix Needed |
|---|---|---|
| Delivery partner sees Collect button after submitting | `outstanding` does not change until approval, no status field on customer | Add `collection_status` to customer API response |
| Another delivery partner can double-collect | Customer list is global with no pending-collection flag | Same fix — `collection_status` hides the Collect button for everyone |
| No approval progress visible in Collected tab | `reconciliation_status` values not standardized | Confirm and document `reconciliation_status` values in collection response |

---

## Questions for Backend Developer

1. What is the exact `reconciliation_status` value returned when a delivery partner submits a collection but admin has not approved yet? (Is it `"recorded"`, `"pending_approval"`, or something else?)
2. Is there a concept of "assigned customers" per delivery partner, or can any delivery partner collect from any customer?
3. Is Option A (adding `collection_status` to the existing `/customers` endpoint) feasible, or would it be better as a new delivery-specific endpoint?
