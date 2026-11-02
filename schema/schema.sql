-- Current-state snapshot of the lotscanner schema (read-only reference).
-- The authoritative, ordered history lives in migrations/ -- this file is not applied
-- directly; it exists so the current shape of the schema can be read in one place
-- without replaying every migration.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE lot_scan_sessions (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id     TEXT NOT NULL,
    company_id      INT NULL,
    status          VARCHAR(16) NOT NULL DEFAULT 'processing'
                        CHECK (status IN ('processing', 'in_review', 'confirmed', 'discarded', 'failed')),
    photo_url       TEXT NOT NULL,
    error_message   TEXT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    confirmed_at    TIMESTAMPTZ NULL
);

CREATE TABLE lot_scan_photos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES lot_scan_sessions(id) ON DELETE CASCADE,
    photo_url       TEXT NOT NULL,
    status          VARCHAR(16) NOT NULL DEFAULT 'processing'
                        CHECK (status IN ('processing', 'done', 'failed')),
    error_message   TEXT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc')
);

CREATE TABLE scanned_items (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id                  UUID NOT NULL REFERENCES lot_scan_sessions(id) ON DELETE CASCADE,
    suggested_catalog_game_id   TEXT NULL,
    suggested_title             TEXT NULL,
    suggested_platform          TEXT NULL,
    suggested_variant           TEXT NULL,
    suggested_price             NUMERIC(10, 2) NULL,
    confidence                  NUMERIC(4, 3) NULL CHECK (confidence IS NULL OR (confidence >= 0 AND confidence <= 1)),
    final_catalog_game_id       TEXT NULL,
    final_title                 TEXT NULL,
    final_platform              TEXT NULL,
    final_variant               TEXT NULL,
    final_price                 NUMERIC(10, 2) NULL,
    state                       VARCHAR(16) NOT NULL DEFAULT 'pending'
                                    CHECK (state IN ('pending', 'accepted', 'corrected', 'excluded', 'unidentified')),
    manually_entered            BOOLEAN NOT NULL DEFAULT FALSE,
    photo_id                    UUID NULL REFERENCES lot_scan_photos(id),
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc'),
    CONSTRAINT ck_scanned_items_final_price_required
        CHECK (state NOT IN ('accepted', 'corrected') OR final_price IS NOT NULL)
);

CREATE INDEX ix_lot_scan_sessions_employee_created ON lot_scan_sessions (employee_id, created_at DESC);
CREATE INDEX ix_lot_scan_sessions_company_created ON lot_scan_sessions (company_id, created_at DESC);
CREATE INDEX ix_lot_scan_photos_session_id ON lot_scan_photos (session_id);
CREATE INDEX ix_scanned_items_session_id ON scanned_items (session_id);
CREATE INDEX ix_scanned_items_final_catalog_game_id ON scanned_items (final_catalog_game_id) WHERE final_catalog_game_id IS NOT NULL;
