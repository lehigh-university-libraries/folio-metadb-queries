DROP FUNCTION IF EXISTS get_count_circ_circle;

CREATE FUNCTION get_count_circ_circle(
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL
) 
RETURNS TABLE (
    barcode INTEGER,
    author TEXT,
    title TEXT,
    loan_count INTEGER
) 
LANGUAGE SQL AS 
$$
WITH loan_counts AS (
    SELECT item_id, COUNT(*) AS loan_count 
    FROM folio_derived.loans_items 
    WHERE 
        (start_date IS NULL OR loan_date >= start_date) AND 
        (end_date IS NULL OR loan_date <= end_date)
    GROUP BY item_id
)
SELECT 
    it.barcode AS barcode,
    string_agg(DISTINCT ic.contributor_name, ', ') AS author,
    it2.title AS title,
    COALESCE(lc.loan_count, 0) AS loan_count  -- Use pre-aggregated count
FROM folio_inventory.item__t it 
LEFT JOIN loan_counts lc 
    ON lc.item_id = it.id 
LEFT JOIN folio_derived.item_ext ie 
    ON ie.item_id = it.id  
LEFT JOIN folio_inventory.holdings_record__t hrt 
    ON hrt.id = it.holdings_record_id 
LEFT JOIN folio_inventory.instance__t it2 
    ON it2.id = hrt.instance_id 
LEFT JOIN folio_derived.instance_contributors ic 
    ON ic.instance_id = it2.id 
WHERE ie.material_type_name = 'circle'
GROUP BY it.barcode, it2.title, lc.loan_count;
$$
LANGUAGE SQL;
