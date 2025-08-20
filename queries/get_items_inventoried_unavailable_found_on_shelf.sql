--metadb:function get_items_inventoried_unavailable_found_on_shelf
--This fuction returns items inventoried with message 'unavailable item found on shelf'

CREATE FUNCTION get_items_inventoried_unavailable_found_on_shelf ()
    RETURNS TABLE (
        item_status text,
        item_location text,
        item_barcode text,
        call_number text,
        item_title text,
        item_note text,
        missing_searched_note text
    )
    AS $$
    SELECT DISTINCT
        iext.status_name AS item_status,
        iext.effective_location_name AS item_location,
        iext.barcode AS item_barcode,
        trim(concat(iext.effective_call_number_prefix, ' ', iext.effective_call_number, ' ', iext.effective_call_number, ' ', iext.volume, ' ', iext.copy_number)) AS call_number,
        inst.title AS instance_title,
        inot.note AS item_note,
        cast(iext.updated_date AS date) AS item_updated_date
    FROM
        folio_derived.item_ext iext
    LEFT JOIN folio_derived.item_notes inot ON iext.item_id = inot.item_id
    LEFT JOIN folio_derived.holdings_ext hrt ON iext.holdings_record_id = hrt.holdings_id
    LEFT JOIN folio_derived.instance_ext inst ON hrt.instance_id = inst.instance_id
    LEFT JOIN folio_derived.locations_libraries locl ON iext.effective_location_id = locl.location_id
WHERE
    inot.note LIKE 'Shelf status: Unavailable item is on shelf%'
    AND iext.status_name != 'Available'
ORDER BY
    item_location,
    call_number;
$$
LANGUAGE SQL;
