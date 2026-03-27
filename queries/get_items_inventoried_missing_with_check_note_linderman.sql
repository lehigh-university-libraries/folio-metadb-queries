--metadb:function get_items_inventoried_missing_with_check_note_linderman
--This function retrieves all items with an item statistical code of Shelf Reading 2025 and with the item status of "missing". 
--There is  column for an item note that will be populated if the item_note_type_name is Workflow-Missing Searched. If the item
--record does not have a note with that not type name the column will be null.
--metadb:function get_items_inventoried_missing_with_check_note_linderman

DROP FUNCTION IF EXISTS get_items_inventoried_missing_with_check_note_linderman;
CREATE FUNCTION get_items_inventoried_missing_with_check_note_linderman()
RETURNS TABLE
(
    item_barcode TEXT,
    item_call_number TEXT,
    item_title TEXT,
    missing_searched_note TEXT  
) 
AS
$$
SELECT
    ihi.barcode AS item_barcode,
    ie.effective_call_number AS item_call_number,
    ihi.title AS item_title,
    in2.note AS missing_searched_note
FROM (
    SELECT DISTINCT ON (item_id)
        item_id
    FROM folio_derived.item_statistical_codes
    WHERE statistical_code_name = 'Shelf Reading 2025'
    ORDER BY item_id
) isc
    JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, barcode, title
        FROM folio_derived.items_holdings_instances
        ORDER BY item_id
    ) ihi ON ihi.item_id = isc.item_id
    JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, effective_call_number, status_name, effective_location_name
        FROM folio_derived.item_ext
        ORDER BY item_id
    ) ie ON ie.item_id = isc.item_id
    LEFT JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, note, note_type_name
        FROM folio_derived.item_notes
        WHERE note_type_name = 'Workflow-Missing Searched'
        ORDER BY item_id
    ) in2 ON in2.item_id = isc.item_id
WHERE
    ie.status_name = 'Missing'
    AND ie.effective_location_name LIKE 'Lind%'
ORDER BY ie.effective_call_number;
$$
LANGUAGE SQL STABLE;
