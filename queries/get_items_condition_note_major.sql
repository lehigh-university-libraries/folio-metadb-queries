--metadb:function get_items_with_spine_label_note
-- This function retrieves all items with an Inventory Note about the Spine Label needing to be replaced.
CREATE FUNCTION get_items_with_spine_label_note()
RETURNS TABLE
(
    item_barcode TEXT,
    item_call_number TEXT,
    item_title TEXT,
    item_updated_date DATE
) 
AS
$$
SELECT
    ihi.barcode AS item_barcode,
    ie.effective_call_number AS item_call_number,
    ihi.title AS item_title,
    cast(ie.updated_date AS date) AS item_updated_date
FROM
    folio_derived.items_holdings_instances ihi
    JOIN folio_derived.item_notes in2 ON in2.item_id = ihi.item_id
    JOIN folio_derived.item_ext ie ON ie.item_id = ihi.item_id
WHERE
    in2.note_type_name = 'Inventoried Condition'
    AND in2.note LIKE 'Major%';
$$
LANGUAGE SQL;
