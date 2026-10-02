-- LotScanSession: one photographing event for one customer's game lot (data-model.md)

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS lot_scan_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id     TEXT NOT NULL,
    status          VARCHAR(16) NOT NULL DEFAULT 'processing'
                        CHECK (status IN ('processing', 'in_review', 'confirmed', 'discarded', 'failed')),
    photo_url       TEXT NOT NULL,
    error_message   TEXT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    confirmed_at    TIMESTAMPTZ NULL
);

CREATE INDEX IF NOT EXISTS ix_lot_scan_sessions_employee_created
    ON lot_scan_sessions (employee_id, created_at DESC);

COMMENT ON TABLE lot_scan_sessions IS
    'One lot-scan session per customer visit; status drives the review/confirm/discard/failed lifecycle (contracts/lot-scan-api.md).';
COMMENT ON COLUMN lot_scan_sessions.error_message IS 'Set only when status = failed (AI identification call errored or timed out).';
COMMENT ON COLUMN lot_scan_sessions.confirmed_at IS 'Set only when status transitions to confirmed; immutable afterward.';
