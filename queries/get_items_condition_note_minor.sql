--metadb:function get_items_condition_note_minor
-- This function retrieves all items with an Inventory Note about Minor condition fix needed.
DROP FUNCTION IF EXISTS get_items_condition_note_minor;
CREATE FUNCTION get_items_condition_note_minor()
RETURNS TABLE
(
    item_barcode TEXT,
    item_call_number TEXT,
    item_title TEXT,
    item_updated_date TEXT,
    library_name TEXT
) 
AS
$$
SELECT
    ihi.barcode AS item_barcode,
    ie.effective_call_number AS item_call_number,
    ihi.title AS item_title,
    to_char(ie.updated_date::TIMESTAMPTZ, 'YYYY-MM-DD') AS item_updated_date,
    ll.library_name AS library_name
FROM (
    SELECT DISTINCT ON (item_id)
        item_id, note, note_type_name
    FROM folio_derived.item_notes
    WHERE note_type_name = 'Inventoried Condition'
    AND note LIKE 'Minor%'
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
            item_id, effective_call_number, updated_date, effective_location_id
        FROM folio_derived.item_ext
        ORDER BY item_id
    ) ie ON ie.item_id = in2.item_id
    JOIN folio_derived.locations_libraries ll ON ll.location_id = ie.effective_location_id
ORDER BY ll.library_name, ie.effective_call_number;
$$
LANGUAGE SQL STABLE;
