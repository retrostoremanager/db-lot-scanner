-- Adds store-scoping for the history feature and multi-photo support per scan session
-- (data-model extension: a session can now have 2+ photos, each independently tracked).

ALTER TABLE lot_scan_sessions ADD COLUMN IF NOT EXISTS company_id INT NULL;
COMMENT ON COLUMN lot_scan_sessions.company_id IS
    'RetroStoreManager company id, from the JWT at scan creation. Nullable: no real prod data exists for this app yet, so pre-migration rows are left NULL rather than backfilled; the app always populates it for new scans.';

CREATE TABLE IF NOT EXISTS lot_scan_photos (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id      UUID NOT NULL REFERENCES lot_scan_sessions(id) ON DELETE CASCADE,
    photo_url       TEXT NOT NULL,
    status          VARCHAR(16) NOT NULL DEFAULT 'processing'
                        CHECK (status IN ('processing', 'done', 'failed')),
    error_message   TEXT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT (NOW() AT TIME ZONE 'utc')
);

COMMENT ON TABLE lot_scan_photos IS
    'One photo within a lot scan session. A session starts with one and can gain more while still in_review; each photo''s own identify status is tracked here so an additional photo failing never fails the whole session.';

ALTER TABLE scanned_items ADD COLUMN IF NOT EXISTS photo_id UUID NULL REFERENCES lot_scan_photos(id);
COMMENT ON COLUMN scanned_items.photo_id IS 'Which photo this item was identified from. Nullable for rows that predate multi-photo support.';

-- Backfill: one lot_scan_photos row per existing session, so pre-migration sessions still
-- have a consistent photo record under the new model (dev test data only -- this app has no
-- real production data yet).
INSERT INTO lot_scan_photos (session_id, photo_url, status, created_at)
SELECT id, photo_url,
       CASE status WHEN 'processing' THEN 'processing' WHEN 'failed' THEN 'failed' ELSE 'done' END,
       created_at
FROM lot_scan_sessions
WHERE NOT EXISTS (SELECT 1 FROM lot_scan_photos lp WHERE lp.session_id = lot_scan_sessions.id);

UPDATE scanned_items si SET photo_id = lp.id
FROM lot_scan_photos lp
WHERE lp.session_id = si.session_id AND si.photo_id IS NULL;

CREATE INDEX IF NOT EXISTS ix_lot_scan_sessions_company_created
    ON lot_scan_sessions (company_id, created_at DESC);
CREATE INDEX IF NOT EXISTS ix_lot_scan_photos_session_id
    ON lot_scan_photos (session_id);
