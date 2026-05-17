# External integrations

External systems this project communicates with.

## <External system 1>

**Endpoint:** `<METHOD> <URL>`

**Payload:**

```json
{ "...": "..." }
```

**Authentication:** <how>.

**Retry policy:**
- Network / timeout / 5xx / 429: 3 attempts, exponential backoff (1s → 5s → 30s). Honor `Retry-After` on 429.
- Other 4xx: do NOT retry. Log full request/response.
- Exhaustion: insert into `pending_<system>` for cron-driven reprocessing.

**Reference:** <link>

## <External system 2>

<Same shape.>
