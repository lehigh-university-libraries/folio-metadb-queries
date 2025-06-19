--metadb:function get_circulation_counts_with_service_points
DROP FUNCTION IF EXISTS get_circulation_counts_with_service_points;
CREATE FUNCTION get_circulation_counts_with_service_points(
    start_date DATE DEFAULT NULL,
    end_date DATE DEFAULT NULL
) 
RETURNS TABLE (
    service_point_name TEXT,
    month_start TEXT,
    action_type TEXT,
    ct INTEGER
) 
AS 
$$
WITH checkout_actions AS (
    SELECT 
        checkout_service_point_name AS service_point_name,
        date_trunc('month', loan_date::date)::date AS month_start,
        'Checkout'::varchar AS action_type,
        count(loan_id) AS ct
    FROM folio_derived.loans_items
    WHERE 
        (start_date IS NULL OR loan_date >= start_date)
        AND (end_date IS NULL OR loan_date < end_date)
        AND checkout_service_point_name != 'Digital Media Studio'
    GROUP BY service_point_name, month_start
),
simple_return_dates AS (
    SELECT 
        checkin_service_point_name AS service_point_name,
        coalesce(
            system_return_date::timestamptz at time zone 'UTC',
            loan_return_date::timestamptz at time zone 'UTC'
        ) AS action_date,
        'Checkin'::varchar AS action_type,
        loan_id
    FROM folio_derived.loans_items
    WHERE checkin_service_point_name != 'Digital Media Studio'
),
checkin_actions AS (
    SELECT 
        service_point_name,
        date_trunc('month', action_date::date)::date AS month_start,
        action_type,
        count(loan_id) AS ct
    FROM simple_return_dates
    WHERE 
        (start_date IS NULL OR action_date >= start_date)
        AND (end_date IS NULL OR action_date < end_date)
    GROUP BY service_point_name, month_start, action_type
)
SELECT 
    service_point_name,
    month_start,
    action_type,
    ct
FROM checkout_actions
UNION ALL
SELECT 
    service_point_name,
    month_start,
    action_type,
    ct
FROM checkin_actions
ORDER BY service_point_name, month_start, action_type;
$$
LANGUAGE SQL;
ORDER BY month_start, service_point_name, action_type;
$$
LANGUAGE SQL;
