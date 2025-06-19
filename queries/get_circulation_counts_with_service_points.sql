DROP FUNCTION IF EXISTS get_circulation_counts_with_service_points;

CREATE OR REPLACE FUNCTION get_circulation_counts_with_service_points(
    start_date DATE DEFAULT NULL,
    end_date   DATE DEFAULT NULL
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
    /* ------------- main query ------------- */
    RETURN QUERY
    WITH
    checkout_actions AS (       -- monthly check‑outs
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

    simple_return_dates AS (    -- raw return events in Eastern Time
        SELECT
            li.checkin_service_point_name                  AS service_point_name,
            COALESCE(
                (li.system_return_date AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York',
                (li.loan_return_date   AT TIME ZONE 'UTC') AT TIME ZONE 'America/New_York'
            )                                             AS action_date,
            'Checkin'                                     AS action_type,
            li.loan_id
        FROM folio_derived.loans_items li
        WHERE li.checkin_service_point_name <> 'Digital Media Studio'
    ),

    checkin_actions AS (        -- monthly check‑ins
        SELECT
            srd.service_point_name,
            date_trunc('month', srd.action_date)::date     AS month_start,
            srd.action_type,
            COUNT(srd.loan_id)::INTEGER                    AS ct
        FROM simple_return_dates srd
        WHERE
            (start_date IS NULL OR srd.action_date >= start_date)
            AND (end_date   IS NULL OR srd.action_date <  end_date)
        GROUP BY 1, 2, 3
    )

    /* ------------- union & order ------------- */
    SELECT month_start, service_point_name, action_type, ct
    FROM   checkout_actions

    UNION ALL

    SELECT month_start, service_point_name, action_type, ct
    FROM   checkin_actions

    ORDER BY month_start, service_point_name, action_type;
END;
$$;






