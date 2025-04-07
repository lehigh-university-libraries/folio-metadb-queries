--metadb:function get_graduating_patrons_with_loans
-- This function retrieves all loans associated with a graduating patron.
CREATE FUNCTION get_graduating_patrons_with_loans()

RETURNS TABLE
(
    graduating_note_date DATE,
    patron_barcode TEXT,
    patron_last_name TEXT,
    patron_email TEXT,
    patron_group TEXT,
    item_barcode TEXT,
    item_call_number TEXT,
    item_title TEXT,
    loan_status TEXT,
    loan_due_date DATE,
    loan_policy_name TEXT
) 
AS
$$
select cast (fug.updated_date as DATE) as graduating_note_date, 
fug.barcode as patron_barcode, 
fug.user_last_name as patron_last_name, 
LEFT(fug.user_email, 6) AS patron_email,
fug.group_name as patron_group,
ie.barcode as item_barcode, 
ie.effective_call_number as item_call_number, 
ihi.title as item_title, 
ie.status_name as loan_status,  
cast(li.loan_due_date as DATE) as loan_due_date, 
li.loan_policy_name
FROM folio_derived.loans_items li
JOIN folio_derived.item_ext ie 
    on li.item_id = ie.item_id
JOIN folio_derived.items_holdings_instances ihi 
    on li.item_id = ihi.item_id
JOIN folio_derived.users_groups fug 
    on li.user_id = fug.user_id
join folio_notes.link fnl
	on fnl.object_id = fug.user_id 
join folio_notes.note_link fnnl
	on fnnl.link_id = fnl.id
join folio_notes.note fnn
	on fnn.id = fnnl.note_id
join folio_notes.type__ t 
	on t.id = fnn.type_id  
where fug.active ='true' 
and fnl.object_type = 'user'
and t.name = 'graduating'
and li.loan_status = 'Open' 
and fnn.content = 'true'
order by patron_last_name;
$$
LANGUAGE SQL STABLE;
