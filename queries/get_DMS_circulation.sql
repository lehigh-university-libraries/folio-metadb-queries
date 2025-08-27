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
        lt.loan_date::DATE AS loan_date,
        g."group" AS patron_group,   -- "group" is reserved, must be quoted
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
        AND lt.checkout_service_point_id = '99f509c0-1383-4f29-8fde-ff6970a4a8fe';
$$;

DROP VIEW IF EXISTS get_DMS_circulation_ordered;

CREATE VIEW get_DMS_circulation_ordered AS
SELECT *
FROM get_DMS_circulation(NULL, NULL)
ORDER BY loan_date DESC;
