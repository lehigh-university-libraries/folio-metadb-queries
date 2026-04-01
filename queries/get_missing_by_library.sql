--metadb:function get_missing_counts
-- This function retrieves counts of missing items for all library locations.
DROP FUNCTION IF EXISTS get_missing_counts;
CREATE FUNCTION get_missing_counts()
RETURNS TABLE
(
    library_name TEXT,
    item_count BIGINT
) 
AS
$$
SELECT *
FROM (
    SELECT
        ll.library_name,
        COUNT(*) AS item_count
    FROM (
        SELECT DISTINCT ON (item_id)
            item_id
        FROM folio_derived.items_holdings_instances
        ORDER BY item_id
    ) ihi
    JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, effective_location_id, status_name, discovery_suppress
        FROM folio_derived.item_ext
        WHERE status_name = 'In transit'
            AND discovery_suppress = 'False'
        ORDER BY item_id
    ) ie ON ie.item_id = ihi.item_id
    JOIN folio_derived.locations_libraries ll ON ll.location_id = ie.effective_location_id
    GROUP BY ll.library_name

    UNION ALL

    SELECT
        'TOTAL' AS library_name,
        COUNT(*) AS item_count
    FROM (
        SELECT DISTINCT ON (item_id)
            item_id
        FROM folio_derived.items_holdings_instances
        ORDER BY item_id
    ) ihi
    JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, effective_location_id, status_name, discovery_suppress
        FROM folio_derived.item_ext
        WHERE status_name = 'Missing'
            AND discovery_suppress = 'False'
        ORDER BY item_id
    ) ie ON ie.item_id = ihi.item_id
    JOIN folio_derived.locations_libraries ll ON ll.location_id = ie.effective_location_id
) AS combined
ORDER BY
    CASE WHEN library_name = 'TOTAL' THEN 1 ELSE 0 END,
    item_count DESC;
$$
LANGUAGE SQL STABLE;
