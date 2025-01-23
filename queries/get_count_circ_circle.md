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
| barcode | INTEGER | The barcode assigned to the book | 39151010192645 |
| contributor | TEXT | Author name if available | Baldwin, James, 1924-1987 |
| title | TEXT | Book title | The price of the ticket : collected nonfiction: 1948-1985 / James Baldwin. |
| publication_date | TEXT | The date of publication | 1985 |
| item_status | TEXT | The status of the item | Available |
| folio_circ_count | INTEGER | The number of times book was loaned | 2 |
| patron_group | TEXT | The name of the patron group(s) | staff, faculty |
| instance_hrid | INTEGER | FOLIO instance hrid | 00011881114 |
