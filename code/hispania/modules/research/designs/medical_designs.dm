/datum/design/healthanalyzer
	name = "Health Analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject"
	id = "healthanalyzer"
	req_tech = list("biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 50)
	build_path = /obj/item/healthanalyzer
	category = list("Medical")

/datum/design/laserscalpel
	name = "Laser Scalpel"
	desc = "A laser scalpel used for precise cutting."
	id = "laserscalpel"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_path = /obj/item/scalpel/advanced
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_SILVER = 1500, MAT_GOLD = 1500, MAT_DIAMOND = 250, MAT_TITANIUM = 1500)
	category = list("Tool Designs")

/datum/design/mechanicalpinches
	name = "Mechanical Pinches"
	desc = "These pinches can be either used as retractor or hemostat."
	id = "mechanicalpinches"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_path = /obj/item/retractor/advanced
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_SILVER = 1500, MAT_TITANIUM = 1500)
	category = list("Tool Designs")

/datum/design/searingtool
	name = "Searing Tool"
	desc = "Used to mend tissue together. Or drill tissue away."
	id = "searingtool"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_path = /obj/item/surgicaldrill/advanced
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_PLASMA = 1500, MAT_URANIUM = 1500, MAT_TITANIUM = 1500)
	category = list("Tool Designs")

/datum/design/moa
	name = "M.O.A"
	desc = "(Medbay Oxygen Asissistant) A oxigen assistant that will be sending oxygen to the pacient over a period of time."
	id = "m.o.a"
	req_tech = list("materials" = 5, "biotech" = 4, "engineering" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL=6000, MAT_GLASS=800, MAT_TITANIUM = 850)
	build_path = /obj/item/reagent_containers/moa
	category = list("Medical")
