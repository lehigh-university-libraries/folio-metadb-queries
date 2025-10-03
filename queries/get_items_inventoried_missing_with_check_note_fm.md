# List to track missing items

## Purpose
The report lists all of the items that were marked "missing" during inventory. The report displays a column for notes if the note type name is 'Workflow-Missing Searched'.
Staff can export this into a CSV file, and use the barcodes for bulk edit to either check in books that were found in bulk, or create a note with the note type 'Workflow-Missing Search' 
to keep track of how often and when and who searched for the missing book.


## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
| barcode | TEXT | The barcode assigned to the book | 39151010192645 |
| item_call_number | TEXT | The item effective call number | 001.5 B927c |
| title | TEXT | Book title | Mutational analysis |
| missing_searched_note | TEXT | Note of item if note_type is 'Workflow-Missing Searched' | Checked 20250714 by LM in Lind|
