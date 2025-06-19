DROP FUNCTION IF EXISTS get_circulation_counts_with_service_points;

CREATE FUNCTION get_circulation_counts_with_service_points (start_date date DEFAULT NULL, end_date date DEFAULT NULL)
    RETURNS TABLE (
        month_start date,
        service_point_name text,
        action_type text,
        ct integer)
    LANGUAGE SQL
    AS $$
    WITH checkout_actions AS (
        SELECT
            li.checkout_service_point_name,
            date_trunc('month', li.loan_date)::date,
            'Checkout',
            COUNT(li.loan_id)
        FROM
            folio_derived.loans_items AS li
        WHERE (start_date IS NULL
            OR li.loan_date >= start_date)
        AND (end_date IS NULL
            OR li.loan_date < end_date)
        AND li.checkout_service_point_name <> 'Digital Media Studio'
    GROUP BY
        1,
        2
),
simple_return_dates AS (
    SELECT
        li.checkin_service_point_name,
        COALESCE((li.system_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York', (li.loan_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York'),
        'Checkin',
        li.loan_id
    FROM
        folio_derived.loans_items AS li
    WHERE
        li.checkin_service_point_name <> 'Digital Media Studio'
),
checkin_actions AS (
    SELECT
        srd.checkin_service_point_name,
        date_trunc('month', srd.coalesce)::date,
    srd."?column?",
    COUNT(srd.loan_id)
FROM
    simple_return_dates AS srd
    WHERE (start_date IS NULL
        OR srd.coalesce >= start_date)
    AND (end_date IS NULL
        OR srd.coalesce < end_date)
GROUP BY
    1,
    2,
    3
)
SELECT
    * -- column names are inherited from RETURNS TABLE clause
FROM (
    SELECT
        date_trunc('month', li.loan_date)::date,
        li.checkout_service_point_name,
        'Checkout',
        COUNT(li.loan_id)
    FROM
        folio_derived.loans_items li
    WHERE (start_date IS NULL
        OR li.loan_date >= start_date)
    AND (end_date IS NULL
        OR li.loan_date < end_date)
    AND li.checkout_service_point_name <> 'Digital Media Studio'
GROUP BY
    1,
    2
UNION ALL
SELECT
    date_trunc('month', COALESCE((li.system_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York', (li.loan_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York'))::date,
    li.checkin_service_point_name,
    'Checkin',
    COUNT(li.loan_id)
FROM
    folio_derived.loans_items li
WHERE
    li.checkin_service_point_name <> 'Digital Media Studio'
    AND (start_date IS NULL
        OR COALESCE((li.system_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York', (li.loan_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York') >= start_date)
    AND (end_date IS NULL
        OR COALESCE((li.system_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York', (li.loan_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York') < end_date)
GROUP BY
    1,
    2) AS combined
ORDER BY
    1,
    2,
    3;
$$;





