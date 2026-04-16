DROP FUNCTION IF EXISTS get_items_with_repaired_note();
CREATE FUNCTION get_items_with_repaired_note()
RETURNS TABLE
(
library_name TEXT,
item_barcode TEXT,
item_call_number TEXT,
item_title TEXT,
item_note TEXT
)
AS
$$
SELECT
    ll.library_name AS library_name,
    ihi.barcode AS item_barcode,
    ie.effective_call_number AS item_call_number,
    ihi.title AS item_title,
    in2.note AS item_note
FROM
    folio_derived.items_holdings_instances ihi
    JOIN folio_derived.item_notes in2 ON in2.item_id = ihi.item_id
    JOIN folio_derived.item_ext ie ON ie.item_id = ihi.item_id
    JOIN folio_derived.locations_libraries ll ON ll.location_id = ie.effective_location_id
WHERE
    in2.note_type_name = 'Repaired'
ORDER BY library_name, item_call_number;
$$
LANGUAGE SQL STABLE;
