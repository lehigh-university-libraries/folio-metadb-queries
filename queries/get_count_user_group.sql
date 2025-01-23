--metadb:function get_count_user_group

DROP FUNCTION IF EXISTS get_count_user_group;

CREATE FUNCTION get_count_user_group(
    param_user_group TEXT DEFAULT ''
)
RETURNS TABLE (
    group_id          TEXT,
    group_description TEXT,
    group_name        TEXT,
    count_by_group    INTEGER    
)
AS 
$$
SELECT  
    users__t.patron_group :: TEXT,
    groups__t.DESC        :: TEXT,
    groups__t.group       :: TEXT,
    COUNT(users__t.id)    :: INTEGER
FROM
    folio_users.users__t  
    LEFT JOIN folio_users.groups__t ON groups__t.id = users__t.patron_group
WHERE 
    ((groups__t.group = param_user_group) OR (param_user_group = ''))
GROUP BY 
    users__t.patron_group,
    groups__t.desc,
    groups__t.group
$$
LANGUAGE SQL;