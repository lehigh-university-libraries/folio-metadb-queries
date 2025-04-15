--metadb:function get_palci_borrowing_titles_with_patron_group
-- This function retrieves three years of PALCI titles borrowed with patron group information.
CREATE FUNCTION get_palci_borrowing_titles_with_patron_group()

RETURNS TABLE
(
    loan_date DATE,
    item_title TEXT,
    patron_group TEXT
) 
AS
$$
SELECT cast(lt.loan_date as DATE) as loan_date,
ihi.title as item_title,
g.group as patron_group
FROM folio_circulation.loan__t AS lt
JOIN folio_derived.item_ext AS ie ON lt.item_id = ie.item_id
JOIN folio_derived.items_holdings_instances AS ihi ON lt.item_id = ihi.item_id
LEFT JOIN folio_users.groups__t AS g ON lt.patron_group_id_at_checkout = g.id
WHERE lt.loan_date >= (CURRENT_DATE - INTERVAL '3 year') AND lt.loan_date < CURRENT_DATE and ihi.material_type_name ='palci'
ORDER BY loan_date desc;
$$
LANGUAGE SQL STABLE;
