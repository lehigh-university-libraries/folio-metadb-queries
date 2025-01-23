# List to count users by patron group

## Purpose
The report shows the counts of users grouped by the patron group.

## Parameters

|Parameter|Position|Type|Default value|Sample input|
|---|---|---|---|---|
|param_user_group|1|TEXT|''|A patron group, e.g. staff|

## Output table

| Attribute | Type | Description | Sample output |
| --- | --- | --- | --- |
| group_id | TEXT | The UUID of the patron group | 3684a786-6671-4268-8ed0-9db82ebca60b |
| group_description | TEXT | The description of the patron group| Staff Member |
| group_name | TEXT | The name of the patron group | staff |
| count_by_group | INTEGER | The count of users in the group | 123 |