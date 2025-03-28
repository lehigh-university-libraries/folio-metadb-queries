--metadb:function get_expired_users_with_loans

DROP FUNCTION IF EXISTS get_expired_users_with_loans;

CREATE FUNCTION get_expired_users_with_loans(
)
RETURNS TABLE (
    item_barcode TEXT,
    call_number TEXT,
    title TEXT,
    status_name TEXT,
    status_date DATE,
    loan_due_date DATE,
    loan_policy_name TEXT,
    patron_group_name TEXT,
    user_barcode TEXT,
    username TEXT,
    last_name TEXT,
    expire_date DATE
)
AS
$$
SELECT 
    ie.barcode :: TEXT as item_barcode, 
    ie.effective_call_number, 
    ihi.title, ie.status_name, 
    cast(ie.status_date as DATE) as status_date, 
    cast(li.loan_due_date as DATE) as loan_due_date, 
    li.loan_policy_name, 
    li.patron_group_name, 
    ug2.barcode AS user_barcode, 
    ug2.username AS username, 
    ug2.user_last_name AS last_name, 
    cast(ug2.expiration_date as DATE) as expire_date
FROM folio_derived.loans_items li
JOIN folio_derived.item_ext ie 
    on li.item_id = ie.item_id
JOIN folio_derived.items_holdings_instances ihi 
    on li.item_id = ihi.item_id
JOIN folio_derived.users_groups ug2 
    on li.user_id = ug2.user_id
WHERE li.loan_status = 'Open' 
    and ug2.expiration_date is not null 
    and ie.discovery_suppress = 'False'
ORDER BY effective_call_number desc;
$$
LANGUAGE SQL;
