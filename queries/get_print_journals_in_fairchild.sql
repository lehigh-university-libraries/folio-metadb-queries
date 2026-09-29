/* metadb:function get_print_journals_in_fairchild
   This function retrieves print journals that are located in Fairchild. */
DROP FUNCTION IF EXISTS get_print_journals_in_fairchild;
CREATE FUNCTION get_print_journals_in_fairchild()
RETURNS TABLE
( 
    instance_id TEXT,
    instance_hrid TEXT,
    title TEXT,
    item_material_type TEXT,
    item_status TEXT,
    fairchild_current_periodicals_location TEXT,
    fairchild_current_periodicals_statement TEXT,
    fairchild_current_periodicals_receipt_status TEXT,
    fairchild_current_periodicals_call_number TEXT,
    fairchild_current_periodicals_bindery_note TEXT,
    fairchild_current_periodicals_binding_frequency_note TEXT,
    fairchild_current_periodicals_journal_publication_frequency_note TEXT,
    fairchild_north_location TEXT,
    fairchild_north_statement TEXT,
    fairchild_north_receipt_status TEXT,
    fairchild_north_call_number TEXT,
    fairchild_north_bindery_note TEXT,
    fairchild_north_binding_frequency_note TEXT,
    fairchild_north_journal_publication_frequency_note TEXT
)
AS
$$
SELECT
    ie.instance_id,
    ie.instance_hrid,
    it2.title,
    ie2.material_type_name AS item_material_type,
    ie2.status_name AS item_status,

         -- Fairchild - 5th Floor - North - Current Periodicals
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North - Current Periodicals' 
            THEN he.permanent_location_name 
        END) AS fairchild_current_periodicals_location,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North - Current Periodicals' 
            THEN hs.holdings_statement 
        END) AS fairchild_current_periodicals_statement,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North - Current Periodicals'
            THEN he.receipt_status 
        END) AS fairchild_current_periodicals_receipt_status,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North - Current Periodicals'
            THEN he.call_number
        END) AS fairchild_current_periodicals_call_number,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North - Current Periodicals'
                 AND hn.note_type_name = 'Bindery'
            THEN hn.note
        END) AS fairchild_current_periodicals_bindery_note,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North - Current Periodicals'
                 AND hn.note_type_name = 'Binding frequency'
            THEN hn.note
        END) AS fairchild_current_periodicals_binding_frequency_note,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North - Current Periodicals'
                 AND hn.note_type_name = 'Journal publication frequency'
            THEN hn.note
        END) AS fairchild_current_periodicals_journal_publication_frequency_note,


    -- Fairchild - 5th Floor - North
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North' 
            THEN he.permanent_location_name 
        END) AS fairchild_north_location,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North' 
            THEN hs.holdings_statement 
        END) AS fairchild_north_statement,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North'
            THEN he.receipt_status 
        END) AS fairchild_north_receipt_status,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North'
            THEN he.call_number
        END) AS fairchild_north_call_number,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North'
                 AND hn.note_type_name = 'Bindery'
            THEN hn.note
        END) AS fairchild_north_bindery_note,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North'
                 AND hn.note_type_name = 'Binding frequency'
            THEN hn.note
        END) AS fairchild_north_binding_frequency_note,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Fairchild - 5th Floor - North'
                 AND hn.note_type_name = 'Journal publication frequency'
            THEN hn.note
        END) AS fairchild_north_journal_publication_frequency_note

FROM folio_inventory.item__t it
JOIN folio_inventory.holdings_record__t hrt
    ON hrt.id = it.holdings_record_id
JOIN folio_inventory.instance__t it2
    ON it2.id = hrt.instance_id
LEFT JOIN folio_derived.item_ext ie2
    ON ie2.item_id = it.id
LEFT JOIN folio_derived.holdings_ext he
    ON he.id = hrt.id
LEFT JOIN folio_inventory.holdings_type__t htt
    ON htt.id = hrt.holdings_type_id
LEFT JOIN folio_derived.holdings_statements hs
    ON hs.holdings_id = hrt.id
LEFT JOIN folio_derived.holdings_notes hn
    ON hn.holding_id = hrt.id
LEFT JOIN folio_derived.instance_ext ie
    ON ie.instance_id = it2.id
WHERE ie2.material_type_name = 'journal'
  AND he.permanent_location_name IN (
        'Fairchild - 5th Floor - North - Current Periodicals',
        'Fairchild - 5th Floor - North'
      )
  AND (it.discovery_suppress::BOOLEAN <> TRUE OR it.discovery_suppress IS NULL)
  AND (hrt.discovery_suppress::BOOLEAN <> TRUE OR hrt.discovery_suppress IS NULL)
  AND (it2.discovery_suppress::BOOLEAN <> TRUE OR it2.discovery_suppress IS NULL)
GROUP BY
    ie.instance_id,
    ie.instance_hrid,
    it2.title,
    ie2.material_type_name,
    ie2.status_name
ORDER BY
    it2.title;
$$
LANGUAGE SQL STABLE;

