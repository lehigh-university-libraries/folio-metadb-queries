--metadb:function get_items_with_spine_label_note
-- This function retrieves all items with an Inventory Note about the Spine Label needing to be replaced.
DROP FUNCTION IF EXISTS get_items_with_spine_label_note;
CREATE FUNCTION get_items_with_spine_label_note()
RETURNS TABLE
(
    item_barcode TEXT,
    item_call_number TEXT,
    item_title TEXT,
    item_updated_date TEXT
) 
AS
$$
SELECT
    ihi.barcode AS item_barcode,
    ie.effective_call_number AS item_call_number,
    ihi.title AS item_title,
    to_char(ie.updated_date::TIMESTAMP, 'YYYY-MM-DD') AS item_updated_date
FROM (
    SELECT DISTINCT ON (item_id)
        item_id, note, note_type_name
    FROM folio_derived.item_notes
    WHERE note_type_name = 'Inventoried Condition'
    AND note LIKE 'Major%'
    ORDER BY item_id
) in2
    JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, barcode, title
        FROM folio_derived.items_holdings_instances
        ORDER BY item_id
    ) ihi ON ihi.item_id = in2.item_id
    JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, effective_call_number, updated_date
        FROM folio_derived.item_ext
        ORDER BY item_id
    ) ie ON ie.item_id = in2.item_id
$$
LANGUAGE SQL STABLE;
