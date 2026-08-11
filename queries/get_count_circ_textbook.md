# List of textbooks in call number order with all patron group circs and their counts

## Purpose
The report shows the counts of circs of textbooks by the patron group.

## Parameters

|Parameter|Position|Type|Default value|Sample input|
|---|---|---|---|---|
|param_user_group|1|TEXT|''|A patron group, e.g. staff|

## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
| barcode | TEXT | The barcode of the textbook | 39151001598784 |
| title | TEXT | The title of the textbook| How to take smart notes |
| call_number | TEXT | The call number of the textbook | F1RST EDUC MON 1995 |
| undergrad_circs | INTEGER | Number of times book was circulated during specified time period | 3 |
| graduate_circs | INTEGER | Number of times book was circulated during specified time period | 1 |
| staff_circs | INTEGER | Number of times book was circulated during specified time period | 0 |
| ill_circs | INTEGER | Number of times book was circulated during specified time period | 5 |
| faculty_circs | INTEGER | Number of times book was circulated during specified time period | 0 |
| loan_count | INTEGER | Number of times book was circulated during specified time period | 0 |
