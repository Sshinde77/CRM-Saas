# Mobile notifications not reaching Sales Officer / Delivery Partner — handoff

## Symptom

On the mobile app, Sales Officers and Delivery Partners report **zero**
notifications — not one — for events that should notify them: an order
assigned/status-changed, a lead assigned, a delivery assigned. The web app
receives notifications fine for the same events. This repo is the backend
(`saasbackend`); the Flutter client repo has already been audited and its
FCM/device-registration/in-app-list code is confirmed correct (see "What has
already been ruled out" below) — focus the investigation here.

## What has already been verified as correct in this backend repo

Checked against commit `a856e1c` on `main`:

- `app/core/notification_types.py` — event list, `EVENT_CATEGORY`,
  `EVENT_DATA_KEYS`, and the `_ENTITY` / `describe()` action-url mapping all
  match the documented contract (see `app/services/notification_service.py`
  docstrings for the source of truth).
- `notify_lead_assigned` is called from `lead_service.py:239` (create) and
  `:392` (reassignment).
- `notify_order_status_changed` notifies org admins **and** the order's
  salesperson (via `_order_salesperson`, `notification_service.py:232-262`),
  excluding the actor.
- `notify_quotation_status_changed` is called from `quotation_service.py:351`.
- `notify_delivery_assignment` is called from 5 call sites covering every
  path a delivery can be assigned: `deliveries.py:414,642`,
  `sales_orders.py:707,942,955`.
- `push_service.py` treats `web`, `android`, `ios` devices identically —
  `send_to_user` → `devices_for_user` has no platform filter, and
  `notify_org_admins` / `notify` queue a push for every device of every
  recipient with no role- or platform-based exclusion beyond what the event's
  recipient rule already says.
- The registration endpoint (`POST /notifications/devices/register`) accepts
  `android`/`ios`/`web`, validates correctly, and is platform-agnostic.

**Conclusion so far: the code that decides *who* gets notified and *that* a
push is queued looks correct.** The gap is somewhere between "a notification
row/push is queued" and "it reaches the Sales Officer / Delivery Partner's
phone." That's almost certainly one of the items below.

## What to check, in order of likelihood

### 1. Is this commit actually deployed?

The notification contract described above (lead_assigned,
order_status_changed → salesperson, etc.) is recent — check:

```bash
git log -1 --format='%H %ci' main
```

against whatever the production backend (`crm-saas-backend.bsmart.workers.dev`
and/or the Render deployment at `saasbackend-1-f6v3.onrender.com` — there
appear to be **two** backend URLs in play, see note below) is actually
running. If production is behind `main`, none of this new recipient logic
(salesperson on order status change, lead_assigned, etc.) exists in prod yet
— that alone would explain "sales/delivery get nothing," independent of any
push/FCM problem.

**Also resolve which backend URL is authoritative.** The Flutter client's
`ApiConstants._productionBaseUrl` points at
`https://crm-saas-backend.bsmart.workers.dev`, but file URLs returned in
`auth/me` responses (e.g. `identity_proof_file`) point at
`https://saasbackend-1-f6v3.onrender.com`. If these are two different
deployments that can drift out of sync, confirm the Cloudflare Worker is
proxying to the *same* app instance/database as Render, and that both are on
the commit being tested.

### 2. Is `PUSH_NOTIFICATIONS_ENABLED` actually true in the deployed env, and is the Firebase service account valid?

`app/core/firebase.py::push_status()` returns exactly this diagnostic without
leaking secrets. If there's no endpoint already exposing it, add one
temporarily (admin-only) or check via a Python shell on the deployed instance:

```python
from app.core.firebase import push_status
print(push_status())
# {"enabled": True, "configured": True, "project_id": "...", "error": None}
```

If `enabled` is `False` or `configured` is `False`, **every** push silently
no-ops (`send_to_devices` returns `PushResult(enabled=False, ...)` — see
`push_service.py:136-140`) and no exception is raised anywhere up the call
chain. This would explain missing push while in-app notifications (DB rows)
still exist.

### 3. Do the affected users actually have a `PushDevice` row?

Run directly against the deployed database:

```sql
SELECT pd.id, pd.platform, pd.label, pd.last_seen_at, u.email, u.role
FROM push_devices pd
JOIN users u ON u.id = pd.user_id
WHERE u.email IN ('<sales-officer-email>', '<delivery-partner-email>');
```

- **No rows at all** → the mobile app's `POST /notifications/devices/register`
  call is either never reaching the backend, or failing. Check the access
  logs for that endpoint around the time those users logged in on mobile —
  look specifically for `401`/`403`/`409`/`422` responses from that route for
  those user IDs. A `409` means the same physical device/token is already
  registered to a different organization (shared test devices between demo
  orgs are a common cause) — the client is supposed to drop the token and
  request a new one on `409`, but confirm that's actually happening rather
  than silently giving up.
- **Rows exist, `platform = 'android'` or `'ios'`** → registration worked;
  the problem is downstream (Firebase delivery, APNs config, or the role's
  notification simply isn't being queued — re-check item 1).
- **Rows exist but `last_seen_at` is old** → the token may be stale/rotated;
  confirm `onTokenRefresh` re-registration is actually hitting this endpoint
  (check access logs for repeated `register` calls from the same user over
  time).

### 4. Use the existing test endpoint to isolate push delivery from business-event logic

`POST /notifications/devices/test` (already implemented,
`routers/notifications.py:203-216`) sends a push to *only* the calling user's
own devices and returns:

```json
{"enabled": true, "attempted": 1, "accepted": 1, "invalid_tokens_removed": 0, "transient_failures": 0, "detail": null}
```

Have the Sales Officer / Delivery Partner call this from their mobile app
(there's no UI button for it currently; a quick curl works too):

```bash
curl -X POST https://<backend>/notifications/devices/test \
  -H "Authorization: Bearer <their access token>"
```

- `attempted: 0` → no device registered (goes back to item 3).
- `attempted: 1, accepted: 0` with `transient_failures: 1` → Firebase/network
  issue, or (for iOS) missing/misconfigured APNs key in the Firebase console.
- `attempted: 1, accepted: 1` but the phone shows nothing → not a backend
  problem; it's OS-level (notification permission denied, Android
  battery-optimization killing the app, or — for iOS — APNs
  sandbox/production environment mismatch). Hand this back to mobile.
- `accepted: 1` and the phone *does* get this test push, but still gets
  nothing for real business events (order/lead/delivery) → the business-event
  recipient logic genuinely isn't firing for this role in the deployed
  version. Re-check item 1 (deployment lag) and then re-read
  `notification_service.py`'s recipient-resolution functions
  (`_order_salesperson`, `notify_lead_assigned`, `notify_delivery_assignment`)
  against this specific user's actual role/assignment data — e.g. confirm
  `order.salesperson_id` or `lead.assigned_salesperson_id` is actually set to
  this user for the order/lead being tested, and that
  `User.effective_system_role` for them isn't accidentally `"admin"` (which
  would make `_order_salesperson` skip them, since admins already get the
  admin-targeted notification and the code avoids double-sending).

### 5. Check for silently swallowed errors

`push_service.queue_notification_push` and `_send_queued_pushes` (the
`after_commit` SQLAlchemy hook) intentionally never raise — a scheduling
failure is just logged (`logger.warning`, `push_service.py:323-330`). Check
the `crm.push` logger's output in the deployed environment's logs for
warnings like:

```
Could not schedule N pushes (...)
Push batch failed (...); N tokens kept
Push for notification <id> failed (...)
```

If the thread pool (`ThreadPoolExecutor(max_workers=2, ...)`) is starved,
stuck, or the process restarts between a commit and the pool picking up the
job, pushes for that commit are silently lost — the in-app `Notification` row
would still exist (check `GET /notifications` for that user to confirm
whether the row exists but the push just never went out — that's the
fastest way to tell "business logic didn't fire" apart from "push transport
failed").

## Summary of the one most useful thing to do first

**Run the test-push endpoint (item 4) for an affected Sales Officer and
Delivery Partner account, and separately check whether their `GET
/notifications` list contains the business-event row they say never
arrived.** Those two data points alone will tell you whether this is:
(a) the recipient logic not firing (no in-app row either) → re-check
deployment/commit and the role-specific recipient functions, or
(b) the in-app row exists but push never arrived (`attempted: 0` on test) →
device registration problem, or
(c) in-app row exists, test push works and arrives, but the real-event push
never did → most likely a deployment-lag or role-condition bug in the
specific recipient-resolution function for that event.
