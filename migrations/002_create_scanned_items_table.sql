-- ScannedItem: one physical game detected within a LotScanSession (data-model.md)

CREATE TABLE IF NOT EXISTS scanned_items (
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
    final_variant                TEXT NULL,
    final_price                 NUMERIC(10, 2) NULL,
    state                        VARCHAR(16) NOT NULL DEFAULT 'pending'
                                     CHECK (state IN ('pending', 'accepted', 'corrected', 'excluded', 'unidentified')),
    manually_entered             BOOLEAN NOT NULL DEFAULT FALSE,
    created_at                   TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc')
);

COMMENT ON TABLE scanned_items IS
    'One physical game detected within a lot scan session; suggested_* holds the AI guess, final_* holds the reviewed value (data-model.md).';
COMMENT ON COLUMN scanned_items.suggested_catalog_game_id IS 'api-gamedb catalog ID the AI proposed; null if unidentified.';
COMMENT ON COLUMN scanned_items.confidence IS 'Primarily the catalog fuzzy-match score, vision self-report as a secondary signal (research.md #3/#6).';
COMMENT ON COLUMN scanned_items.manually_entered IS 'True if the employee typed final details with no catalog match (FR-008).';
