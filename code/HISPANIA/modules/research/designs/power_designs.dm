/datum/design/inducer
	name = "Inducer"
	desc = "The NT-75 Electromagnetic Power Inducer can wirelessly induce electric charge in an object, allowing you to recharge power cells without having to remove them."
	id = "inducer"
	build_type = PROTOLATHE | MECHFAB
	req_tech = list("powerstorage" = 5, "materials" = 5, "engineering" = 5)
	materials = list(MAT_METAL = 3000, MAT_GLASS = 1000, MAT_SILVER=1000, MAT_GOLD = 1500)
	build_path = /obj/item/inducer/sci
	category = list("Misc","Power")

/datum/design/xenobluecellmaker
	name = "Xenobluespace power cell Maker"
	desc = "High-tech porwer cell shell capable of creating a porwer cell that combines Bluespace and xenobiology technology."
	id = "xenobluecell"
	req_tech = list("powerstorage" = 7, "materials" = 6, "engineering" = 6, "bluespace" = 6)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2000, MAT_GOLD = 440, MAT_GLASS = 720, MAT_DIAMOND = 480, MAT_URANIUM = 100, MAT_TITANIUM = 600, MAT_BLUESPACE = 200)
	build_path = /obj/item/xenobluecellmaker
	category = list("Misc","Power")

