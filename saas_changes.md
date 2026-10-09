# Customer Collection Reconciliation Visibility & Payment Proof Upload

## Overview

This release introduces visibility for recorded field collections awaiting reconciliation and adds payment proof upload support across customer collection and delivery workflows. The two-stage reconciliation lifecycle and accounting controls remain preserved.

---

## 1. Customer Collection Reconciliation Visibility

### A. Lifecycle & Endpoints

Delivery partners and field collectors record collections through the following endpoints:

- `POST /deliveries/collections/customer` — Record general customer collections (supports invoice allocations).
- `POST /customer-payments/collections` — Canonical alias for general customer collections.
- `POST /deliveries/{delivery_id}/collections` — Record collection for a specific delivery run.
- `GET /deliveries/collections` — List recorded collections (filterable by partner and date).
- `GET /deliveries/collections/{collection_id}` — Get collection detail and allocation breakdown.
- `POST /deliveries/collections/{collection_id}/reconcile` (and `PATCH`) — Accountant/Admin action to formally reconcile a collection.
- `POST /deliveries/collections/{collection_id}/void` (and `PATCH`) — Accountant/Admin action to void an un-reconciled collection.

### B. Accounting Controls & Two-Stage Reconciliation

1. **Initial Recording (`reconciliation_status="recorded"`)**:
   - Creates a `DeliveryCollection` record.
   - Appears in the Collection Reconciliation queue.
   - **Does NOT** create a `CustomerPayment` record.
   - **Does NOT** alter customer `outstanding_balance`, `total_received`, or invoice `paid_amount`.
   - **Does NOT** mark invoices as paid.

2. **Reconciliation (`reconciliation_status="reconciled"`)**:
   - Triggers formal accounting handoff via `payment_service.record()`.
   - Generates exactly one receipted `CustomerPayment` record with allocations.
   - Updates invoice balances and customer ledger figures.

3. **Voiding (`reconciliation_status="voided"`)**:
   - Cancels the recorded collection.
   - Excludes the collection from all unreconciled balances without affecting financial ledgers.

### C. New Response Fields

The following fields expose recorded collections awaiting accountant review without altering canonical accounting balances:

#### Sales Orders (`GET /orders`, `GET /orders/{order_id}`)
- `unreconciled_collection_amount: float` (default `0.0`): Sum of recorded, unreconciled collections linked directly to the order or allocated to the order's invoices.
- `unreconciled_collection_count: int` (default `0`): Distinct count of recorded collections pending reconciliation for this order.
- `payment_status: "pending" | "pending_reconciliation" | "partial" | "paid" | "failed" | "refunded"`:
  - `"pending_reconciliation"`: Displayed when money has been collected in the field and recorded, but awaits formal reconciliation.
  - Canonical invoice status (`pending`, `partial`, `paid`) is never overwritten before reconciliation.

#### Customers (`GET /customers`, `GET /customers/{id}`) & Customer Profile (`GET /customers/{id}/profile`)
- `unreconciled_collection_amount: float` (default `0.0`): Total amount of active recorded collections for the customer (`reconciliation_status == 'recorded'`).
- `unreconciled_collection_count: int` (default `0`): Number of recorded collections pending reconciliation for the customer.
- `outstanding_balance: float`: Canonical accounting balance (remains unchanged until formal reconciliation).

---

## 2. Payment Proof Upload

### A. Upload Workflow

Clients upload proof images/documents prior to collection submission:
- `POST /files/upload` — Accepts multipart form data (`file: UploadFile`) and returns a file reference and URL (`{ "id": "...", "url": "/files/..." }`).

### B. Request & Response Field: `payment_proof_url`

- **Optional Request Field**: Added to `DeliveryCollectionCreate` and `CustomerCollectionCreate`:
  ```json
  {
    "customer_id": "cust-uuid",
    "amount": 500.0,
    "payment_method": "cash",
    "payment_proof_url": "https://pub-...r2.dev/... or /files/file-uuid or bare-file-uuid"
  }
  ```
- **Persistence & Propagation**:
  - Persisted directly on the `DeliveryCollection` model (`payment_proof_url` column).
  - Propagated to `CustomerPayment.payment_proof_url` during `POST /deliveries/collections/{collection_id}/reconcile`.
- **Response Schemas**:
  - `DeliveryCollectionOut`: Returns `payment_proof_url`.
  - `CustomerPaymentOut`: Returns `payment_proof_url`.
- **URL Normalization**:
  - Automatically normalized using `normalize_file_url()`. Supports bare file IDs, relative `/files/...` paths, and absolute CDN/R2 URLs.

---

## 3. Database Migration

- **Migration File**: `alembic/versions/t8u9v0w1x2y3_add_payment_proof_url_to_delivery_collections.py`
- **Revision ID**: `t8u9v0w1x2y3`
- **Down Revision**: `s7t8u9v0w1x2`
- **Description**: Adds the nullable `payment_proof_url` column (`String(500)`) to the `delivery_collections` table.

---

## 4. Compatibility and Controls

- **Backward Compatibility**: `payment_proof_url` is optional on all collection endpoints (`default=None`). Existing web/mobile clients can continue submitting collections without providing a proof URL.
- **Two-Stage Workflow**: Delivery partners record collections; only accountants and admins can reconcile or void them.
- **Tenant Isolation**: All collection aggregations, queries, and file references are strictly scoped by `organization_id`.
- **Double-Counting Prevention**: Allocation records are respected so multi-invoice and multi-order collections only attribute the corresponding allocation amounts.
- **Void Exclusion**: Voided collections are excluded from unreconciled amounts immediately.
