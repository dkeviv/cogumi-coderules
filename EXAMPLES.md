# Examples

Code examples for the Cogumi additions (rules 5 to 8). Each shows what agents commonly do and what to do instead. Examples for rules 1 to 4 are in the Karpathy repository.

---

## 5. Design for Change

**Request:** "Add Slack notifications. We will add Telegram and email later."

**What agents do**

```python
def notify(user, text, channel):
    if channel == "slack":
        send_slack(user.slack_id, text)
    elif channel == "telegram":      # added next month, edits this function
        send_telegram(user.tg_id, text)
    elif channel == "email":         # added the month after
        send_email(user.email, text)
```

Every new channel edits `notify`, and every edit risks the channels that already work.

**What to do**

```python
NOTIFIERS = {}

def register(name):
    def wrap(fn):
        NOTIFIERS[name] = fn
        return fn
    return wrap

def notify(user, text, channel):
    NOTIFIERS[channel](user, text)

@register("slack")
def slack(user, text): ...
```

Telegram later is a new module with `@register("telegram")` and no edit to `notify`. This abstraction is justified because the owner named channels as a change point. For anything not named, keep it simple (rule 2).

---

## 6. Test the Product, Not Just the Code

**Request:** "Users can create an order and get a confirmation email."

**What agents do**

```python
def test_create_order(mock_repo, mock_mailer):
    svc = OrderService(mock_repo, mock_mailer)
    svc.create(user_id=1, items=[...])
    mock_repo.save.assert_called_once()
    mock_mailer.send.assert_called_once()
```

This passes even if the route is unregistered, the database column is missing or the email template fails to render.

**What to do**

```python
def test_order_flow(client, db, outbox):
    r = client.post("/orders", json={"items": [{"sku": "A1", "qty": 2}]})
    assert r.status_code == 201
    assert client.get(f"/orders/{r.json()['id']}").json()["status"] == "confirmed"
    assert len(outbox) == 1 and "A1" in outbox[0].body

def test_order_flow_duplicate_submit(client, db, outbox):
    key = {"Idempotency-Key": "k1"}
    client.post("/orders", json={"items": [...]}, headers=key)
    client.post("/orders", json={"items": [...]}, headers=key)
    assert len(db.orders()) == 1 and len(outbox) == 1
```

The test enters through the real route, uses the real database and fakes only the mail server (which the project does not control). The failure path is also a flow.

---

## 7. Read Before You Write

**Request:** "Return a 404 with a message when the project is not found."

**What agents do**

```python
class ProjectMissingError(Exception): ...   # a third "not found" error
```

**What to do**

Search first:

```
grep -rn "NotFound\|not_found\|DoesNotExist" src/
```

The search finds `NotFoundError` in `errors.py`, already mapped to a 404 by the error handler. Reuse it:

```python
raise NotFoundError("project", project_id)
```

The final note says: "Reused: `NotFoundError` and its 404 mapping. Created: nothing."

---

## 8. Prove It Before Saying Done

**Request:** "Import contacts from a CSV."

**What agents do**

```python
def import_contacts(path):
    for row in csv.DictReader(open(path)):
        try:
            Contact.create(email=row["email"], name=row.get("name", ""))
        except Exception:
            pass
```

Bad rows vanish and the caller is told nothing.

**What to do**

```python
class ImportRowError(ValueError): ...

def import_contacts(path) -> ImportReport:
    report = ImportReport()
    with open(path, newline="") as f:
        for n, row in enumerate(csv.DictReader(f), start=2):
            try:
                report.add(Contact.create(**parse_row(row)))   # validates and types once
            except ImportRowError as e:
                report.reject(line=n, reason=str(e))
    return report
```

Each rejected row reports its line and reason. The caller can show the result.
