# List to show all print journal in Linderman

## Purpose
The report is to show all print journals held in Linderman along with information about currency, retention, holdings statements, binding information and other contextual info to help maintain the collection.

## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
| instance_id | TEXT | The instance UUID of the journal | 36eb0db9-7456-482f-bbc3-384c79702517 |
| instance_hrid | TEXT | The instance HRID of the journal | 298161 |
| title | TEXT | Journal title | Architecture intérieure-Créé. |
| item_material_type | TEXT | The date of publication | journal|
| item_status | TEXT | The status of the item | Available |
| linderman_reading_room_location | TEXT | The number of times book was loaned | Linderman 1st Floor - Reading Room - Current Periodicals |
| linderman_reading_room_statement | TEXT | Number of years kept in Current Periodicals | Latest 3 years kept in Current Periodicals. |
| linderman_reading_room_receipt_status | TEXT | Do we currently receive this journal, initials, year and month that was last determined | Currently received (LM 10-25) |
| linderman_reading_room_bindery_note | TEXT | FOLIO instance hrid | should be blank for current periodicals |
| linderman_reading_room_binding_frequency_note | TEXT | FOLIO instance hrid | should be blank for current periodicals |
| linderman_reading_room_journal_publication_frequency_note | TEXT| FOLIO instance hrid | should be blank for current periodicals |
| linderman_lower_level_location | TEXT | Shelving location of bound journals | Linderman Ground Floor - Lower Level |
| linderman_lower_level_statement | TEXT | Full holdings statement | 1-20,22- (1955-) |
| linderman_lower_level_receipt_status | TEXT | FOLIO instance hrid | should be blank for bound periodicals |
| linderman_lower_level_bindery_note | TEXT | Do we bind?, initials, year and month that was last determined | Currently bound (RAB 10-25) |
| linderman_lower_level_binding_frequency_note | TEXT | How many issues typically get bound together | 6 issues per volume |
| linderman_lower_level_journal_publication_frequency_note | TEXT | How many issues typcially are issue per year?| 3 issues per year |
