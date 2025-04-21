--metadb:function get_overdue_loans_with_patron
DROP FUNCTION IF EXISTS get_overdue_loans_with_patron;

CREATE FUNCTION get_overdue_loans_with_patron ()
    RETURNS TABLE (
        due_date date,
        item_effective_call_number text item_title text item_tstatus text location_effective text patron_group_name text patron_last_name text,
        patron_barcode text,
        patron_email text,
    )
    AS $$
    SELECT
        CAST(li.loan_due_date AS date) AS due_date,
        ihi.barcode AS item_barcode,
        ie.effective_call_number AS item_effective_call_number,
        ihi.title AS item_title,
        li.item_status AS item_tstatus,
        ie.effective_location_name AS location_effective,
        li.patron_group_name,
        ug.user_last_name AS patron_last_name,
        ug.barcode AS patron_barcode,
        ug.user_email AS patron_email
    FROM
        folio_derived.items_holdings_instances ihi
        JOIN folio_derived.item_ext ie ON ie.item_id = ihi.item_id
        JOIN folio_derived.loans_items li ON ihi.item_id = li.item_id
        JOIN folio_derived.locations_libraries ll ON ll.location_id = ie.effective_location_id
        JOIN folio_derived.users_groups ug ON li.user_id = ug.user_id
    WHERE
        li.loan_status = 'Open'
        AND li.loan_due_date < CURRENT_DATE
        AND li.patron_group_name NOT IN ('ill', 'palciuser', 'libraryuse')
        AND ie.discovery_suppress = 'False'
    ORDER BY
        ie.effective_call_number;
$$
LANGUAGE SQL;
