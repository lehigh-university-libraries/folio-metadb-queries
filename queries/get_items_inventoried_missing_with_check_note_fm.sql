--metadb:function get_items_inventoried_missing_with_check_note_fm
--This function retrieves all items with an item statistical code of Shelf Reading 2025 and with the item status of "missing". 
--There is  column for an item note that will be populated if the item_note_type_name is Workflow-Missing Searched. If the item
--record does not have a note with that not type name the column will be null.


CREATE FUNCTION get_items_inventoried_missing_with_check_note_fm()
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
    in2.note AS missing_searched_note  -- Only shows note if type matches
FROM
    folio_derived.items_holdings_instances ihi
    JOIN folio_derived.item_ext ie ON ie.item_id = ihi.item_id
    JOIN folio_derived.item_statistical_codes isc ON isc.item_id = ihi.item_id
    LEFT JOIN folio_derived.item_notes in2 
        ON in2.item_id = ihi.item_id AND in2.note_type_name = 'Workflow-Missing Searched'
WHERE
    isc.statistical_code_name = 'Shelf Reading 2025'
    AND ie.status_name = 'Missing'
    AND ie.effective_location_name LIKE 'Fairchild%';    
$$
LANGUAGE SQL;
