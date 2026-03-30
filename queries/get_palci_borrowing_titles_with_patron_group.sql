-- This function retrieves three years of PALCI titles borrowed with patron group information.
--metadb:function get_palci_borrowing_titles_with_patron_group
DROP FUNCTION IF EXISTS get_palci_borrowing_titles_with_patron_group;
CREATE FUNCTION get_palci_borrowing_titles_with_patron_group()
RETURNS TABLE
(
    loan_date TEXT,
    item_title TEXT,
    patron_group TEXT
) 
AS
$$
SELECT
    to_char(lt.loan_date, 'YYYY-MM-DD') AS loan_date,
    ihi.title AS item_title,
    g.group AS patron_group
FROM folio_circulation.loan__t AS lt
JOIN (
    SELECT DISTINCT ON (item_id)
        item_id
    FROM folio_derived.item_ext
    ORDER BY item_id
) ie ON lt.item_id = ie.item_id
JOIN (
    SELECT DISTINCT ON (item_id)
        item_id, title, material_type_name
    FROM folio_derived.items_holdings_instances
    ORDER BY item_id
) ihi ON lt.item_id = ihi.item_id
LEFT JOIN folio_users.groups__t AS g ON lt.patron_group_id_at_checkout = g.id
WHERE lt.loan_date >= (CURRENT_DATE - INTERVAL '3 year')
    AND lt.loan_date < CURRENT_DATE
    AND ihi.material_type_name = 'palci'
ORDER BY lt.loan_date DESC;
$$
LANGUAGE SQL STABLE;
