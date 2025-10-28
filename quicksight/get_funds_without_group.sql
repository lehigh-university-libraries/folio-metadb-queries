--metadb:function get_funds_without_group
-- Get a list of active funds on active ledgers, with no assigned material group, or no assigned college group
CREATE OR REPLACE FUNCTION get_funds_without_group()
RETURNS TABLE (
    ledger_name TEXT,
    fund_code TEXT,
    fund_name TEXT,
    material_group_name TEXT,
    college_group_name TEXT
)
AS
$$
WITH fund_group AS (
    SELECT fund__t.id AS fund_id,
        fund__t.code AS fund_code,
        groups__t.code AS group_code,
        groups__t.name AS group_name
    FROM folio_finance.fund__t fund__t
        LEFT JOIN folio_finance.group_fund_fiscal_year__t gffy__t ON gffy__t.fund_id = fund__t.id
        LEFT JOIN folio_finance.groups__t groups__t ON gffy__t.group_id = groups__t.id
),
material_fund AS (
    SELECT fund_code,
        group_code,
        group_name
    FROM fund_group
    WHERE group_code like 'ALL-%'
),
college_fund AS (
    SELECT fund_code,
        group_code,
        group_name
    FROM fund_group
    WHERE group_code like 'C-%'
)
SELECT ledger__t.name AS ledger_name,
    fund__t.code AS fund_code,
    fund__t.name AS fund_name,
    material_fund.group_name AS material_group_name,
    college_fund.group_name AS college_group_name
FROM folio_finance.fund__t fund__t
    LEFT JOIN material_fund ON fund__t.code = material_fund.fund_code
    LEFT JOIN college_fund ON fund__t.code = college_fund.fund_code
    JOIN folio_finance.ledger__t ledger__t ON fund__t.ledger_id = ledger__t.id
WHERE fund__t.fund_status = 'Active'
    AND (
        material_fund.group_name IS NULL
        OR college_fund.group_name IS NULL
    )
ORDER BY ledger_name,
    fund_code;
$$
LANGUAGE sql;
