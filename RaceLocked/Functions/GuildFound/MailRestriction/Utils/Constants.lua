--- Shared constants for the Guild Found mail restriction subsystem.

--- Seconds to wait for a Trade Verification probe reply before an unknown
--- sender/recipient is treated as a block. Shared by the inbound plan,
--- the consent session, and the outbound send guard so the verification
--- window stays consistent across all three.
RACE_LOCKED_MAIL_PROBE_TIMEOUT = 5
