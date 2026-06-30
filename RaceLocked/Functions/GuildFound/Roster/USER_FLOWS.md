# Guild Found Roster — User Flows

Experience-level summary for the **Guild Found Roster** panel (Guild Verification tab).

## Who

- **Member** — read-only roster; shares own status on login / Sync.
- **Guild master** — same, plus per-row **Edit** / **Save** overrides (`*` marks manual values).

## What you see

Each row: **Name**, **Verified**, **Tampered**, **Status** (Eligible / Ineligible). Local player highlighted. Sorted eligible first, then A–Z.

## Flows

**View (member)** — Open Guild Verification → scan guildmates who have synced status. No edit controls.

**Stay in sync** — Login auto-shares status (60+); one chat confirmation line. **Sync** (refresh icon) re-broadcasts once per window open.

**GM override** — **Edit** → Yes / No / Reset on Verified and Tampered (preview only) → **Save** persists and sends one guild update. Leave row or close window = discard unsaved. Offline members pick up overrides when they log in.

**Sync Log** — Header **Log** link → session sent/received/info lines → **Roster** to return. Clears on `/reload`; reopening the window always lands on the roster table.

## Notes

- Account-wide saved roster; lists players who have synced, not a live guild roster scan.
- Entries persist until pruned manually (future); leaving the guild does not auto-remove rows.
- Informational only — does not change in-game permissions by itself.
