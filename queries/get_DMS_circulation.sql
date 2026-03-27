--metadb:function get_DMS_circulation
DROP FUNCTION IF EXISTS get_DMS_circulation;
CREATE FUNCTION get_DMS_circulation(
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL
) 
RETURNS TABLE (
    loan_date TEXT,
    patron_group TEXT,
    barcode TEXT,
    call_number TEXT,
    title TEXT
)
LANGUAGE SQL STABLE
AS $$
    SELECT
        LEFT(lt.loan_date::TEXT, 10) AS loan_date,
        g."group" AS patron_group,
        ie.barcode,
        ie.effective_call_number AS call_number,
        ihi.title
    FROM folio_circulation.loan__t AS lt
    JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, barcode, effective_call_number
        FROM folio_derived.item_ext
        ORDER BY item_id
    ) ie ON lt.item_id = ie.item_id
    JOIN (
        SELECT DISTINCT ON (item_id)
            item_id, title
        FROM folio_derived.items_holdings_instances
        ORDER BY item_id
    ) ihi ON lt.item_id = ihi.item_id
    LEFT JOIN folio_users.groups__t AS g 
        ON lt.patron_group_id_at_checkout = g.id
    WHERE 
        (start_date IS NULL OR LEFT(lt.loan_date::TEXT, 10)::DATE >= start_date)
        AND (end_date IS NULL OR LEFT(lt.loan_date::TEXT, 10)::DATE <= end_date)
        AND lt.checkout_service_point_id = '99f509c0-1383-4f29-8fde-ff6970a4a8fe'
    ORDER BY LEFT(lt.loan_date::TEXT, 10) ASC;
$$;

DROP VIEW IF EXISTS get_DMS_circulation_ordered;
CREATE VIEW get_DMS_circulation_ordered AS
SELECT *
FROM get_DMS_circulation(NULL, NULL);
