Hi (frontend developer, and the AI assistant working on the frontend),

The customer screen gets two new read-only lists:

1. **Pending payments**: the customer's invoices that still have money owing.
2. **Collected payments**: the payments the customer has actually made.

Nothing that exists today has changed. `GET /customers/{id}/payments`, the account statement / ledger, recording a payment, voiding a payment and the receipt PDF all work exactly as before.

---

## 1. Pending payments

`GET /customers/{customer_id}/payments/pending`

`customer_id` is the customer's id or customer code, the same as every other `/customers/{id}` route.

### Query parameters (all optional)

| Name | Meaning |
|---|---|
| `from_date`, `to_date` | Invoice date range, `YYYY-MM-DD`, both ends inclusive, in the organization's timezone |
| `due_from`, `due_to` | Due date range, `YYYY-MM-DD`, both ends inclusive |
| `overdue` | `true` = only overdue invoices, `false` = only invoices that are not overdue |
| `payment_status` | `unpaid` or `partial` |
| `search` | Invoice number contains this text (case-insensitive) |
| `page` | Default 1 |
| `page_size` | Default 10, maximum 100 |
| `sort_by` | `invoice_date`, `due_date`, `invoice_number`, `total`, `outstanding` |
| `sort_order` | `asc` or `desc` |

Default order: earliest due date first; invoices without a due date come last.

### Example requests

```
GET /customers/9b1c…/payments/pending
GET /customers/9b1c…/payments/pending?overdue=true
GET /customers/CUST-0012/payments/pending?due_from=2026-11-01&due_to=2026-11-30&page=2&page_size=20
GET /customers/9b1c…/payments/pending?search=INV-10001&sort_by=outstanding&sort_order=desc
```

### Response

```json
{
  "items": [
    {
      "invoice_id": "3f0e…",
      "invoice_number": "INV-10001-2026-0042",
      "order_id": "a71c…",
      "invoice_date": "2026-10-08T00:00:00Z",
      "due_date": "2026-11-07T00:00:00Z",
      "total": 1000.0,
      "amount_paid": 200.0,
      "credited_amount": 0.0,
      "outstanding": 800.0,
      "currency": "INR",
      "payment_status": "partial",
      "invoice_status": "partial",
      "is_overdue": true,
      "days_overdue": 10
    }
  ],
  "total": 1,
  "page": 1,
  "page_size": 10,
  "total_pages": 1,
  "summary": {
    "total_outstanding": 800.0,
    "total_overdue": 800.0,
    "pending_invoices": 1,
    "overdue_invoices": 1,
    "currency": "INR",
    "payment_terms": "net_30",
    "as_of": "2026-11-17"
  }
}
```

### Rules

- `outstanding` = invoice total − amount paid − credit notes issued against the invoice. This is the same figure the customer's account statement uses.
- Fully settled invoices, credit notes, and cancelled or void invoices are never listed.
- `payment_status` is `unpaid` when nothing has been paid or credited yet, and `partial` otherwise.
- `is_overdue` is true when the due date is before today in the organization's timezone. An invoice due today is not overdue. An invoice with no due date (`due_date: null`) is never overdue.
- `days_overdue` is the number of whole days past the due date, or 0 when the invoice is not overdue.
- `summary` covers every row that matches your filters, not just the current page.
- `payment_terms` is the customer's payment terms; invoices do not store their own.

---

## 2. Collected payments

`GET /customers/{customer_id}/payments/collected`

The customer's recorded payments, newest first. Each payment is listed exactly once, even when it was applied to several invoices.

### Query parameters (all optional)

| Name | Meaning |
|---|---|
| `from_date`, `to_date` | Payment date range, `YYYY-MM-DD`, both ends inclusive, in the organization's timezone |
| `payment_mode` | For example `cash`, `upi`, `card`, `bank_transfer`. Case-insensitive. Also matches a split payment that has a part paid in that mode |
| `payment_status` | Only `recorded` is accepted (see Rules) |
| `search` | Receipt number, transaction reference, or the number of an invoice the payment was applied to |
| `page` | Default 1 |
| `page_size` | Default 10, maximum 100 |
| `sort_by` | `payment_date`, `amount`, `receipt_number` |
| `sort_order` | `asc` or `desc` |

### Example requests

```
GET /customers/9b1c…/payments/collected
GET /customers/9b1c…/payments/collected?from_date=2026-11-01&to_date=2026-11-17
GET /customers/9b1c…/payments/collected?payment_mode=upi&search=RCPT-0007
```

### Response

```json
{
  "items": [
    {
      "payment_id": "c42d…",
      "receipt_number": "RCPT-0007",
      "payment_date": "2026-11-17T06:12:00Z",
      "amount": 420.0,
      "payment_mode": "bank_transfer",
      "reference": "NEFT-9",
      "status": "recorded",
      "source": "direct",
      "order_id": null,
      "allocated_amount": 400.0,
      "unallocated_amount": 20.0,
      "allocations": [
        { "invoice_id": "11aa…", "invoice_number": "INV-10001-2026-0011", "amount": 300.0 },
        { "invoice_id": "22bb…", "invoice_number": "INV-10001-2026-0012", "amount": 100.0 }
      ],
      "splits": [],
      "currency": "INR"
    }
  ],
  "total": 1,
  "page": 1,
  "page_size": 10,
  "total_pages": 1,
  "summary": {
    "total_collected": 420.0,
    "payment_count": 1,
    "total_allocated": 400.0,
    "total_unallocated": 20.0,
    "currency": "INR"
  }
}
```

### Rules

- Only finalized payments are listed.
  - A delivery or field collection that is still waiting for the accountant is NOT in this list. The existing `GET /customers/{id}/payments` keeps showing it, with status `awaiting_reconciliation`.
  - Once the accountant reconciles it, it appears here exactly once, with `source: "delivery_collection"`.
  - Every other payment has `source: "direct"`.
- A voided payment is deleted by the system, so it never appears. That is why `status` is always `recorded`; any other `payment_status` value returns 400.
- `allocations` lists the invoices the payment was applied to:
  - a payment applied to one invoice has one entry;
  - a payment split across several invoices has one entry per invoice;
  - an advance (money held on account) has an empty list.
- `unallocated_amount` is the part held on account (`amount − allocated_amount`).
- `splits` is the tender breakdown when `payment_mode` is `split` (for example part cash, part UPI); otherwise it is an empty list.
- Internal notes are not returned.
- `summary` covers every row that matches your filters, not just the current page.

---

## 3. Access and errors (both endpoints)

| Situation | Response |
|---|---|
| Not logged in | 401 |
| User without the `payments` → `view` permission (for example the default Sales Officer role) | 403 |
| Staff whose role has "own" data scope, opening a customer not assigned to them | 404 `{"detail": "Customer not found"}` |
| Unknown customer id, or a customer belonging to another company | 404 `{"detail": "Customer not found"}` |
| Bad date such as `from_date=17-11-2026` | 400 `{"detail": "from_date must be YYYY-MM-DD"}` |
| `from_date` after `to_date` (or `due_from` after `due_to`) | 400 |
| Unknown `sort_by`, `sort_order`, or `payment_status` value | 400, the message lists the allowed values |
| `page` below 1, or `page_size` above 100 | 422 (standard validation error) |

Admins always have access. Accountants see every customer.

All amounts are plain JSON numbers rounded to 2 decimals. Dates are ISO 8601 in UTC.

## 4. What is not supported

- Refunds and write-offs: the system has no record type for them, so neither list shows them.
- Payment terms per invoice: invoices do not store their own terms, so `summary.payment_terms` shows the customer's terms.
- A per-invoice currency: invoices do not store a currency. `currency` is the customer's currency if set, otherwise the organization's currency, otherwise `INR`.

---

Hi (whoever deploys the backend on Cloudflare),

- No database migration. No new Python package. No new environment variable.
- Both endpoints are read-only; they never write to the database.
- Files changed:
  - `app/routers/customers.py`: two new GET routes; nothing else in the file changed
  - `app/services/customer_payment_lists.py`: new
  - `app/schemas/customer_payment_lists.py`: new
  - `tests/test_customer_pending_collected_payments.py`: new, 14 tests
- Tests run on a scratch PostgreSQL database:
  - The new test file: 14 passed.
  - Existing payment, collection, reconciliation, Razorpay, permission, dashboard and bulk-delete suites: all passed.
  - `test_stock_locking_and_split_payments` fails on the unchanged code as well, so it is not caused by this change.
