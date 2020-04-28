/datum/design/bluespace_rollerbed
	name = "Bluespace Roller bed"
	desc = "An upgraded version of a roller bed. This one can be carried in a backpack."
	id = "bluespace_rollerbed"
	req_tech = list("bluespace" = 6, "materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_TITANIUM = 1500, MAT_BLUESPACE = 1000)
	build_path = /obj/item/roller/bluespace
	category = list("Bluespace")

/datum/design/bluespace_binoculars
	name = "Bluespace Binoculars"
	desc = "Weird tool to make explorations or stalking more easy"
	id = "bluespace_binoculars"
	req_tech = list("bluespace" = 6, "materials" = 7, "engineering" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_TITANIUM = 1500, MAT_BLUESPACE = 2000)
	build_path = /obj/item/device/binoculars/bluespace
	category = list("Bluespace")
