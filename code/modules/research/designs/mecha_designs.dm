///////////////////////////////////
//////////Mecha Module Disks///////
///////////////////////////////////
// Ripley
/datum/design/ripley_main
	name = "Exosuit Board (APLU \"Ripley\" Central Control module)"
	desc = "Allows for the construction of a \"Ripley\" Central Control module."
	id = "ripley_main"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/ripley/main
	category = list("Exosuit Modules")

/datum/design/ripley_peri
	name = "Exosuit Board (APLU \"Ripley\" Peripherals Control module)"
	desc = "Allows for the construction of a  \"Ripley\" Peripheral Control module."
	id = "ripley_peri"
	req_tech = list("programming" = 2)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/ripley/peripherals
	category = list("Exosuit Modules")

// Odysseus
/datum/design/odysseus_main
	name = "Exosuit Board (\"Odysseus\" Central Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Central Control module."
	id = "odysseus_main"
	req_tech = list("programming" = 3,"biotech" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/odysseus/main
	category = list("Exosuit Modules")

/datum/design/odysseus_peri
	name = "Exosuit Board (\"Odysseus\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Odysseus\" Peripheral Control module."
	id = "odysseus_peri"
	req_tech = list("programming" = 3,"biotech" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/odysseus/peripherals
	category = list("Exosuit Modules")

// Gygax
/datum/design/gygax_main
	name = "Exosuit Board (\"Gygax\" Central Control module)"
	desc = "Allows for the construction of a \"Gygax\" Central Control module."
	id = "gygax_main"
	req_tech = list("programming" = 4, "combat" = 3, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/gygax/main
	category = list("Exosuit Modules")

/datum/design/gygax_peri
	name = "Exosuit Board (\"Gygax\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Gygax\" Peripheral Control module."
	id = "gygax_peri"
	req_tech = list("programming" = 4, "combat" = 3, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/gygax/peripherals
	category = list("Exosuit Modules")

/datum/design/gygax_targ
	name = "Exosuit Board (\"Gygax\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Gygax\" Weapons & Targeting Control module."
	id = "gygax_targ"
	req_tech = list("programming" = 4, "combat" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/gygax/targeting
	category = list("Exosuit Modules")

// Durand
/datum/design/durand_main
	name = "Exosuit Board (\"Durand\" Central Control module)"
	desc = "Allows for the construction of a \"Durand\" Central Control module."
	id = "durand_main"
	req_tech = list("programming" = 4, "combat" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/durand/main
	category = list("Exosuit Modules")

/datum/design/durand_peri
	name = "Exosuit Board (\"Durand\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Durand\" Peripheral Control module."
	id = "durand_peri"
	req_tech = list("programming" = 4, "combat" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/durand/peripherals
	category = list("Exosuit Modules")

/datum/design/durand_targ
	name = "Exosuit Board (\"Durand\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Durand\" Weapons & Targeting Control module."
	id = "durand_targ"
	req_tech = list("programming" = 5, "combat" = 4, "engineering" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/durand/targeting
	category = list("Exosuit Modules")

// Phazon
/datum/design/phazon_main
	name = "Exosuit Board (\"Phazon\" Central Control module)"
	desc = "Allows for the construction of a \"Phazon\" Central Control module."
	id = "phazon_main"
	req_tech = list("programming" = 6, "materials" = 6, "plasmatech" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 100)
	build_path = /obj/item/circuitboard/mecha/phazon/main
	category = list("Exosuit Modules")

/datum/design/phazon_peri
	name = "Exosuit Board (\"Phazon\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Phazon\" Peripheral Control module."
	id = "phazon_peri"
	req_tech = list("programming" = 6, "bluespace" = 5, "plasmatech" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 100)
	build_path = /obj/item/circuitboard/mecha/phazon/peripherals
	category = list("Exosuit Modules")

/datum/design/phazon_targ
	name = "Exosuit Design (\"Phazon\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Phazon\" Weapons & Targeting Control module."
	id = "phazon_targ"
	req_tech = list("programming" = 6, "magnets" = 5, "plasmatech" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_BLUESPACE = 100)
	build_path = /obj/item/circuitboard/mecha/phazon/targeting
	category = list("Exosuit Modules")

// H.O.N.K.
/datum/design/honker_main
	name = "Exosuit Board (\"H.O.N.K\" Central Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Central Control module."
	id = "honker_main"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/honker/main
	category = list("Exosuit Modules")

/datum/design/honker_peri
	name = "Exosuit Board (\"H.O.N.K\" Peripherals Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Peripheral Control module."
	id = "honker_peri"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/honker/peripherals
	category = list("Exosuit Modules")

/datum/design/honker_targ
	name = "Exosuit Board (\"H.O.N.K\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"H.O.N.K\" Weapons & Targeting Control module."
	id = "honker_targ"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/honker/targeting
	category = list("Exosuit Modules")

/datum/design/reticence_main
	name = "Exosuit Module (\"Reticence\" Central Control module)"
	desc = "Allows for the construction of a \"Reticence\" Central Control module."
	id = "reticence_main"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/reticence/main
	category = list("Exosuit Modules")

/datum/design/reticence_peri
	name = "Exosuit Module (\"Reticence\" Peripherals Control module)"
	desc = "Allows for the construction of a \"Reticence\" Peripheral Control module."
	id = "reticence_peri"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/reticence/peripherals
	category = list("Exosuit Modules")

/datum/design/reticence_targ
	name = "Exosuit Module (\"Reticence\" Weapons & Targeting Control module)"
	desc = "Allows for the construction of a \"Reticence\" Weapons & Targeting Control module."
	id = "reticence_targ"
	req_tech = list("programming" = 3, "engineering" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000)
	build_path = /obj/item/circuitboard/mecha/reticence/targeting
	category = list("Exosuit Modules")
