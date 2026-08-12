--metadb:function get_count_circ_textbook

DROP FUNCTION IF EXISTS get_count_circ_textbook;

CREATE FUNCTION get_count_circ_textbook(
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL
) 
RETURNS TABLE (
    barcode TEXT,
    call_number TEXT,
    title TEXT,
    undergrad_circs INTEGER,
    graduate_circs INTEGER,
    staff_circs INTEGER,
    ill_circs INTEGER,
    faculty_circs INTEGER,
    total_circs INTEGER
) 
AS 
$$
WITH loan_counts AS (
    SELECT 
        lt.item_id,
        COUNT(CASE WHEN LOWER(g.group) LIKE 'undergrad%' THEN 1 END) AS undergrad_circs,
        COUNT(CASE WHEN LOWER(g.group) LIKE 'grad%' THEN 1 END) AS graduate_circs,
        COUNT(CASE WHEN LOWER(g.group) LIKE 'staff%' THEN 1 END) AS staff_circs,
        COUNT(CASE WHEN LOWER(g.group) LIKE 'ill%' THEN 1 END) AS ill_circs,
        COUNT(CASE WHEN LOWER(g.group) LIKE 'faculty%' THEN 1 END) AS faculty_circs,
        COUNT(*) AS loan_count
    FROM 
        folio_circulation.loan__t AS lt
        LEFT JOIN folio_users.groups__t AS g 
            ON lt.patron_group_id_at_checkout = g.id
    WHERE 
        (start_date IS NULL OR lt.loan_date >= start_date) AND 
        (end_date IS NULL OR lt.loan_date <= end_date)
    GROUP BY 
        lt.item_id
)
SELECT
    ie.barcode :: TEXT AS barcode,
    ie.effective_call_number :: TEXT AS call_number,
    ihi.title :: TEXT AS title,
    COALESCE(lc.undergrad_circs, 0) :: INTEGER AS undergrad_circs,
    COALESCE(lc.graduate_circs, 0) :: INTEGER AS graduate_circs,
    COALESCE(lc.staff_circs, 0) :: INTEGER AS staff_circs,
    COALESCE(lc.ill_circs, 0) :: INTEGER AS ill_circs,
    COALESCE(lc.faculty_circs, 0) :: INTEGER AS faculty_circs,
    COALESCE(lc.loan_count, 0) :: INTEGER AS total_circs
FROM
    folio_derived.item_ext AS ie
    LEFT JOIN folio_derived.items_holdings_instances AS ihi 
        ON ie.item_id = ihi.item_id
    LEFT JOIN loan_counts AS lc 
        ON ie.item_id = lc.item_id
WHERE
    ie.effective_location_name = 'Fairchild - 5th Floor - North - F1RST Textbook Collection'
ORDER BY
    ie.effective_call_number;
$$
LANGUAGE SQL;
