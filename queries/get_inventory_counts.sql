--metadb:function get_inventory_counts
-- This function retrieves inventory counts for all library locations.
CREATE FUNCTION get_inventory_counts()
RETURNS TABLE
(
    library_name TEXT,
    item_count TEXT
) 
AS
$$

SELECT
    *
FROM (
    SELECT
        ll.library_name,
        COUNT(*) AS item_count
    FROM
        folio_derived.items_holdings_instances ihi
        JOIN folio_derived.item_ext ie ON ie.item_id = ihi.item_id
        JOIN folio_derived.item_statistical_codes isc ON isc.item_id = ihi.item_id
        JOIN folio_derived.locations_libraries ll ON ll.location_id = ie.effective_location_id
    WHERE
        isc.statistical_code_name = 'Shelf Reading 2025'
    GROUP BY
        ll.library_name
    UNION ALL
    SELECT
        'TOTAL' AS library_name,
        COUNT(*) AS item_count
    FROM
        folio_derived.items_holdings_instances ihi
        JOIN folio_derived.item_ext ie ON ie.item_id = ihi.item_id
        JOIN folio_derived.item_statistical_codes isc ON isc.item_id = ihi.item_id
        JOIN folio_derived.locations_libraries ll ON ll.location_id = ie.effective_location_id
    WHERE
        isc.statistical_code_name = 'Shelf Reading 2025') AS combined
ORDER BY
    CASE WHEN library_name = 'TOTAL' THEN
        1
    ELSE
        0
    END,
    item_count DESC;
$$
LANGUAGE SQL;
