with fund_group as (
	select fund__t.id as fund_id, fund__t.code as fund_code, groups__t.code as group_code, groups__t.name as group_name
	from folio_finance.fund__t fund__t
	left join folio_finance.group_fund_fiscal_year__t gffy__t on gffy__t.fund_id = fund__t.id 
	left join folio_finance.groups__t groups__t on gffy__t.group_id = groups__t.id
),
material_fund as (
	select fund_code, group_code, group_name from fund_group
	where group_code like 'ALL-%'
),
college_fund as (
	select fund_code, group_code, group_name from fund_group
	where group_code like 'C-%'
)
select budget__t.name as budget_name,
budget__t.allocation_to, budget__t.initial_allocation, budget__t.expenditures, budget__t.encumbered,
fund__t.code as fund_code,
material_fund.group_code as material_group_code,
material_fund.group_name as material_group_name,
college_fund.group_code as college_group_code,
college_fund.group_name as college_group_name,
fy__t.code as fiscal_year_code
from folio_finance.budget__t budget__t
join folio_finance.fund__t fund__t on budget__t.fund_id = fund__t.id
join folio_finance.fiscal_year__t fy__t on budget__t.fiscal_year_id = fy__t.id 
join material_fund on fund__t.code = material_fund.fund_code
join college_fund on fund__t.code = college_fund.fund_code
