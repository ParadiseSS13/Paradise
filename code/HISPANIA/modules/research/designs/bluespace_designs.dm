/datum/design/bluespace_rollerbed
	name = "Bluespace Roller bed"
	desc = "A small blue crystal with mystical properties."
	id = "bluespace_rollerbed"
	req_tech = list("bluespace" = 6, "materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_TITANIUM = 1500, MAT_BLUESPACE = 1500)
	build_path = /obj/item/roller/bluespace
	category = list("Bluespace")