--metadb:function get_count_circ_circle

DROP FUNCTION IF EXISTS get_count_circ_circle(DATE, DATE);
DROP FUNCTION IF EXISTS get_count_circ_circle();

CREATE FUNCTION get_count_circ_circle(
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL
) 
RETURNS TABLE (
    barcode TEXT,
    author TEXT,
    title TEXT,
    last_loan_date TEXT, -- Added formatted date output
    loan_count INTEGER
) 
AS 
$$
WITH loan_counts AS (
    SELECT 
        item_id, 
        COUNT(*) AS loan_count,
        MAX(loan_date) AS max_loan_date
    FROM folio_derived.loans_items 
    WHERE 
        (start_date IS NULL OR loan_date::DATE >= start_date) AND 
        (end_date IS NULL OR loan_date::DATE <= end_date)
    GROUP BY item_id
)
SELECT 
    it.barcode :: TEXT AS barcode,
    string_agg(DISTINCT ic.contributor_name, ', ') :: TEXT AS author,
    it2.title :: TEXT AS title,
    TO_CHAR(lc.max_loan_date, 'YYYY-MM-DD') :: TEXT AS last_loan_date,
    COALESCE(lc.loan_count, 0) :: INTEGER AS loan_count
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
GROUP BY it.barcode, it2.title, lc.max_loan_date, lc.loan_count;
$$
LANGUAGE SQL;
