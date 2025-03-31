# List expired users with loans

## Purpose
This report shows a list of expired users who still have outstanding loans.  We include loan details so we can work to recover the materials.

## Parameters

## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
| call_number|TEXT|Effective call number of the item|818.5 Z77p |
| expire_date| DATE| Date the patron is expired | 2025-06-28T00:00:00 |
| item_barcode| TEXT| The barcode assigned to the item | 39151010192645 |
| last_name | TEXT| Patron last name | Canney|
| loan_due_date |DATE| Date the loan was due| 2025-06-28T00:00:00 |
| loan_policy_name |TEXT| Loan policy name|365 Day Loan|
| patron_group_name | TEXT | The name of the patron group(s) | faculty |
| status_date | DATE | Date the item status changed | 2025-03-28T00:00:00|
| status_name | TEXT | The status of the item | Checked out |
| title | TEXT | Book title | The pigman; a novel.|


