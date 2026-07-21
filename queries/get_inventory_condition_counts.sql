--metadb:function get_inventory_condition_counts
-- This function retrieves inventory condition count totals for all library locations.
DROP FUNCTION IF EXISTS get_inventory_condition_counts;
CREATE FUNCTION get_inventory_condition_counts()
RETURNS TABLE
(
    Inventory_Condition TEXT,
    item_count BIGINT
) 
AS
$$
SELECT
    isc.condition as Inventory_Condition,
    COUNT(*) AS item_count
FROM (
    SELECT DISTINCT ON (item_id)
        item_id,
        CASE
            WHEN note LIKE 'Major%'   THEN 'Major'
            WHEN note LIKE 'Minor%'   THEN 'Minor'
            WHEN note LIKE 'Barcode%' THEN 'Barcode'
            WHEN note LIKE 'Spine%'   THEN 'Spine'
        END AS condition
    FROM folio_derived.item_notes
    WHERE note_type_name = 'Inventoried Condition'
    AND (note LIKE 'Major%' OR note LIKE 'Minor%' OR note LIKE 'Barcode%' OR note LIKE 'Spine%')
    ORDER BY item_id
) isc
    JOIN (
        SELECT DISTINCT ON (item_id)
            item_id
        FROM folio_derived.items_holdings_instances
        ORDER BY item_id
    ) ihi ON ihi.item_id = isc.item_id
    JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, effective_location_id
        FROM folio_derived.item_ext
        ORDER BY item_id
    ) ie ON ie.item_id = isc.item_id
    JOIN folio_derived.locations_libraries ll ON ll.location_id = ie.effective_location_id
Group BY
     isc.condition;
$$
LANGUAGE SQL STABLE;
