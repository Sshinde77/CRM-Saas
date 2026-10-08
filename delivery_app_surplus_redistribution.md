# Delivery App — Surplus Quantity Redistribution

When a receiver on a delivery run takes fewer units than were loaded for them, the
units they did not take can be handed to another receiver on the **same vehicle run**.
This is available only to the delivery app, through two new `/app/...` endpoints.
The website delivery flow is unchanged.

---

## 1. Feature overview

```
A: Ordered 5    Customer wants 3       Delivered = 3    Surplus = 2
B: Ordered 3    Customer wants 2       Delivered = 2    Surplus = 1
                                                   Total surplus = 3
C: Ordered 2    Customer wants extra 3 Maximum available = 2 + 3 = 5
                                       Delivered = 5

Final:
A → Ordered 5 / Delivered 3
B → Ordered 3 / Delivered 2
C → Ordered 2 / Delivered 5
```

- **`ordered_quantity` never changes.** `SalesOrderItem.quantity` is never written by
  this feature. C's order still says 2.
- **Only delivered figures change.** `DeliveryItem.delivered_quantity`,
  `SalesOrderItem.delivered_quantity` and the vehicle's `delivered_qty` are updated by
  the existing confirm logic, exactly as for any other delivery.
- **Surplus stays inside one run.** Spare units can only move between deliveries that
  were loaded in the delivery partner's current active `VehicleLoading` session.
- **Out of scope:** the future "customer declined quantity / reason" flow is not part
  of this task.

### How it works internally

Spare units are tracked as `loaded_quantity − delivered_quantity` on each delivery
line. To give C three extra units, the loaded quantity is **moved between lines**:

| Line | loaded before | loaded after | delivered after |
|---|---|---|---|
| A | 5 | 3 | 3 |
| B | 3 | 2 | 2 |
| C | 2 | 5 | 5 |

After the move, the existing `delivery_service.confirm()` records C's hand-over
unchanged. Because A's line now reads loaded 3 / delivered 3, a later re-attempt on
A cannot hand out the same two units again.

No warehouse stock moves: the units already left the warehouse when the vehicle was
loaded. The vehicle's totals stay consistent (10 loaded, 10 delivered).

---

## 2. New app APIs

Both endpoints are for the **assigned delivery partner** only. Anyone else in the same
organisation gets `403`, and other organisations get `404`.

### `GET /deliveries/{delivery_id}/app/delivery-capacity`

Read-only. Returns, for each line, the most that can be delivered right now and where
any extra would come from. Call this before showing the delivery screen, and again
after any error.

**Response**

```json
{
  "delivery_id": "…",
  "delivery_number": "DO-…",
  "status": "in_transit",
  "vehicle_loading_id": "…",
  "delivered_value": 0.0,
  "order_delivered_value": 0.0,
  "paid_amount": 0.0,
  "app_amount_due": 0.0,
  "items": [
    {
      "delivery_item_id": "…",
      "product_id": "…",
      "variant_id": null,
      "product_name": "Widget",
      "batch_number": null,
      "ordered_quantity": 2,
      "planned_quantity": 2,
      "loaded_quantity": 2,
      "delivered_quantity": 0,
      "own_remaining": 2,
      "transferable_surplus": 3,
      "max_allowed_delivery": 5,
      "redistribution_blocked_reason": null,
      "surplus_sources": [
        {"delivery_id": "…A", "delivery_number": "DO-…", "delivery_item_id": "…", "available": 2},
        {"delivery_id": "…B", "delivery_number": "DO-…", "delivery_item_id": "…", "available": 1}
      ]
    }
  ]
}
```

| Field | Meaning |
|---|---|
| `vehicle_loading_id` | The active run this delivery belongs to. `null` means it is not part of an active run, so no surplus is available. |
| `own_remaining` | `loaded_quantity − delivered_quantity` on this line. |
| `transferable_surplus` | Spare units from eligible donors (section 3), capped by what is physically on the vehicle. |
| `max_allowed_delivery` | `own_remaining + transferable_surplus`. Send this back as `expected_max`. |
| `redistribution_blocked_reason` | Why no surplus is offered, e.g. serial-tracked product, different batch, or not on an active run. Otherwise `null`. |
| `surplus_sources` | Each donor's spare units. Their sum can exceed `transferable_surplus`, because the vehicle cap is applied to the total. |
| `delivered_value`, `order_delivered_value`, `paid_amount`, `app_amount_due` | See section 7. |

### `POST /deliveries/{delivery_id}/app/confirm`

Records what was handed over, using spare units from the same run when a line asks
for more than its own remaining quantity.

**Request**: the existing confirm body, with an optional `expected_max` on each item.

```json
{
  "items": [
    {"delivery_item_id": "…", "delivered_quantity": 5, "expected_max": 5}
  ],
  "pod_photo_file_ids": ["…"],
  "delivery_proof_url": null,
  "signature_file_id": "…",
  "receiver_name": "Gate",
  "notes": null,
  "failed": false,
  "failure_reason": null
}
```

**Response**: the full existing `DeliveryOut` (same fields as the website confirm
response), plus:

```json
{
  "...": "all DeliveryOut fields",
  "reallocations": [
    {"from_delivery_id": "…A", "from_delivery_item_id": "…", "to_delivery_item_id": "…",
     "product_id": "…", "variant_id": null, "quantity": 2},
    {"from_delivery_id": "…B", "from_delivery_item_id": "…", "to_delivery_item_id": "…",
     "product_id": "…", "variant_id": null, "quantity": 1}
  ],
  "delivered_value": 500.0,
  "order_delivered_value": 500.0,
  "paid_amount": 0.0,
  "app_amount_due": 500.0
}
```

`reallocations` is empty when every line stayed within its own remaining quantity.

**Validation and errors**

| Status | When |
|---|---|
| `409` | An item's `expected_max` no longer matches the server's current `max_allowed_delivery`. For example, another confirm on the same run used the spare units first. The body is `{"detail": {"message", "delivery_item_id", "max_allowed_delivery"}}`. Nothing is saved. Refresh the capacity and ask again. |
| `400` | The quantity exceeds `max_allowed_delivery`. The message gives the limit and the reason, e.g. "at most 5 can be delivered (2 of its own plus 3 spare on this vehicle run), asked for 6", plus a serial or batch reason when relevant. |
| `400` | The delivery is not `in_transit` or `partially_delivered`. |
| `400` | The same `delivery_item_id` appears twice in `items`. |
| `400` | The existing confirm validations, unchanged. |
| `403` | The caller is not the delivery's assigned partner. |
| `404` | The delivery does not exist, or belongs to another organisation. |

`expected_max` is optional. If it is omitted, no staleness check is made and the
quantity is only checked against the current limit.

`failed: true` with a `failure_reason` behaves exactly like the website's failed
confirm. Nothing is redistributed.

---

## 3. Surplus eligibility rules

A **donor** line can give units to the **target** line only when all of these hold:

| Rule | Detail |
|---|---|
| Same organisation | |
| Same delivery partner | `Delivery.delivery_partner_id` |
| Same vehicle | `Delivery.vehicle_id`, which must also match the run's vehicle |
| Same product and variant | `product_id` and `variant_id` must both match. `null` matches only `null`. |
| Same active run | Both deliveries were loaded during the partner's current active `VehicleLoading` session. Deliveries loaded in an earlier session are excluded: their leftovers went back to the warehouse at that session's end-of-day return. |
| Donor already visited | Donor status is `partially_delivered` or `failed`. |
| Not the target | A delivery never donates to itself. |
| Has spare units | Donor line `loaded_quantity − delivered_quantity > 0`. |

**Deliveries still `in_transit` can never donate.** Their units are still owed to
their own receiver.

The **target** delivery must be assigned to the calling partner, and its status must
be `in_transit` or `partially_delivered`.

The extra units are taken from donors in a fixed order: oldest confirmation first.

**Vehicle cap.** The total offered can never exceed what is physically on the
vehicle for that product: `loaded_qty − delivered_qty − returned_qty` on the run's
`VehicleLoadingItem`. Mid-day `extra_qty` is **not** counted, because it was never part
of any delivery on the run.

How "same session" is detected: there is no foreign key from a delivery to its
vehicle session. A delivery counts as part of the active session when it has at least
one `loaded` history event and none of them are dated before the session started.

---

## 4. Product tracking rules

| Product | Redistribution |
|---|---|
| Normal | Allowed. |
| Batch-tracked (`batch_tracking`) | Allowed only from donor lines whose `batch_number` equals the target line's, and that batch number must not be empty. Spare units from other batches are not offered. Asking for them gives `400` "…from a different batch". |
| Serial-tracked (`serial_number_tracking`) | Not allowed. `transferable_surplus` is always 0, and asking for more than the line's own quantity gives `400` "Serial-tracked products cannot be redistributed between receivers". Delivering within the line's own quantity still works. |

---

## 5. Concurrency protection

The website confirm and the app confirm now take the same lock, through one shared
internal helper: `delivery_service.lock_run_for_confirm()`.

```
VehicleLoading lock      (the partner's active run)
       ↓
Delivery lock            (the delivery being confirmed; the app then locks donors in id order)
       ↓
Re-read current quantities  (delivery lines and vehicle totals, from the database)
       ↓
Validate
       ↓
Confirm / redistribute
```

- Locks are taken with a no-op `UPDATE`, the same technique `load()` already used, so
  it works on both PostgreSQL and SQLite.
- Everything on a partner's run queues behind the run lock, always in the same order,
  so a website confirm and an app confirm cannot deadlock.
- A request that had to wait re-reads the figures before validating. A stale request
  therefore gets the normal validation error instead of using units that were
  already handed to someone else.

**Problem this fixes:** before the shared lock, a website confirm on A that read A's
figures just before an app confirm moved A's spare units to C would still be
accepted. That left A with delivered 5 against loaded 3, and the vehicle with
12 delivered against 10 loaded. Now the website request gets the existing
`400 "only 0 of what was loaded is still on the vehicle"`.

---

## 6. Website compatibility

- The website's `POST /deliveries/{id}/confirm` is **unchanged at the API-contract
  level**: same path, request body, response, validation rules and messages.
- **The website cannot redistribute surplus.** The existing endpoint still refuses
  any quantity above a line's own `loaded − delivered`.
- Redistribution is exposed **only** through the new `/deliveries/{id}/app/...`
  endpoints.
- Load, vehicle-stock, invoice and collection APIs were **not changed** for this
  feature.
- `ordered_quantity` behaviour is unchanged.
- The internal locking improvement protects both website and app confirms without
  changing the website API contract. The only difference is that a confirm racing
  another confirm on the same run now waits briefly and validates against fresh
  figures.
- The persisted figures are real delivery data, so the website will show them after a
  redistribution:
  - a donor's `loaded_quantity` is lower (A shows loaded 3);
  - a receiver can show delivered above ordered (C shows delivered 5 against ordered 2);
  - the delivery challan's Planned / Loaded / Delivered columns reflect this.

  The website flow itself is unchanged. The `quantity_reallocated` history entries
  explain each move.

---

## 7. Invoicing and amount fields

- Through the app flow, a receiver's delivered quantity **can exceed their ordered
  quantity** (C: ordered 2, delivered 5).
- Invoicing the delivery (`POST /orders/{order_id}/invoice` with `{"delivery_id": …}`)
  bills the **actual delivered quantity** at the order line's existing price, discount
  and tax, through the existing invoice logic. C is billed for 5. The order line's
  quantity and the order total do not change.

App-only response fields, on the capacity and app confirm responses:

| Field | Meaning |
|---|---|
| `delivered_value` | This delivery's delivered units, valued the way a delivery invoice bills them: `unit_price × qty − line discount × qty/ordered`, plus the line's tax rate, with no order-level discount. It matches the invoice total for this delivery. |
| `order_delivered_value` | The same valuation over every delivered unit on the order. It equals `delivered_value` when the order has one delivery. |
| `paid_amount` | `amount_paid` across the order's invoices, the same figure `amount_due` subtracts. |
| `app_amount_due` | `max(order_delivered_value − paid_amount, 0)`. |

`app_amount_due` is worked out at **order** level because payments are recorded
against the order's invoices. A payment for one delivery must not reduce what is due
on another.

- The existing shared `DeliveryOut.amount_due` (order total less payments) was
  **intentionally left unchanged**. For C it still shows the value of 2 units. The app
  should show `delivered_value` / `app_amount_due` instead.
- **Invoice before collecting.** The existing collection check,
  `POST /deliveries/{id}/collections`, caps a collection at the latest invoice's
  outstanding amount, or at the order total when nothing is invoiced yet. To collect
  for the extra units, the app must invoice the delivery first and then record the
  collection. The collection rules were not changed.

---

## 8. Audit / history

Every move writes a `quantity_reallocated` event to the existing `DeliveryHistory`
timeline on **both** deliveries, in the same transaction as the confirm. No new
table was added.

```json
{
  "event_type": "quantity_reallocated",
  "notes": "2 × Widget handed to DO-…",
  "event_metadata": {
    "from_delivery_id": "…A",
    "from_delivery_item_id": "…",
    "to_delivery_id": "…C",
    "to_delivery_item_id": "…",
    "product_id": "…",
    "variant_id": null,
    "quantity": 2,
    "vehicle_loading_id": "…"
  }
}
```

The target's entry reads "2 × Widget taken from DO-…". The usual `delivered` /
`partially_delivered` event follows, written by the existing confirm logic.

---

## 9. Database / migration

- **No database migration was required.**
- The existing `DeliveryItem` quantities, `VehicleLoading` / `VehicleLoadingItem`
  totals and `DeliveryHistory` were sufficient.

### Files

| File | Change |
|---|---|
| `app/services/delivery_redistribution_service.py` | New: capacity, eligibility, redistribution and app amount figures. |
| `app/services/delivery_service.py` | Added `lock_delivery_row()` and `lock_run_for_confirm()`; `confirm()` now calls the lock first. |
| `app/routers/deliveries.py` | Two new `/app/...` routes. |
| `app/schemas/delivery.py` | New app-only request and response schemas. |
| `tests/test_delivery_surplus_redistribution.py` | New: 20 tests. |

---

## 10. Verification summary

- The A/B/C scenario was tested end to end: C receives 5, the reallocations are A→2
  and B→1, and the vehicle shows 10 loaded and 10 delivered.
- Ordered quantities stay unchanged (A 5, B 3, C 2), including after invoicing.
- No surplus is offered for a different partner, vehicle, product or variant, an
  earlier session, an `in_transit` donor, or another organisation.
- A re-attempt on a donor cannot reuse redistributed units.
- **App/app concurrency is protected:** two simultaneous app confirms cannot spend the
  same spare units.
- **The website/app race is fixed:** a stale website confirm gets the normal `400`.
  In a real simultaneous race exactly one request succeeds. Delivered never exceeds
  loaded on any line or on the vehicle, and invoiced quantity equals delivered
  quantity.
- A stale `expected_max` returns `409`.
- Batch and serial restrictions are tested.
- `delivered_value` matches the real invoice total. `app_amount_due` follows payments.
  The shared `amount_due` is unchanged.
- The existing website confirm still refuses quantities above loaded.
- The existing delivery, vehicle-stock, workflow and status suites all still pass.
- No migration was required.
