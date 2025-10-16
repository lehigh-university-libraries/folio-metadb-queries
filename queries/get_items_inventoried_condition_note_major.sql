--metadb:function get_items_with_condition_note_major
-- This function retrieves all items with an Inventory Condition Note that is Major, filtered by location.
CREATE FUNCTION get_items_with_condition_note_major(location_filter TEXT DEFAULT 'All Locations')
RETURNS TABLE
(
    library_name TEXT,
    item_barcode TEXT,
    item_call_number TEXT,
    item_title TEXT,
    item_updated_date DATE
) 
AS
$$
SELECT
    ll.library_name,
    ihi.barcode AS item_barcode,
    ie.effective_call_number AS item_call_number,
    ihi.title AS item_title,
    CAST(ie.updated_date AS DATE) AS item_updated_date
FROM
    folio_derived.items_holdings_instances ihi
    JOIN folio_derived.item_notes in2 ON in2.item_id = ihi.item_id
    JOIN folio_derived.item_ext ie ON ie.item_id = ihi.item_id
    JOIN folio_derived.locations_libraries ll ON ll.location_id = ie.effective_location_id
WHERE
    in2.note_type_name = 'Inventoried Condition'
    AND in2.note LIKE 'Major%'
    AND (location_filter = 'All Locations' OR ll.library_name = location_filter)
$$
LANGUAGE SQL;
