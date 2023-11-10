// Executioner
/datum/design/executioner_main
	name = "Exosuit Board (\"Executioner\" Central Control module)"
	desc = "Allows for the construction of a \"Executioner\" Central Control module."
	id = "executioner_main"
	req_tech = list("programming" = 4, "combat" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/executioner/main
	category = list("Exosuit Modules")

/datum/design/executioner_peri
	name = "Exosuit Board (\"Executioner\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Executioner\" Peripheral Control module."
	id = "executioner_peri"
	req_tech = list("programming" = 4, "combat" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/executioner/peripherals
	category = list("Exosuit Modules")

/datum/design/executioner_targ
	name = "Exosuit Board (\"Executioner\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Executioner\" Weapons & Targeting Control module."
	id = "executioner_targ"
	req_tech = list("programming" = 5, "combat" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/executioner/targeting
	category = list("Exosuit Modules")
