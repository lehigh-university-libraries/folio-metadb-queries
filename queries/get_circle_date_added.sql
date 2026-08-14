--metadb:function get_circle_date_added
DROP FUNCTION IF EXISTS get_circle_date_added;

CREATE FUNCTION get_circle_date_added(
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL
) 
RETURNS TABLE (
    circle_book_added TIMESTAMPTZ,
    item_barcode TEXT,
    title TEXT,
    author TEXT,
    call_number TEXT,
    item_status TEXT
) 
LANGUAGE sql
AS 
$$
SELECT
    he.created_date AS circle_book_added,
    ie2.barcode AS item_barcode,
    ie.title AS title,
    string_agg(ic.contributor_name, '; ') AS author,
    he.call_number AS call_number,
    ie2.status_name AS item_status

FROM
    folio_inventory.item__t it 
    LEFT JOIN folio_derived.item_ext ie2 ON ie2.item_id = it.id 
    JOIN folio_inventory.holdings_record__t hrt ON hrt.id = it.holdings_record_id 
    LEFT JOIN folio_derived.holdings_ext he ON he.id = hrt.id 
    LEFT JOIN folio_inventory.instance__t it2 ON it2.id = hrt.instance_id 
    LEFT JOIN folio_derived.instance_ext ie ON ie.instance_id = it2.id
    LEFT JOIN folio_derived.instance_contributors ic ON ic.instance_id = it2.id

WHERE
    ie2.effective_location_name = 'Fairchild - 4th Floor - CIRCLE'
    AND (it.discovery_suppress::BOOLEAN <> TRUE OR it.discovery_suppress IS NULL)
    AND (hrt.discovery_suppress::BOOLEAN <> TRUE OR hrt.discovery_suppress IS NULL)
    AND (it2.discovery_suppress::BOOLEAN <> TRUE OR it2.discovery_suppress IS NULL)
    -- Parameterized Holdings Created Date Range:
    AND (start_date IS NULL OR he.created_date >= start_date::TIMESTAMPTZ)
    AND (end_date IS NULL OR he.created_date < (end_date + INTERVAL '1 day')::TIMESTAMPTZ)

GROUP BY
    he.created_date,
    ie2.barcode,
    ie.title,
    he.call_number,
    ie2.status_name;
$$;
