--metadb:function get_items_inventoried_unavailable_found_on_shelf
DROP FUNCTION IF EXISTS get_items_inventoried_unavailable_found_on_shelf;
CREATE FUNCTION get_items_inventoried_unavailable_found_on_shelf()
    RETURNS TABLE (
        item_status text,
        item_location text,
        item_barcode text,
        call_number text,
        item_title text,
        item_note text,
        item_updated_date text
    )
AS $$
    SELECT
        iext.status_name AS item_status,
        iext.effective_location_name AS item_location,
        iext.barcode AS item_barcode,
        trim(concat(
            iext.effective_call_number_prefix, ' ',
            iext.effective_call_number, ' ',
            iext.volume, ' ',
            iext.copy_number
        )) AS call_number,
        inst.title AS item_title,
        inot.note AS item_note,
        LEFT(iext.updated_date, 10) AS item_updated_date
    FROM (
        SELECT DISTINCT ON (item_id)
            item_id, status_name, effective_location_name, barcode,
            effective_call_number_prefix, effective_call_number,
            volume, copy_number, updated_date, holdings_record_id,
            effective_location_id
        FROM folio_derived.item_ext
        ORDER BY item_id
    ) iext
    LEFT JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, note, note_type_name
        FROM folio_derived.item_notes
        WHERE note LIKE 'Shelf status: Unavailable item is on shelf%'
        ORDER BY item_id
    ) inot ON iext.item_id = inot.item_id
    LEFT JOIN (
        SELECT DISTINCT ON (id)
            id, instance_id
        FROM folio_derived.holdings_ext
        ORDER BY id
    ) hrt ON iext.holdings_record_id = hrt.id
    LEFT JOIN (
        SELECT DISTINCT ON (instance_id)
            instance_id, title
        FROM folio_derived.instance_ext
        ORDER BY instance_id
    ) inst ON hrt.instance_id = inst.instance_id
    LEFT JOIN folio_derived.locations_libraries locl ON iext.effective_location_id = locl.location_id
    WHERE
        inot.note LIKE 'Shelf status: Unavailable item is on shelf%'
        AND iext.status_name != 'Available'
    ORDER BY
        item_location,
        call_number;
$$
LANGUAGE SQL STABLE;
