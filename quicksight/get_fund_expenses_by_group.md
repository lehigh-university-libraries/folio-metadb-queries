# Categorize FOLIO fund expenses by fund group

## Purpose
The dataset reports expenses by fund code, grouped by college and material type.

## Scope & Limitations

| Dimension | Scope / Limitations | 
| --- | --- | 
| Fiscal year | Only fiscal years since FY2025, when the current fund codes were first used. |
| College | Only funds assigned to a particular college group | 
| Material | Only funds assigned to a particular material group |
| Policies | Limitations like allowable encumbrance and allowable expenditure are not considered. |

## Data Sources

FOLIO, via MetaDB.
## Definitions

|Term|Definition|Source|
|---|---|---|
| Fund | In FOLIO, a fund is "A fiscal entity used to track transactions against a general purpose or function within a ledger. Funds are associated with only one ledger. Fund information persists from year to year as new budgets are created for the fund each year." | [FOLIO Documentation > Finance](https://docs.folio.org/docs/acquisitions/finance/) |
| Group / Fund group | A collection of one or more funds grouped together. | ^ |
| Budget (for a fund) | A finance record that describes the amount of money available for a fiscal year within a fund that includes a definition of the allowed expenditure percentage and allowed encumbrance percentage. Transfer and allocation transactions are performed against a budget. Expense classes can be assigned to a budget. | ^ |
| Initial allocation | The amount of the first allocation made to the budget. | [FOLIO Documentation > Finance > Viewing budget details](https://docs.folio.org/docs/acquisitions/finance/#viewing-budget-details) | 
| Increase in allocation | The sum of all allocation transaction amounts, not including the initial allocations, made **to** the budget. | ^ |
| Decrease in allocation | The sum of all allocation transaction amounts, not including the initial allocations, made **from** the budget. | ^ |
| Total allocated | The sum of all allocated amounts for the budget (initial allocation plus increase in allocation minus decrease in allocation). | ^ |
| Net transfers | Total net transfer amount for the budget.  Note: these are net transfers against the Total allocated amount, resulting in the Total funding amount. | ^ |
| Total funding | The **Total allocated** amount plus the **Net transfers** amount. | ^ |
| Encumbered | The sum of all encumbrance transaction amounts against the budget. | ^ |
| Awaiting payment | The sum of pending payment transaction amounts against the budget. | ^ |
| Expended | The sum of payment transaction amounts against the budget. | ^ |
| Credited | The sum of credit transaction amounts against the budget. | ^ |
| Unavailable | The total amount unavailable for the budget, calculated as the sum of the **encumbered**, **awaiting payment**, and **expended** amounts, minus the **credited** amount. | ^, but the docs are incorrect (they miss the credited piece). |
| Available balance | Total amount available for the budget, calculated as **Total funding** amount minus the **Unavailable** amount. | ^ |
| Cash balance | The **Total funding** amount minus the **Expended** amount. | ^ |

## Output table

| Attribute | Type | Source | Description | Sample output |
| --- | --- | --- | --- | --- |
| budget_name | Text | FOLIO | Name of the FOLIO Budget. Incorporates the Banner budget prefix, the department name, the material type, and the fiscal year. | 75070 CHEM-J-FY2025 |  |
| initial_allocation | Numeric | FOLIO | Initial allocation (defined above) | 500 | 
| allocation_to | Numeric | FOLIO | Increase in allocation (defined above) | 234736 |
| allocation_from | Numeric | FOLIO | Decrease in allocation (defined above) | 0 |
| total_allocated | Numeric | Calculation | Total allocated (defined above) | 235236
| net_transfers | Numeric | FOLIO | Net transfers (defined above) | 0 |
| total_funding | Numeric | Calculation | Total funding (defined above) | 235236 |
| expenditures | Numeric | FOLIO | Expended (defined above) | 167647 |
| encumbered | Numeric | FOLIO | Encumbered (defined above) | 0 |
| awaiting_payment | Numeric | FOLIO | Awaiting payment (defined above) | 0 |
| credits | Numeric | FOLIO | Credited (defined above) | 0 |
| unavailable | Numeric | Calculation | Unavailable (defined above) | 67589 |
| available_balance | Numeric | Calculation | Available balance (defined above) | 167647 |
| cash_balance | Numeric | Calculation | Cash balance (defined above) | 167647 |
| fund_code | Text | FOLIO | Code representing a FOLIO fund.  At Lehigh, this includes its Banner prefix, subject and material type.   | 75070 CHEM-J | 
| material_group_code | Text | FOLIO | Code for a fund group that includes all funds for purchases of a specific type: Books (ALL-B), Journals (ALL-J) or Databases (ALL-D). | ALL-J |
| material_group_name | Text | FOLIO | Human readable version of the material_group_code | All Journals |
| college_group_code | Text | FOLIO | Code for a fund group that includes all funds for purchases specific to a single Lehigh college. | C-AS |
| college_group_name | Text | FOLIO | Human readable version of the college_group_code | College of Arts & Sciences |
| fiscal_year_code | Text | FOLIO | Code representing a fiscal year | FY2025 |
