# List items with circulation counts and patron groups

## Purpose
This report shows a list of items that have circulated with counts of loans and renewals (excluding circulation for ILL). We include patron groups.

## Parameters

## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
| item_barcode| TEXT| The barcode assigned to the item | 39151010192645 |
| call_number|TEXT|Effective call number of the item|818.5 Z77p |
| title | TEXT | Book title | The pigman; a novel.|
| patron_group | TEXT | The name of the patron group(s) | faculty |
| loan_count | INTEGER | The count of loans | 1 |
| renewal_count | INTEGER | The count of renewals | 1 |
