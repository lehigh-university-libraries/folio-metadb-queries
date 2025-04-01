--metadb:function get_expired_users_with_loans

DROP FUNCTION IF EXISTS get_expired_users_with_loans;

CREATE FUNCTION get_expired_users_with_loans(
)
RETURNS TABLE (
    expire_date DATE,
	last_name TEXT,
	user_barcode TEXT,
    username TEXT,
	patron_group_name TEXT,
	loan_due_date DATE,
	item_barcode TEXT,
    call_number TEXT,
    title TEXT,
	loan_policy_name TEXT,
	status_date DATE,
    status_name TEXT
)
AS
$$
SELECT 
    cast(ug2.expiration_date as DATE) as expire_date,
    ug2.user_last_name AS last_name,
    ug2.barcode AS user_barcode, 
    ug2.username AS username,
    li.patron_group_name,
    cast(li.loan_due_date as DATE) as loan_due_date, 
    ie.barcode :: TEXT as item_barcode, 
    ie.effective_call_number, 
    ihi.title,
    li.loan_policy_name,
    cast(ie.status_date as DATE) as status_date,
    ie.status_name   
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
