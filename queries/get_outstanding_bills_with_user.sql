--metadb:function get_outstanding_bills_with_user
-- This function retrieves all outstanding bills for a given user.
CREATE FUNCTION get_outstanding_bills_with_user()

RETURNS TABLE
(
    bill_amount INTEGER,
    bill_remaining INTEGER,
    bill_type TEXT,
    item_barcode TEXT,
    item_call_number TEXT,
    item_title TEXT,
    item_due_date DATE,
    item_location TEXT,
    user_barcode TEXT,
    username TEXT,
    user_last_name TEXT  
) 
AS
$$
SELECT at2.amount as bill_amount,
at2.remaining as bill_remaining,
at2.fee_fine_type as bill_type, 
at2.barcode as item_barcode,
at2.call_number as item_call_number,
at2.title as item_title,
cast (at2.due_date as DATE) as item_due_date,
at2.location as item_location,
ug2.barcode as user_barcode,
ug2.username AS username,
ug2.user_last_name AS user_last_name
from folio_feesfines.accounts__t__ at2 
inner join folio_derived.users_groups ug2 on at2.user_id = ug2.user_id
where at2.remaining >= '1' 
order by at2.fee_fine_type desc;
$$
LANGUAGE SQL STABLE;
