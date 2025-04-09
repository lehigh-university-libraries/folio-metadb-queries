--metadb:function get_circulation_counts_with_patron_group
-- This function retrieves all items with circulation counts in a time period with patron group information (excluding ILL circulation).
CREATE FUNCTION get_circulation_counts_with_patron_group()

RETURNS TABLE
(
    item_barcode TEXT,
    item_call_number TEXT,
    item_title TEXT,
    patron_group TEXT,
    loan_count INTEGER,
    RENEWAL_count INTEGER
) 
AS
$$
SELECT ie.barcode,
       ie.effective_call_number,
       ihi.title,
       g.group AS patron_group,
       COALESCE(COUNT(lt.id), 0) AS loan_count,
       COALESCE(SUM(renewal_count), 0) AS renewal_count
FROM folio_circulation.loan__t AS lt
JOIN folio_derived.item_ext AS ie ON lt.item_id = ie.item_id
JOIN folio_derived.items_holdings_instances AS ihi ON lt.item_id = ihi.item_id
LEFT JOIN folio_users.groups__t AS g ON lt.patron_group_id_at_checkout = g.id
WHERE lt.loan_date >= (CURRENT_DATE - INTERVAL '5 year') AND lt.loan_date < CURRENT_DATE and g.group not in('ill','palciuser')
GROUP BY ie.barcode, ie.effective_call_number, ihi.title, lt.patron_group_id_at_checkout, g.group
ORDER BY ie.effective_call_number;
$$
LANGUAGE SQL STABLE;
