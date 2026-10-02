-- Enforce data-model.md's validation rule: "final_price MUST be set for any item in
-- accepted/corrected state before the parent session can transition to confirmed."

ALTER TABLE scanned_items
    ADD CONSTRAINT ck_scanned_items_final_price_required
    CHECK (state NOT IN ('accepted', 'corrected') OR final_price IS NOT NULL);

COMMENT ON CONSTRAINT ck_scanned_items_final_price_required ON scanned_items IS
    'data-model.md validation rule: accepted/corrected items must carry a final price.';
