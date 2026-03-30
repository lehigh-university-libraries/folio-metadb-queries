--metadb:function get_circulation_summary_with_patron_group
-- This function retrieves five years of circulated titles borrowed with bibliographic data and patron group information.
DROP FUNCTION IF EXISTS get_circulation_summary_with_patron_group;
CREATE FUNCTION get_circulation_summary_with_patron_group()
RETURNS TABLE
(
    item_barcode TEXT,
    item_call_number TEXT,
    contributor_name TEXT,
    item_title TEXT,
    item_publisher TEXT,
    date_of_publication INTEGER,
    patron_group TEXT,
    loan_count BIGINT,
    renewal_count NUMERIC
) 
AS
$$
SELECT 
    ie.barcode AS item_barcode,
    MAX(ie.effective_call_number) AS item_call_number,
    MAX(ic.contributor_name) AS contributor_name,
    MAX(ihi.title) AS item_title,
    MAX(ip.publisher) AS item_publisher,
    MAX(
        CASE 
            WHEN ip.date_of_publication ~ '\d{4}' 
            THEN SUBSTRING(ip.date_of_publication FROM '\d{4}')::INTEGER
            ELSE NULL
        END
    ) AS date_of_publication,
    g.group AS patron_group,    
    COUNT(lt.id) AS loan_count,
    COALESCE(SUM(lt.renewal_count), 0) AS renewal_count
FROM (
    SELECT DISTINCT ON (id)
        id, item_id, loan_date, renewal_count, patron_group_id_at_checkout
    FROM folio_circulation.loan__t
    WHERE loan_date >= (CURRENT_DATE - INTERVAL '5 year')
        AND loan_date < CURRENT_DATE
    ORDER BY id
) lt
JOIN (
    SELECT DISTINCT ON (item_id)
        item_id, barcode, effective_call_number
    FROM folio_derived.item_ext
    ORDER BY item_id
) ie ON lt.item_id = ie.item_id
JOIN (
    SELECT DISTINCT ON (item_id)
        item_id, title, instance_id
    FROM folio_derived.items_holdings_instances
    ORDER BY item_id
) ihi ON lt.item_id = ihi.item_id
LEFT JOIN (
    SELECT DISTINCT ON (instance_id)
        instance_id, contributor_name
    FROM folio_derived.instance_contributors
    WHERE contributor_is_primary = 'TRUE'
    ORDER BY instance_id
) ic ON ic.instance_id = ihi.instance_id
LEFT JOIN (
    SELECT DISTINCT ON (instance_id)
        instance_id, publisher, date_of_publication
    FROM folio_derived.instance_publication
    ORDER BY instance_id, date_of_publication NULLS LAST
) ip ON ip.instance_id = ihi.instance_id
LEFT JOIN folio_users.groups__t AS g ON lt.patron_group_id_at_checkout = g.id
WHERE g.group NOT IN ('ill', 'palciuser')
GROUP BY ie.barcode, g.group
ORDER BY MAX(ie.effective_call_number), g.group;
$$
LANGUAGE SQL STABLE;
