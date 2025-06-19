/* ================================================================
   Function:  get_circulation_counts_with_service_points
   Purpose :  Monthly counts of check‑outs & check‑ins by service
              point, filtered by an optional date window.
   Notes   :  – month_start is a DATE (no time component)
              – check‑in timestamps are converted from UTC to
                America/New_York before roll‑up
================================================================ */

-- 1. Remove any old version
DROP FUNCTION IF EXISTS get_circulation_counts_with_service_points(
    DATE, DATE
);

-- 2. Create (or replace) the function
CREATE OR REPLACE FUNCTION get_circulation_counts_with_service_points(
    start_date DATE DEFAULT NULL,   -- inclusive lower bound
    end_date   DATE DEFAULT NULL    -- exclusive upper bound
)
RETURNS TABLE (
    month_start        DATE,
    service_point_name TEXT,
    action_type        TEXT,
    ct                 INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    /* ==================================================
       CTE 1 – monthly check‑out counts
    ================================================== */
    WITH checkout_actions AS (
        SELECT
            li.checkout_service_point_name                  AS service_point_name,
            date_trunc('month', li.loan_date)::date         AS month_start,
            'Checkout'                                      AS action_type,
            COUNT(li.loan_id)::INTEGER                      AS ct
        FROM folio_derived.loans_items li
        WHERE
              (start_date IS NULL OR li.loan_date >= start_date)
          AND (end_date   IS NULL OR li.loan_date <  end_date)
          AND li.checkout_service_point_name <> 'Digital Media Studio'
        GROUP BY 1, 2
    ),

    /* ==================================================
       CTE 2 – raw check‑in events in Eastern Time
    ================================================== */
    simple_return_dates AS (
        SELECT
            li.checkin_service_point_name                                           AS service_point_name,
            COALESCE(
                (li.system_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York',
                (li.loan_return_date   AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York'
            )                                                                       AS action_date,
            'Checkin'                                                               AS action_type,
            li.loan_id
        FROM folio_derived.loans_items li
        WHERE li.checkin_service_point_name <> 'Digital Media Studio'
    ),

    /* ==================================================
       CTE 3 – monthly check‑in counts
    ================================================== */
    checkin_actions AS (
        SELECT
            srd.service_point_name,
            date_trunc('month', srd.action_date)::date                              AS month_start,
            srd.action_type,
            COUNT(srd.loan_id)::INTEGER                                             AS ct
        FROM simple_return_dates srd
        WHERE
              (start_date IS NULL OR srd.action_date >= start_date)
          AND (end_date   IS NULL OR srd.action_date <  end_date)
        GROUP BY 1, 2, 3
    )

    /* ==================================================
       Final UNION and ordered result
    ================================================== */
    SELECT month_start,
           service_point_name,
           action_type,
           ct
    FROM   checkout_actions

    UNION ALL

    SELECT month_start,
           service_point_name,
           action_type,
           ct
    FROM   checkin_actions

    ORDER BY month_start,
             service_point_name,
             action_type;
END;
$$;







