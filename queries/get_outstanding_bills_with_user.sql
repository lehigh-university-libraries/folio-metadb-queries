--metadb:function get_outstanding_bills_with_user
-- This function retrieves all outstanding bills for a given user.
--metadb:function get_outstanding_bills_with_user
DROP FUNCTION IF EXISTS get_outstanding_bills_with_user;
CREATE FUNCTION get_outstanding_bills_with_user()
RETURNS TABLE
(
    action_date TEXT,
    action_type TEXT,    
    bill_amount NUMERIC,
    account_balance NUMERIC,
    user_barcode TEXT,
    last_name TEXT,
    item_title TEXT,
    item_call_number TEXT,
    item_barcode TEXT
) 
AS
$$
SELECT
    LEFT(faa.transaction_date, 10) AS action_date,
    faa.type_action AS action_type,
    faa.transaction_amount AS bill_amount,
    faa.account_balance AS account_balance,
    ug2.barcode AS user_barcode,
    ug2.user_last_name AS last_name,
    ffa.title AS item_title,
    ffa.call_number AS item_call_number,
    ffa.barcode AS item_barcode
FROM (
    SELECT DISTINCT ON (account_id)
        account_id, transaction_date, type_action, transaction_amount,
        account_balance, user_id, fine_status
    FROM folio_derived.feesfines_accounts_actions
    WHERE fine_status = 'Open'
        AND type_action NOT LIKE 'Papercut%'
        AND type_action NOT LIKE 'Paid fully%'
        AND type_action NOT LIKE 'Cancelled%'
        AND type_action NOT LIKE 'Refunded%'
        AND type_action NOT LIKE 'Credited%'
        AND type_action NOT LIKE 'Waived%'
    ORDER BY account_id, transaction_date ASC
) faa
JOIN (
    SELECT DISTINCT ON (user_id)
        user_id, barcode, user_last_name
    FROM folio_derived.users_groups
    ORDER BY user_id
) ug2 ON faa.user_id = ug2.user_id
JOIN (
    SELECT DISTINCT ON (id)
        id, title, call_number, barcode
    FROM folio_feesfines.accounts__t
    ORDER BY id
) ffa ON faa.account_id = ffa.id
ORDER BY faa.transaction_date ASC;
$$
LANGUAGE SQL STABLE;
