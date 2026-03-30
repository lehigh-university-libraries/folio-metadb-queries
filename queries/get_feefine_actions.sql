--metadb:function get_feefine_actions
--metadb:function get_feefine_actions
DROP FUNCTION IF EXISTS get_feefine_actions;
CREATE FUNCTION get_feefine_actions(
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL
) 
RETURNS TABLE (
    action_date TEXT,
    action_type TEXT,
    action_amount NUMERIC,
    account_balance NUMERIC,
    fine_status TEXT,
    operator_id TEXT,
    user_barcode TEXT,
    last_name TEXT,
    title TEXT,
    item_barcode TEXT,
    returned_date TEXT
) 
AS 
$$
SELECT 
    to_char(faa.transaction_date, 'YYYY-MM-DD') AS action_date,
    faa.type_action AS action_type,
    faa.transaction_amount AS action_amount, 
    faa.account_balance AS account_balance,
    faa.fine_status AS fine_status,
    faa.operator_id AS operator_id,
    ug2.barcode AS user_barcode,  
    ug2.user_last_name AS last_name,
    ffa.title AS title,
    ffa.barcode AS item_barcode,
    to_char(ffa.returned_date, 'YYYY-MM-DD') AS returned_date
FROM (
    SELECT DISTINCT ON (account_id)
        account_id, transaction_date, type_action, transaction_amount,
        account_balance, fine_status, operator_id, user_id
    FROM folio_derived.feesfines_accounts_actions
    ORDER BY account_id, transaction_date DESC
) faa
JOIN (
    SELECT DISTINCT ON (user_id)
        user_id, barcode, user_last_name
    FROM folio_derived.users_groups
    ORDER BY user_id
) ug2 ON faa.user_id = ug2.user_id
JOIN (
    SELECT DISTINCT ON (id)
        id, title, barcode, returned_date
    FROM folio_feesfines.accounts__t
    ORDER BY id
) ffa ON faa.account_id = ffa.id
WHERE 
    (start_date IS NULL OR faa.transaction_date::DATE >= start_date) AND 
    (end_date IS NULL OR faa.transaction_date::DATE <= end_date)
ORDER BY faa.transaction_date DESC;
$$
LANGUAGE SQL STABLE;
