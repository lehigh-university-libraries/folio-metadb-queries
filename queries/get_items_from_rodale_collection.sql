--metadb:function get_items_from_rodale_collection
-- This function retrieves all items that are in the Rodale Collection. This is a cataloging check as well as a reporting list
CREATE FUNCTION get_items_from_rodale_collection()

RETURNS TABLE
(   
item_barcode TEXT,
item_status TEXT,
item_material_type TEXT,
item_updated DATE,
item_accession_number TEXT,
item_suppress TEXT,
item_permanent_location TEXT,
holdings_id TEXT,
holdings_hrid TEXT,
holdings_suppress TEXT,
holdings_call_numb TEXT,
holdings_call_numb_type TEXT,
holdings_type TEXT,
holdings_location TEXT,
instance_id TEXT,
instance_hrid TEXT,
instance_suppress TEXT,
instance_notes TEXT
) 
AS
$$

SELECT
  ie2.barcode AS item_barcode,
  ie2.status_name AS item_status,
  ie2.material_type_name AS item_material_type,
  ie2.updated_date AS item_updated,
  ie2.accession_number AS item_accession_number,
  ie2.discovery_suppress AS item_suppress,
  ie2.permanent_location_name AS item_permanent_location,
  he.holdings_id AS holdings_id,
  he.holdings_hrid AS holdings_hrid,
  he.discovery_suppress AS holdings_suppress,
  he.call_number AS holdings_call_numb,
  he.call_number_type_name AS holdings_call_numb_type,
  he.type_name AS holdings_type,
  he.permanent_location_name AS holdings_location,
  ie.instance_id AS instance_id,
  ie.instance_hrid AS instance_hrid,
  ie.discovery_suppress AS instance_suppress,
  STRING_AGG(in2.instance_note, '; ') AS instance_notes

FROM
  folio_inventory.item__t it 
  LEFT JOIN folio_derived.item_ext ie2 ON ie2.item_id = it.id 
  JOIN folio_inventory.holdings_record__t hrt ON hrt.id = it.holdings_record_id 
  LEFT JOIN folio_derived.holdings_ext he ON he.holdings_id = hrt.id 
  LEFT JOIN folio_inventory.holdings_type__t htt ON htt.id = hrt.holdings_type_id 
  JOIN folio_inventory.instance__t it2 ON it2.id = hrt.instance_id 
  LEFT JOIN folio_derived.instance_ext ie ON ie.instance_id = it2.id
  LEFT JOIN folio_derived.instance_notes in2 
    ON in2.instance_id = it2.id AND in2.instance_note_type_name = 'Local notes'

WHERE
  ie2.effective_location_name = 'Goodman 125 - Room 101a'
  AND (it.discovery_suppress::BOOLEAN <> TRUE OR it.discovery_suppress IS NULL)
  AND (hrt.discovery_suppress::BOOLEAN <> TRUE OR hrt.discovery_suppress IS NULL)
  AND (it2.discovery_suppress::BOOLEAN <> TRUE OR it2.discovery_suppress IS NULL)

GROUP BY
  ie2.barcode,
  ie2.status_name,
  ie2.material_type_name,
  ie2.updated_date,
  ie2.accession_number,
  ie2.discovery_suppress,
  ie2.permanent_location_name,
  he.holdings_id,
  he.holdings_hrid,
  he.discovery_suppress,
  he.call_number,
  he.call_number_type_name,
  he.type_name,
  he.permanent_location_name,
  ie.instance_id,
  ie.instance_hrid,
  ie.discovery_suppress;
 
$$
LANGUAGE SQL STABLE;
