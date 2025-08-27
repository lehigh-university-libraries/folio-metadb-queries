--metadb:function get_DMS_circulation
DROP FUNCTION IF EXISTS get_DMS_circulation;

CREATE FUNCTION get_DMS_circulation(
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL
) 
RETURNS TABLE (
    loan_date DATE,
    patron_group TEXT,
    barcode TEXT,
    call_number TEXT,
    title TEXT
)
LANGUAGE SQL
AS $$
    SELECT
        CAST(lt.loan_date AS DATE) AS loan_date,
        g.group AS patron_group,
        ie.barcode,
        ie.effective_call_number AS call_number,
        ihi.title
    FROM folio_circulation.loan__t AS lt
    JOIN folio_derived.item_ext AS ie 
        ON lt.item_id = ie.item_id
    JOIN folio_derived.items_holdings_instances AS ihi 
        ON lt.item_id = ihi.item_id
    LEFT JOIN folio_users.groups__t AS g 
        ON lt.patron_group_id_at_checkout = g.id
    WHERE 
    (start_date IS NULL OR lt.loan_date::DATE >= start_date)
    AND (end_date IS NULL OR lt.loan_date::DATE <= end_date)
    ORDER BY lt.loan_date DESC
$$;
