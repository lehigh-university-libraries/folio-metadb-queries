--metadb:function get_outstanding_bills_with_user
-- This function retrieves all outstanding bills for a given user.
CREATE FUNCTION get_outstanding_bills_with_user()

RETURNS TABLE
(
    action_date DATE,
    action_type TEXT,    
    bill_amount NUMERIC,
    account_balance NUMERIC,
    user_barcode TEXT,
    username TEXT,
    user_last_name TEXT,
    item_title TEXT,
    item_call_number TEXT,
    item_barcode TEXT
) 
AS
$$
select cast(faa.transaction_date as DATE) as action_date, 
faa.type_action as action_type,
faa.transaction_amount as bill_amount, 
faa.account_balance, 
ug2.barcode AS user_barcode,  
ug2.user_last_name AS last_name,
ffa.title as item_title,
ffa.call_number as item_call_number,
ffa.barcode as item_barcode
from folio_derived.feesfines_accounts_actions faa
join folio_derived.users_groups ug2 on faa.user_id = ug2.user_id
join folio_feesfines.accounts__t ffa on faa.account_id = ffa.id
where faa.fine_status = 'Open'
  AND faa.type_action NOT LIKE 'Papercut%'
  AND faa.type_action NOT LIKE 'Paid fully%'
  AND faa.type_action NOT LIKE 'Cancelled%'
  AND faa.type_action NOT LIKE 'Refunded%'
  AND faa.type_action NOT LIKE 'Credited%'
  AND faa.type_action NOT LIKE 'Waived%'
 order by faa.transaction_date asc;
$$
LANGUAGE SQL STABLE;
