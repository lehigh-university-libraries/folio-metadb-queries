--metadb:function get_palci_borrowing_with_bibdata_andpatron_group
-- This function retrieves three years of PALCI titles borrowed with bibligraphic data and patron group information.
CREATE FUNCTION get_palci_borrowing_with_bibdata_andpatron_group()
RETURNS TABLE
(
    item_barcode TEXT,
    item_call_number TEXT,
    contributor_name TEXT,
    item_title TEXT,
    item_publisher TEXT,
    date_of_publication TEXT,
    patron_group TEXT,
    loan_count INTEGER,
    renewal_count INTEGER
) 
AS
$$
SELECT 
    ie.barcode AS item_barcode,
    MAX(ie.effective_call_number) AS item_call_number,
    MAX(CASE 
        WHEN ic.contributor_is_primary = 'TRUE' THEN ic.contributor_name
        ELSE NULL
    END) AS contributor_name,
    MAX(ihi.title) AS item_title,
    MAX(ip.publisher) AS item_publisher,
    MAX(
  CASE 
    WHEN ip.date_of_publication ~ '^\d{4}$' 
    THEN TO_DATE(ip.date_of_publication, 'YYYY') 
    ELSE NULL 
  END
) AS date_of_publication,
    g.group AS patron_group,    
    COUNT(lt.id) AS loan_count,
    COALESCE(SUM(lt.renewal_count), 0) AS renewal_count
FROM folio_circulation.loan__t AS lt
JOIN folio_derived.item_ext AS ie ON lt.item_id = ie.item_id
JOIN folio_derived.items_holdings_instances AS ihi ON lt.item_id = ihi.item_id
LEFT JOIN folio_derived.instance_contributors ic ON ic.instance_id = ihi.instance_id
LEFT JOIN (
    SELECT DISTINCT ON (instance_id)
           instance_id,
           publisher,
           date_of_publication
    FROM folio_derived.instance_publication
    ORDER BY instance_id, date_of_publication NULLS LAST
) ip ON ip.instance_id = ihi.instance_id
LEFT JOIN folio_users.groups__t AS g ON lt.patron_group_id_at_checkout = g.id
WHERE lt.loan_date >= (CURRENT_DATE - INTERVAL '5 year')
  AND lt.loan_date < CURRENT_DATE
  AND g.group NOT IN ('ill', 'palciuser')
GROUP BY ie.barcode, g.group
ORDER BY MAX(ie.effective_call_number), g.group;
$$
LANGUAGE SQL STABLE;
