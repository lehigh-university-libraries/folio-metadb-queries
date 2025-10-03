--metadb:function get_feefine_actions
DROP FUNCTION IF EXISTS get_feefine_actions;
CREATE FUNCTION get_feefine_actions(
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL
) 
RETURNS TABLE (
    action_date DATE,
    action_type TEXT,
    action_amount NUMERIC,
    account_balance NUMERIC,
    fine_status TEXT,
    operator_id TEXT,
    user_barcode TEXT,
    last_name TEXT,
    title TEXT,
    item_barcode TEXT,
    returned_date DATE
) 
AS 
$$
SELECT 
    cast(faa.transaction_date as DATE) as action_date, 
    faa.type_action as action_type,
    faa.transaction_amount as action_amount, 
    faa.account_balance as account_balance,
    faa.fine_status as fine_status,
    faa.operator_id as operator_id,
    ug2.barcode AS user_barcode,  
    ug2.user_last_name AS last_name,
    ffa.title AS title,
    ffa.barcode as item_barcode,
    cast(ffa.returned_date as DATE) as returned_date
FROM folio_derived.feesfines_accounts_actions faa
JOIN folio_derived.users_groups ug2 ON faa.user_id = ug2.user_id
JOIN folio_feesfines.accounts__t ffa ON faa.account_id = ffa.id
WHERE 
    (start_date IS NULL OR cast(faa.transaction_date as DATE) >= start_date) AND 
    (end_date IS NULL OR cast(faa.transaction_date as DATE) <= end_date)
$$
LANGUAGE SQL;
