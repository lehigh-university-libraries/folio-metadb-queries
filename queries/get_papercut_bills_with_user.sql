--metadb:function get_papercut_bills_with_user
-- This function retrieves all outstanding Papercut bills for a given user.
--metadb:function get_papercut_bills_with_user
DROP FUNCTION IF EXISTS get_papercut_bills_with_user;
CREATE FUNCTION get_papercut_bills_with_user()
RETURNS TABLE
(
    action_date TEXT,
    action_type TEXT,    
    bill_amount NUMERIC,
    account_balance NUMERIC,
    user_barcode TEXT,
    last_name TEXT
) 
AS
$$
SELECT
    to_char(faa.transaction_date, 'YYYY-MM-DD') AS action_date,
    faa.type_action AS action_type,
    faa.transaction_amount AS bill_amount,
    faa.account_balance AS account_balance,
    ug2.barcode AS user_barcode,
    ug2.user_last_name AS last_name
FROM (
    SELECT DISTINCT ON (account_id)
        account_id, transaction_date, type_action, transaction_amount,
        account_balance, user_id, fine_status
    FROM folio_derived.feesfines_accounts_actions
    WHERE fine_status = 'Open'
        AND type_action = 'Papercut'
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
        id
    FROM folio_feesfines.accounts__t
    ORDER BY id
) ffa ON faa.account_id = ffa.id
ORDER BY faa.transaction_date DESC;
$$
LANGUAGE SQL STABLE;
