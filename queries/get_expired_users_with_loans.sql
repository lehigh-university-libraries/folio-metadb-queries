--metadb:function get_expired_users_with_loans
DROP FUNCTION IF EXISTS get_expired_users_with_loans;
CREATE FUNCTION get_expired_users_with_loans()
RETURNS TABLE (
expire_date TEXT,
last_name TEXT,
user_barcode TEXT,
user_email TEXT,
patron_group_name TEXT,
loan_due_date TEXT,
item_barcode TEXT,
call_number TEXT,
title TEXT,
loan_policy_name TEXT,
status_date TEXT,
status_name TEXT
)
AS
$$
SELECT DISTINCT
    to_char(ug2.expiration_date::TIMESTAMP, 'YYYY-MM-DD') as expire_date,
    ug2.user_last_name AS last_name,
    ug2.barcode AS user_barcode, 
    ug2.user_email AS user_email,
    li.patron_group_name,
    to_char(li.loan_due_date::TIMESTAMP, 'YYYY-MM-DD') as loan_due_date, 
    ie.barcode::TEXT as item_barcode, 
    ie.effective_call_number, 
    ihi.title,
    li.loan_policy_name,
    to_char(ie.status_date::TIMESTAMP, 'YYYY-MM-DD') as status_date,
    ie.status_name   
FROM (
    SELECT DISTINCT ON (item_id)
        item_id, user_id, loan_due_date, loan_status, 
        patron_group_name, loan_policy_name
    FROM folio_derived.loans_items
    WHERE loan_status = 'Open'
    ORDER BY item_id, loan_due_date DESC
) li
JOIN folio_derived.item_ext ie 
    on li.item_id = ie.item_id
JOIN (
    SELECT DISTINCT ON (item_id) item_id, title
    FROM folio_derived.items_holdings_instances
    ORDER BY item_id
) ihi ON li.item_id = ihi.item_id
JOIN folio_derived.users_groups ug2 
    on li.user_id = ug2.user_id
WHERE ug2.expiration_date is not null 
    and ie.discovery_suppress = 'False'
ORDER BY expire_date desc;
$$
LANGUAGE SQL;
