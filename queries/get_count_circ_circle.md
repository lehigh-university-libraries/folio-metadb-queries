# List to count circulation of CIRCLE collection

## Purpose
The report shows the circulation of books in the CIRCLE collection.

## Parameters

|Parameter|Position|Type|Default value|Sample input|
|---|---|---|---|---|
|param_user_group|1|TEXT|''|Start date and end date, e.g. 2024-01-01 to 2025-01-01|

## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
| barcode | TEXT | The barcode assigned to the book | 39151010192645 |
| publication_date | TEXT | The of publication | date |
| patron_group | TEXT | The name of the patron group(s) | staff, faculty |
| instance_hrid | INTEGER | FOLIO instance hrid | 1234567 |
