-- get_funds_without_group
-- Get a list of active funds with no assigned material group, or no assigned college group
with fund_group as (
    select fund__t.id as fund_id,
        fund__t.code as fund_code,
        groups__t.code as group_code,
        groups__t.name as group_name
    from folio_finance.fund__t fund__t
        left join folio_finance.group_fund_fiscal_year__t gffy__t on gffy__t.fund_id = fund__t.id
        left join folio_finance.groups__t groups__t on gffy__t.group_id = groups__t.id
),
material_fund as (
    select fund_code,
        group_code,
        group_name
    from fund_group
    where group_code like 'ALL-%'
),
college_fund as (
    select fund_code,
        group_code,
        group_name
    from fund_group
    where group_code like 'C-%'
)
select ledger__t.name as ledger_name,
    fund__t.code as fund_code,
    fund__t.name as fund_name,
    material_fund.group_name as material_group_name,
    college_fund.group_name as college_group_name
from folio_finance.fund__t fund__t
    left join material_fund on fund__t.code = material_fund.fund_code
    left join college_fund on fund__t.code = college_fund.fund_code
    join folio_finance.ledger__t ledger__t on fund__t.ledger_id = ledger__t.id
where fund__t.fund_status = 'Active'
    and (
        material_fund.group_name is null
        or college_fund.group_name is null
    )
order by ledger_name,
    fund_code
