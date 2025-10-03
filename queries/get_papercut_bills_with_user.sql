--metadb:function get_papercut_bills_with_user
-- This function retrieves all outstanding Papercut bills for a given user.
CREATE FUNCTION get_papercut_bills_with_user()

RETURNS TABLE
(
    action_date DATE,
    action_type TEXT,    
    bill_amount NUMERIC,
    account_balance NUMERIC,
    user_barcode TEXT,
    last_name TEXT
) 
AS
$$
select cast(faa.transaction_date as DATE) as action_date, 
faa.type_action as action_type,
faa.transaction_amount as bill_amount, 
faa.account_balance as account_balance, 
ug2.barcode AS user_barcode,  
ug2.user_last_name AS last_name
from folio_derived.feesfines_accounts_actions faa
join folio_derived.users_groups ug2 on faa.user_id = ug2.user_id
join folio_feesfines.accounts__t ffa on faa.account_id = ffa.id
where faa.fine_status = 'Open'
  AND faa.type_action = 'Papercut'
 order by faa.transaction_date desc;
;
$$
LANGUAGE SQL STABLE;
