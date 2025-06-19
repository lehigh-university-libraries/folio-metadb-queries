-- metadb:function get_circulation_counts_with_service_points
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
/*──────────────────────── CTE #1 ─ Check‑outs ───────────────────────*/
WITH checkout_actions AS (
    SELECT
        li.checkout_service_point_name            AS service_point_name,
        date_trunc('month', li.loan_date)::date   AS month_start,   -- DATE ✔
        'Checkout'                                AS action_type,
        COUNT(li.loan_id)                         AS ct
    FROM folio_derived.loans_items AS li
    WHERE
        (start_date IS NULL OR li.loan_date >= start_date)
        AND (end_date   IS NULL OR li.loan_date <  end_date)
        AND li.checkout_service_point_name <> 'Digital Media Studio'
    GROUP BY 1, 2
),

/*──────────────────────── CTE #2 ─ Raw return events (Eastern) ─────*/
simple_return_dates AS (
    SELECT
        li.checkin_service_point_name AS service_point_name,
        /* 1. declare value is UTC, 2. convert to America/New_York  */
        COALESCE(
            (li.system_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York',
            (li.loan_return_date   AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York'
        )                                         AS action_date,
        'Checkin'                                AS action_type,
        li.loan_id
    FROM folio_derived.loans_items AS li
    WHERE li.checkin_service_point_name <> 'Digital Media Studio'
),

/*──────────────────────── CTE #3 ─ Monthly check‑ins ───────────────*/
checkin_actions AS (
    SELECT
        srd.service_point_name,
        date_trunc('month', srd.action_date)::date AS month_start,  -- DATE ✔
        srd.action_type,
        COUNT(srd.loan_id)                         AS ct
    FROM simple_return_dates AS srd
    WHERE
        (start_date IS NULL OR srd.action_date >= start_date)
        AND (end_date   IS NULL OR srd.action_date <  end_date)
    GROUP BY 1, 2, 3
)

/*─────────────── Final UNION; enforce DATE one more time ───────────*/
SELECT
    combined.month_start::date                    AS month_start,   -- belt‑and‑suspenders cast
    combined.service_point_name,
    combined.action_type,
    combined.ct
FROM (
    SELECT * FROM checkout_actions
    UNION ALL
    SELECT * FROM checkin_actions
) AS combined
ORDER BY
    combined.month_start,
    combined.service_point_name,
    combined.action_type;
$$
LANGUAGE SQL;


