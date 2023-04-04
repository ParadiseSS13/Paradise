///////////////////////////////////
//////////AI Module Disks//////////
///////////////////////////////////

/datum/design/freeform_module
	name = "AI Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Module."
	id = "freeform_module"
	req_tech = list("programming" = 5, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 100)
	build_path = /obj/item/aiModule/freeform
	category = list("AI Modules")

/datum/design/onecrewmember_module
	name = "AI Module (oneCrewMember)"
	desc = "Allows for the construction of a oneCrewMember AI Module."
	id = "onecrewmember_module"
	req_tech = list("programming" = 6, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/oneCrewMember
	category = list("AI Modules")

/datum/design/oxygen_module
	name = "AI Module (OxygenIsToxicToHumans)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "oxygen_module"
	req_tech = list("programming" = 4, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 100)
	build_path = /obj/item/aiModule/oxygen
	category = list("AI Modules")

/datum/design/protectstation_module
	name = "AI Module (ProtectStation)"
	desc = "Allows for the construction of a ProtectStation AI Module."
	id = "protectstation_module"
	req_tech = list("programming" = 5, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 100)
	build_path = /obj/item/aiModule/protectStation
	category = list("AI Modules")

/datum/design/purge_module
	name = "AI Module (Purge)"
	desc = "Allows for the construction of a Purge AI Module."
	id = "purge_module"
	req_tech = list("programming" = 5, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/purge
	category = list("AI Modules")

/datum/design/quarantine_module
	name = "AI Module (Quarantine)"
	desc = "Allows for the construction of a Quarantine AI Module."
	id = "quarantine_module"
	req_tech = list("programming" = 3, "biotech" = 2, "materials" = 4)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 100)
	build_path = /obj/item/aiModule/quarantine
	category = list("AI Modules")

/datum/design/reset_module
	name = "AI Module (Reset)"
	desc = "Allows for the construction of a Reset AI Module."
	id = "reset_module"
	req_tech = list("programming" = 4, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 100)
	build_path = /obj/item/aiModule/reset
	category = list("AI Modules")

/datum/design/safeguard_module
	name = "AI Module (Safeguard)"
	desc = "Allows for the construction of a Safeguard AI Module."
	id = "safeguard_module"
	req_tech = list("programming" = 3, "materials" = 3)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_GOLD = 100)
	build_path = /obj/item/aiModule/safeguard
	category = list("AI Modules")

/datum/design/antimov_module
	name = "Core AI Module (Antimov)"
	desc = "Allows for the construction of a Antimov AI Core Module."
	id = "antimov_module"
	req_tech = list("programming" = 5, "syndicate" = 2, "materials" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/antimov
	category = list("AI Modules")

/datum/design/asimov
	name = "Core AI Module (Asimov)"
	desc = "Allows for the construction of a Asimov AI Core Module."
	id = "asimov_module"
	req_tech = list("programming" = 3, "materials" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/asimov
	category = list("AI Modules")

/datum/design/corporate_module
	name = "Core AI Module (Corporate)"
	desc = "Allows for the construction of a Corporate AI Core Module."
	id = "corporate_module"
	req_tech = list("programming" = 5, "materials" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/corp
	category = list("AI Modules")

/datum/design/crewsimov
	name = "Core AI Module (Crewsimov)"
	desc = "Allows for the construction of a Crewsimov AI Core Module."
	id = "crewsimov_module"
	req_tech = list("programming" = 3, "materials" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/crewsimov
	category = list("AI Modules")

/datum/design/freeformcore_module
	name = "Core AI Module (Freeform)"
	desc = "Allows for the construction of a Freeform AI Core Module."
	id = "freeformcore_module"
	req_tech = list("programming" = 6, "materials" = 6)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/freeformcore
	category = list("AI Modules")

/datum/design/paladin_module
	name = "Core AI Module (P.A.L.A.D.I.N.)"
	desc = "Allows for the construction of a P.A.L.A.D.I.N. AI Core Module."
	id = "paladin_module"
	req_tech = list("programming" = 5, "materials" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/paladin
	category = list("AI Modules")

/datum/design/tyrant_module
	name = "Core AI Module (T.Y.R.A.N.T.)"
	desc = "Allows for the construction of a T.Y.R.A.N.T. AI Module."
	id = "tyrant_module"
	req_tech = list("programming" = 5, "syndicate" = 2, "materials" = 5)
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 1000, MAT_DIAMOND = 100)
	build_path = /obj/item/aiModule/tyrant
	category = list("AI Modules")
