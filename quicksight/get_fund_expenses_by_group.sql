--metadb:function get_fund_expenses_by_group

CREATE OR REPLACE FUNCTION get_fund_expenses_by_group()
RETURNS TABLE (
    budget_name TEXT,
    initial_allocation NUMERIC,
    allocation_to NUMERIC,
    allocation_from NUMERIC,
    total_allocated NUMERIC,
    net_transfers NUMERIC,
    total_funding NUMERIC,
    expenditures NUMERIC,
    encumbered NUMERIC,
    awaiting_payment NUMERIC,
    credits NUMERIC,
    unavailable NUMERIC,
    available_balance NUMERIC,
    cash_balance NUMERIC,
    fund_code TEXT,
    material_group_code TEXT,
    material_group_name TEXT,
    college_group_code TEXT,
    college_group_name TEXT,
    fiscal_year_code TEXT
)
AS
$$
WITH fund_group AS (
  SELECT fund__t.id AS fund_id, fund__t.code AS fund_code, groups__t.code AS group_code, groups__t.name AS group_name
  from folio_finance.fund__t fund__t
  LEFT JOIN folio_finance.group_fund_fiscal_year__t gffy__t ON gffy__t.fund_id = fund__t.id
  LEFT JOIN folio_finance.groups__t groups__t ON gffy__t.group_id = groups__t.id
),
material_fund AS (
  SELECT fund_code, group_code, group_name from fund_group
  WHERE group_code LIKE 'ALL-%'
),
college_fund AS (
  SELECT fund_code, group_code, group_name from fund_group
  WHERE group_code like 'C-%'
)
SELECT budget__t.name AS budget_name,
  budget__t.initial_allocation,
  budget__t.allocation_to,
  budget__t.allocation_from,
  (budget__t.initial_allocation + budget__t.allocation_to - budget__t.allocation_from) AS total_allocated,
  budget__t.net_transfers,
  (budget__t.initial_allocation + budget__t.allocation_to - budget__t.allocation_from) + budget__t.net_transfers AS total_funding,
  budget__t.expenditures,
  budget__t.encumbered,
  budget__t.awaiting_payment,
  budget__t.credits,
  budget__t.expenditures + budget__t.encumbered + budget__t.awaiting_payment - budget__t.credits AS unavailable,
  ((budget__t.initial_allocation + budget__t.allocation_to - budget__t.allocation_from) + budget__t.net_transfers) - (budget__t.expenditures +
  budget__t.encumbered + budget__t.awaiting_payment - budget__t.credits) AS available_balance,
  ((budget__t.initial_allocation + budget__t.allocation_to - budget__t.allocation_from) + budget__t.net_transfers) - budget__t.expenditures as
  cash_balance,
  fund__t.code AS fund_code,
  material_fund.group_code AS material_group_code,
  material_fund.group_name AS material_group_name,
  college_fund.group_code AS college_group_code,
  college_fund.group_name AS college_group_name,
  fy__t.code AS fiscal_year_code
FROM folio_finance.budget__t budget__t
JOIN folio_finance.fund__t fund__t ON budget__t.fund_id = fund__t.id
JOIN folio_finance.fiscal_year__t fy__t ON budget__t.fiscal_year_id = fy__t.id
JOIN material_fund ON fund__t.code = material_fund.fund_code
JOIN college_fund ON fund__t.code = college_fund.fund_code;
$$
LANGUAGE sql;
