--metadb:function get_items_with_condition_note_minor
-- This function retrieves all items with an Inventory Condition Note that is Minor, filtered by location.
DROP FUNCTION IF EXISTS get_items_with_condition_note_minor;
CREATE FUNCTION get_items_with_condition_note_minor(location_filter TEXT DEFAULT 'All Locations')
RETURNS TABLE
(
    library_name TEXT,
    item_barcode TEXT,
    item_call_number TEXT,
    item_title TEXT,
    item_updated_date TEXT
) 
AS
$$
SELECT
    ll.library_name,
    ihi.barcode AS item_barcode,
    ie.effective_call_number AS item_call_number,
    ihi.title AS item_title,
    LEFT(ie.updated_date, 10) AS item_updated_date
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
WHERE
    (location_filter = 'All Locations' OR ll.library_name = location_filter)
ORDER BY ll.library_name, ie.effective_call_number;
$$
LANGUAGE SQL STABLE;
