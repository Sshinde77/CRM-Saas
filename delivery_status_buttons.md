# Delivery Status → Button Mapping

Reference for `assigned_deliveries_screen.dart`.  
Each delivery has two status fields: **`status`** (outer) and **`internalStatus`** (sub-state used when status = `accepted`).

---

## Status Combinations & Buttons

| `status` | `internalStatus` | Primary Action Button | Secondary Buttons | Reject Button |
|---|---|---|---|---|
| `planned` | _(any)_ | ✅ **Accept** (green) | — | ✅ Yes |
| `pending` | _(any)_ | ✅ **Accept** (green) | — | ✅ Yes |
| `accepted` | `accepted` | 🔵 **Prepare Delivery** (blue) | 📞 Call · 🗺 Navigate | — |
| `accepted` | `ready` | 🔵 **Load Vehicle** (blue) | 📞 Call · 🗺 Navigate | — |
| `accepted` | `loaded` | 🔵 **Start Delivery** (blue) | 📞 Call · 🗺 Navigate | — |
| `in_transit` | _(any)_ | ✅ **Mark Delivered** (green) | 📞 Call · 🗺 Navigate | — |
| `delivered` | _(any)_ | — | — | — |

> **Call / Navigate** buttons appear whenever `canContactCustomer` is true → `status == 'accepted' || status == 'in_transit'`

---

## Code References

| Condition | Getter | File:Line |
|---|---|---|
| `canRespond` | `status == 'planned' \|\| status == 'pending'` | `assigned_deliveries_screen.dart:2175` |
| `canPrepareDelivery` | `status == 'accepted' && internalStatus == 'accepted'` | `:2177` |
| `canLoadDelivery` | `status == 'accepted' && internalStatus == 'ready'` | `:2180` |
| `canStartDelivery` | `status == 'accepted' && internalStatus == 'loaded'` | `:2182` |
| `canMarkDelivered` | `status == 'in_transit'` | `:2185` |
| `canContactCustomer` | `status == 'accepted' \|\| status == 'in_transit'` | `:2187` |

Button priority order (first match wins) is defined in `_DeliveryCardAction.forDelivery()` at `:1348`:
1. Accept (canRespond)
2. **Start Delivery (canStartDelivery)** ← checked before Prepare/Load
3. Prepare Delivery (canPrepareDelivery)
4. Load Vehicle (canLoadDelivery)
5. Mark Delivered (canMarkDelivered)

---

## 🐛 Problem: "Start Delivery" Button Should Be Removed

**When it appears:** `status == 'accepted'` AND `internalStatus == 'loaded'`

**What it does:** Calls `provider.dispatchDelivery(delivery.id)` which moves the delivery to `in_transit`.

**Desired behaviour:** The "Start Delivery" step should be removed from the delivery partner's flow entirely. After loading the vehicle (`internalStatus == 'loaded'`), the delivery should either automatically progress or be dispatched by the admin — the partner should not need to tap a separate "Start Delivery" button.

**Fix needed:**
- Remove the `canStartDelivery` check from `_DeliveryCardAction.forDelivery()` (`:1364–1371`)
- Remove or repurpose `_startDelivery()` method (`:353–363`)
- Decide what the card should show at `internalStatus == 'loaded'`: no button, or directly jump to something else
