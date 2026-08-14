# List to show circle collection items added within a given time period. This is based on the creation of the holdings record.

## Purpose
The report gives a list of items that were added to the CIRCLE collection during a given time period.

## Parameters

|Parameter|Position|Type|Default value|Sample input|
|---|---|---|---|---|
|param_loans_items|1|TEXT|''|Start date and end date, e.g. 2024-01-01 to 2025-01-01|

## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
| date_added | TIMESTAMPTZ | The date the holdings record for the CIRCLE item was created |  |
| item_barcode | TEXT | The barcode on the item. |  |
| title | TEXT | Title | The price of the ticket : collected nonfiction: 1948-1985 / James Baldwin. |
| author | TEXT | The author of the publication | 1 |
| item_status | TEXT | The status of the item | Available |
