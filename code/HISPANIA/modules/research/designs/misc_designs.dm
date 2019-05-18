/datum/design/plasma_tank
	name = "Empty plasma tank"
	desc = "an empty plasma tank"
	id = "plasmatank"
	req_tech = list("toxins" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=3000, MAT_GLASS=500)
	build_path = /obj/item/tank/plasma/empty
	category = list("Miscellaneous")
