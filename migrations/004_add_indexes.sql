-- Supports correction-search lookups and per-session item fetches (tasks.md T013)

CREATE INDEX IF NOT EXISTS ix_scanned_items_session_id
    ON scanned_items (session_id);

CREATE INDEX IF NOT EXISTS ix_scanned_items_final_catalog_game_id
    ON scanned_items (final_catalog_game_id)
    WHERE final_catalog_game_id IS NOT NULL;
