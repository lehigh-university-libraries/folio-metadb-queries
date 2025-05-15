# List expired users with loans

## Purpose
This report shows a list of expired users who still have outstanding loans.  We include loan details so we can work to recover the materials.

## Parameters

## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
| expire_date| DATE| Date the patron is expired | 2025-06-28T00:00:00 |
| last_name | TEXT| Patron last name | Tester|
| user_barcode | TEXT | Patron barcode | 800000000 |
| user_email | TEXT | Patron email | amx000@lehigh.edu |
| patron_group_name | TEXT | The name of the patron group(s) | faculty |
| loan_due_date |DATE| Date the loan was due| 2025-06-28T00:00:00 |
| item_barcode| TEXT| The barcode assigned to the item | 39151010192645 |
| call_number|TEXT|Effective call number of the item|818.5 Z77p |
| title | TEXT | Book title | The pigman; a novel.|
| loan_policy_name |TEXT| Loan policy name|365 Day Loan|
| status_date | DATE | Date the item status changed | 2025-03-28T00:00:00|
| status_name | TEXT | The status of the item | Checked out |
