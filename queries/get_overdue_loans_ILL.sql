--metadb:function get_overdue_loans_with_patron
DROP FUNCTION IF EXISTS get_overdue_loans_with_patron;
CREATE FUNCTION get_overdue_loans_with_patron()
    
RETURNS TABLE
(
        loan_due_date TEXT,
        item_barcode TEXT,
        item_effective_call_number TEXT,
        item_title TEXT,
        item_status TEXT,
        location_effective TEXT, 
        patron_barcode TEXT,
        patron_email TEXT
)
AS 
$$
SELECT TO_CHAR(li.loan_due_date::TIMESTAMP, 'YYYY-MM-DD') AS loan_due_date,
        ihi.barcode AS item_barcode,
        ie.effective_call_number AS item_effective_call_number,
        ihi.title AS item_title,
        li.item_status AS item_status,
        ie.effective_location_name AS location_effective,
        ug.barcode AS patron_barcode,
        ug.user_email AS patron_email
FROM (
    SELECT DISTINCT ON (item_id)
        item_id, barcode, title
    FROM folio_derived.items_holdings_instances
    ORDER BY item_id
) ihi
        JOIN (
            SELECT DISTINCT ON (item_id)
                item_id, effective_call_number, effective_location_name,
                effective_location_id, discovery_suppress
            FROM folio_derived.item_ext
            ORDER BY item_id
        ) ie ON ie.item_id = ihi.item_id
        JOIN (
            SELECT DISTINCT ON (item_id)
                item_id, loan_due_date, item_status,
                patron_group_name, user_id, loan_status
            FROM folio_derived.loans_items
            WHERE loan_status = 'Open'
            AND loan_due_date::TIMESTAMP < CURRENT_DATE
            ORDER BY item_id, loan_due_date DESC
        ) li ON ihi.item_id = li.item_id
        JOIN folio_derived.locations_libraries ll ON ll.location_id = ie.effective_location_id
        JOIN (
            SELECT DISTINCT ON (user_id)
                user_id, barcode, user_email
            FROM folio_derived.users_groups
            ORDER BY user_id
        ) ug ON li.user_id = ug.user_id
WHERE li.patron_group_name IN ('ill', 'palciuser')
        AND ie.discovery_suppress = 'False'
ORDER BY patron_barcode, loan_due_date ASC;
$$
LANGUAGE SQL STABLE;
