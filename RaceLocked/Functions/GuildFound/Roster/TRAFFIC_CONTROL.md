# Guild Found Roster — Traffic Control

Event-driven addon traffic on `RLGFRoster`. No heartbeat, no zone re-broadcast.

## Message types

| Kind | When sent |
|------|-----------|
| **`S:`** self-report | Once per session on login (60+), or manual **Sync** |
| **`G:`** GM override | GM clicks **Save** on a row (one message per save) |
| **`O:`** peer relay | We hold a GM override but receive that player's `S:` without the badge |

## Outgoing limits

- **Session announce** — at most one login self-report per game session (`PLAYER_ENTERING_WORLD` retries via `ADDON_LOADED` / `GUILD_ROSTER_UPDATE` until guild name is readable).
- **2 s throttle** — login and Sync share `broadcastSelfReport()`; double-fires collapse.
- **Level gate** — below `RACE_LOCKED_GUILD_FOUND_MAX_LEVEL` (see `Utils/Constants.lua`): chat confirmation only, no `S:` on the wire.
- **Sync button** — one use per window open; re-enabled after closing Race Locked.
- **GM edits** — in-memory until **Save**; unsaved edits discarded on row change or window close; no-op Save sends nothing; Verified + Tampered changes = one `G:`.
- **Compact payloads** — GM badge piggybacks on the player's own `S:` when possible.

## Relay (`O:`) limits

Sent only when we receive another member's badge-less `S:` and we already hold their GM override. Delayed **1.5–3.5 s**, keyed by player (coalesced). Cancelled if a badge arrives or another peer's relay is accepted.

## Incoming guards

- Drop messages from self.
- Reject `G:` from non–guild-master.
- Accept overrides only when timestamp ≥ stored (`RaceLocked_Roster_SetGMOverride`).
- Stale rejected relays do not cancel our pending relay.

## Local UI (not wire traffic)

- Routine traffic → in-panel **Sync Log** only (one chat line on login).
- Log capped at **200** entries; tab refresh debounced **0.2 s**.
- Closing Race Locked resets view to roster table (log is session-only).
