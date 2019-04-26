/datum/design/xenobluecellmaker
	name = "Xenobluespace power cell Maker"
	desc = "High-tech porwer cell shell capable of creating a porwer cell that combines Bluespace and xenobiology technology."
	id = "xenobluecell"
	req_tech = list("powerstorage" = 7, "materials" = 6, "engineering" = 6, "bluespace" = 6)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1600, MAT_GOLD = 240, MAT_GLASS = 320, MAT_DIAMOND = 320, MAT_TITANIUM = 600, MAT_BLUESPACE = 200)
	construction_time=50
	build_path = /obj/item/xenobluecellmaker
	category = list("Misc","Power")


