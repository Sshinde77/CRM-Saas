# Delivery Collection API — Backend Change Request

## Current issue

The collection screen currently loads two different APIs for two related views:

```text
Pending tab:
GET /customers?is_active=true&has_collectable=true

Collected tab:
GET /deliveries/collections
```

This is causing duplicate and inconsistent entries.

After a delivery partner submits a collection, the collection record appears in
`/deliveries/collections` with an approval status such as `pending_approval`.
However, the customer's outstanding balance is not reduced until approval, so
the same customer is still returned by `/customers?has_collectable=true`.

The Flutter app therefore receives the same business event from two different
data sources:

```text
/customers              → customer still appears collectable
/deliveries/collections  → collection is awaiting approval
```

This can result in:

- the same customer appearing in both tabs;
- an unnecessary second collection attempt;
- inconsistent totals and counts;
- pagination being calculated over different datasets;
- different clients showing different results.

## Requested solution

Use `/deliveries/collections` as the single source for both tabs, with an
explicit view parameter:

```text
GET /deliveries/collections?view=pending
GET /deliveries/collections?view=collected
```

The `view` parameter must be applied by the backend before filtering,
pagination, totals, and summary calculations.

## Issue 1 — Add `view=pending` and `view=collected`

### Pending view

Request:

```text
GET /deliveries/collections?view=pending
```

This view should return customer-level records that still require payment.
Each record should contain enough information for the Pending tab and the
Collect action:

```json
{
  "customer_id": "customer_123",
  "customer_name": "ABC Traders",
  "contact_name": "John",
  "phone": "9999999999",
  "outstanding_amount": 5000.0,
  "collectable_amount": 5000.0,
  "collection_status": null,
  "status": "pending"
}
```

The pending view must include only customers who can legitimately receive a
new collection. It must exclude customers with an active, non-voided
collection that is awaiting approval.

### Collected view

Request:

```text
GET /deliveries/collections?view=collected
```

This view should return collection transaction records, including collections
that are waiting for approval and collections that have already been approved
or reconciled:

```json
{
  "collection_id": "collection_123",
  "customer_id": "customer_123",
  "customer_name": "ABC Traders",
  "amount_collected": 5000.0,
  "payment_mode": "cash",
  "collection_status": "pending_approval",
  "collected_at": "2026-11-24T10:30:00Z"
}
```

### Pending-approval ownership rule

An awaiting-approval collection must appear in exactly one tab. The recommended
rule is:

```text
pending_approval / recorded → Collected view only
approved / reconciled       → Collected view only
voided                      → excluded from both active views
```

It must not be returned as a collectable customer in `view=pending`.

The backend should standardize the status names. Recommended canonical values:

- `pending_approval`: submitted by the delivery partner and waiting for admin;
- `approved` or `reconciled`: accepted by the business;
- `voided`: cancelled or rejected;
- `pending`: customer has an unpaid balance and no active collection exists.

If the backend chooses `recorded` instead of `pending_approval`, the meaning
must be documented and used consistently in every response.

### Required response fields

Both views should return a stable response shape where possible:

```json
{
  "items": [],
  "pagination": {
    "page": 1,
    "page_size": 10,
    "total": 0,
    "total_pages": 1
  },
  "summary": {
    "total_pending": 0,
    "total_collected": 0.0,
    "awaiting_approval_amount": 0.0,
    "cash_total": 0.0,
    "bank_transfer_total": 0.0
  }
}
```

Fields that do not apply to a view may be returned as zero or omitted, but the
pagination structure should remain consistent.

## Issue 2 — Pagination must be independent and filter-first

Using the same endpoint does not itself create a pagination problem. The
backend must treat `view` as part of the query/filter state and calculate
pagination independently for each view.

Example requests:

```text
GET /deliveries/collections?view=pending&page=1&page_size=10
GET /deliveries/collections?view=pending&page=2&page_size=10

GET /deliveries/collections?view=collected&page=1&page_size=10
GET /deliveries/collections?view=collected&page=2&page_size=10
```

The backend processing order must be:

```text
1. Apply organization and delivery-partner authorization scope
2. Apply the requested view filter
3. Apply status, search, customer, date, and other filters
4. Calculate summary totals over the complete filtered dataset
5. Calculate total and total_pages
6. Apply page and page_size
7. Return the requested page
```

Do not paginate the complete unfiltered collection table and then remove
records for the selected view. That causes short pages, empty pages, incorrect
page counts, and missing records.

### Pagination metadata requirements

For every request, return metadata describing only that request's view and
filters:

```json
{
  "pagination": {
    "page": 2,
    "page_size": 10,
    "total": 37,
    "total_pages": 4
  }
}
```

For `view=pending`, `total` must be the number of pending customers.

For `view=collected`, `total` must be the number of collection transactions.

The `total` value must not be shared between the two views, and changing from
one view to the other must reset the requested page to page 1 in the client.

### Summary requirements

Summary values must be calculated across all matching records, not only the
current page. For example, `total_collected` on collected page 2 must be the
total for all collected records matching the request filters.

## Duplicate-submission protection

The backend must enforce the same rule during collection creation. If an
active collection is already awaiting approval for the customer, a second
collection request should be rejected even if another client bypasses the
Pending view filter.

Recommended response:

```text
HTTP 409 Conflict
```

Example response:

```json
{
  "code": "active_collection_exists",
  "message": "A collection for this customer is already awaiting approval.",
  "collection_status": "pending_approval",
  "customer_id": "customer_123"
}
```

## Acceptance criteria

- Both tabs use `/deliveries/collections` with an explicit `view` parameter.
- `view=pending` returns only customers eligible for a new collection.
- `view=collected` returns pending-approval, approved, and reconciled
  collection records.
- A pending-approval record appears in exactly one tab.
- Voided records are excluded from both active views.
- Pagination totals and page counts are calculated independently per view.
- Filtering occurs before pagination.
- Summary totals cover the full filtered dataset, not only the current page.
- Page size and page number are honored for both views.
- A second active collection for the same customer is rejected server-side.
- Status values and response field names are documented and consistent.
