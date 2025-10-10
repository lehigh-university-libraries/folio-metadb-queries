--metadb:function get_print_journals_in_linderman
--This function retrieves print journals that are located in Linderman.
DROP FUNCTION IF EXISTS get_print_journals_in_linderman;
CREATE FUNCTION get_print_journals_in_linderman()
RETURNS TABLE
( 
    instance_id TEXT,
    instance_hrid TEXT,
    title TEXT,
    item_material_type TEXT,
    item_status TEXT,
    linderman_reading_room_location TEXT,
    linderman_reading_room_statement TEXT,
    linderman_reading_room_receipt_status TEXT,
    linderman_reading_room_call_number TEXT,
    linderman_reading_room_bindery_note TEXT,
    linderman_reading_room_binding_frequency_note TEXT,
    linderman_reading_room_journal_publication_frequency_note TEXT,
    linderman_lower_level_location TEXT,
    linderman_lower_level_statement TEXT,
    linderman_lower_level_receipt_status TEXT,
    linderman_lower_level_call_number TEXT,
    linderman_lower_level_bindery_note TEXT,
    linderman_lower_level_binding_frequency_note TEXT,
    linderman_lower_level_journal_publication_frequency_note TEXT
)
AS
$$
SELECT
    ie.instance_id,
    ie.instance_hrid,
    it2.title,
    ie2.material_type_name AS item_material_type,
    ie2.status_name AS item_status,

    -- Linderman 1st Floor - Reading Room - Current Periodicals
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman 1st Floor - Reading Room - Current Periodicals' 
            THEN he.permanent_location_name 
        END) AS linderman_reading_room_location,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman 1st Floor - Reading Room - Current Periodicals' 
            THEN hs.holdings_statement 
        END) AS linderman_reading_room_statement,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman 1st Floor - Reading Room - Current Periodicals'
            THEN he.receipt_status 
        END) AS linderman_reading_room_receipt_status,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman 1st Floor - Reading Room - Current Periodicals'
            THEN he.call_number
        END) AS linderman_reading_room_call_number,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman 1st Floor - Reading Room - Current Periodicals'
                 AND hn.note_type_name = 'Bindery'
            THEN hn.note
        END) AS linderman_reading_room_bindery_note,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman 1st Floor - Reading Room - Current Periodicals'
                 AND hn.note_type_name = 'Binding frequency'
            THEN hn.note
        END) AS linderman_reading_room_binding_frequency_note,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman 1st Floor - Reading Room - Current Periodicals'
                 AND hn.note_type_name = 'Journal publication frequency'
            THEN hn.note
        END) AS linderman_reading_room_journal_publication_frequency_note,

    -- Linderman Ground Floor - Lower Level
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman Ground Floor - Lower Level' 
            THEN he.permanent_location_name 
        END) AS linderman_lower_level_location,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman Ground Floor - Lower Level' 
            THEN hs.holdings_statement 
        END) AS linderman_lower_level_statement,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman Ground Floor - Lower Level'
            THEN he.receipt_status 
        END) AS linderman_lower_level_receipt_status,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman Ground Floor - Lower Level'
            THEN he.call_number
        END) AS linderman_lower_level_call_number,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman Ground Floor - Lower Level'
                 AND hn.note_type_name = 'Bindery'
            THEN hn.note
        END) AS linderman_lower_level_bindery_note,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman Ground Floor - Lower Level'
                 AND hn.note_type_name = 'Binding frequency'
            THEN hn.note
        END) AS linderman_lower_level_binding_frequency_note,
    MAX(CASE 
            WHEN he.permanent_location_name = 'Linderman Ground Floor - Lower Level'
                 AND hn.note_type_name = 'Journal publication frequency'
            THEN hn.note
        END) AS linderman_lower_level_journal_publication_frequency_note

FROM folio_inventory.item__t it
JOIN folio_inventory.holdings_record__t hrt
    ON hrt.id = it.holdings_record_id
JOIN folio_inventory.instance__t it2
    ON it2.id = hrt.instance_id
LEFT JOIN folio_derived.item_ext ie2
    ON ie2.item_id = it.id
LEFT JOIN folio_derived.holdings_ext he
    ON he.holdings_id = hrt.id
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
        'Linderman 1st Floor - Reading Room - Current Periodicals',
        'Linderman Ground Floor - Lower Level'
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
