DROP FUNCTION IF EXISTS get_circulation_counts_with_service_points;

CREATE FUNCTION get_circulation_counts_with_service_points(
    start_date DATE DEFAULT NULL,
    end_date   DATE DEFAULT NULL
)
RETURNS TABLE (
    month_start        DATE,
    service_point_name TEXT,
    action_type        TEXT,
    ct                 INTEGER
)
LANGUAGE SQL
AS $$
WITH checkout_actions AS (
    SELECT
        li.checkout_service_point_name,
        date_trunc('month', li.loan_date)::date,
        'Checkout',
        COUNT(li.loan_id)
    FROM folio_derived.loans_items AS li
    WHERE
        (start_date IS NULL OR li.loan_date >= start_date)
        AND (end_date   IS NULL OR li.loan_date <  end_date)
        AND li.checkout_service_point_name <> 'Digital Media Studio'
    GROUP BY 1, 2
),

simple_return_dates AS (
    SELECT
        li.checkin_service_point_name,
        COALESCE(
            (li.system_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York',
            (li.loan_return_date   AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York'
        ),
        'Checkin',
        li.loan_id
    FROM folio_derived.loans_items AS li
    WHERE li.checkin_service_point_name <> 'Digital Media Studio'
),

checkin_actions AS (
    SELECT
        srd.checkin_service_point_name,
        date_trunc('month', srd.coalesce)::date,
        srd."?column?",
        COUNT(srd.loan_id)
    FROM simple_return_



