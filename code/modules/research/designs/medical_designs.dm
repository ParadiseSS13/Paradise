/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////
/datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood and their quantities."
	id = "adv_mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 30, "$glass" = 20)
	reliability_base = 74
	build_path = "/obj/item/device/mass_spectrometer/adv"
	category = list("Medical")
	
/datum/design/adv_reagent_scanner
	name = "Advanced Reagent Scanner"
	desc = "A device for identifying chemicals and their proportions."
	id = "adv_reagent_scanner"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 30, "$glass" = 20)
	reliability_base = 74
	build_path = /obj/item/device/reagent_scanner/adv
	category = list("Medical")
	
/datum/design/bluespacebeaker
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	req_tech = list("bluespace" = 2, "materials" = 6)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000, "$plasma" = 3000, "$diamond" = 500)
	reliability_base = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/bluespace
	category = list("Medical")
	
/datum/design/implant_chem
	name = "Chemical Implant"
	desc = "An implant which can be filled with various chemicals, and then injected on command."
	id = "implant_chem"
	req_tech = list("materials" = 2, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/implantcase/chem
	locked = 1
	category = list("Medical")
	
/datum/design/noreactbeaker
	name = "Cryostasis Beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	req_tech = list("materials" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 3000)
	reliability_base = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreact
	category = list("Medical")
	
/datum/design/cyborg_analyzer
	name = "Cyborg Analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "cyborg_analyzer"
	req_tech = list("programming" = 2, "biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 30, "$glass" = 20)
	reliability_base = 74
	build_path = /obj/item/device/robotanalyzer
	category = list("Medical")
	
/datum/design/defib
	name = "Defibrillator"
	desc = "A device that delivers powerful shocks to detachable paddles that resuscitate incapacitated patients."
	id = "defib"
	req_tech = list("materials" = 7, "biotech" = 5, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list("$metal" = 5000, "$glass" = 2000, "$silver" = 1000)
	reliability = 76
	build_path = /obj/item/weapon/defibrillator
	category = list("Medical")
	
/datum/design/implant_free
	name = "Freedom Implant"
	desc = "An implant which allows the user to instantly escape from restraints."
	id = "implant_free"
	req_tech = list("syndicate" = 2, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = /obj/item/weapon/implantcase/freedom
	category = list("Medical")
	
/datum/design/implanter
	name = "Implanter"
	desc = "A basic implanter for injecting implants"
	id = "implanter"
	req_tech = list("materials" = 2, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 50, "$glass" = 50)
	build_path = "/obj/item/weapon/implanter"
	category = list("Medical")
	
/datum/design/implant_loyal
	name = "Loyalty Implant"
	desc = "An implant which makes its carrier loyal to Nanotrasen."
	id = "implant_loyal"
	req_tech = list("materials" = 2, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 7000, "$glass" = 7000)
	build_path = /obj/item/weapon/implantcase/loyalty
	locked = 1
	category = list("Medical")
	
/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list("$metal" = 1000, "$glass" = 500)
	reliability_base = 76
	build_path = /obj/item/device/mmi
	category = list("Misc","Medical")
	
/datum/design/mass_spectrometer
	name = "Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood."
	id = "mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 30, "$glass" = 20)
	reliability_base = 76
	build_path = /obj/item/device/mass_spectrometer
	category = list("Medical")
	
/datum/design/posibrain
	name = "Positronic Brain"
	desc = "Allows for the construction of a positronic brain"
	id = "posibrain"
	req_tech = list("engineering" = 4, "materials" = 6, "bluespace" = 2, "programming" = 4)
	build_type = PROTOLATHE
	materials = list("$metal" = 2000, "$glass" = 1000, "$silver" = 1000, "$gold" = 500, "$plasma" = 500, "$diamond" = 100)
	build_path = /obj/item/device/mmi/posibrain
	category = list("Misc","Medical")

/datum/design/mmi_radio
	name = "Radio-Enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	id = "mmi_radio"
	req_tech = list("programming" = 2, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list("$metal" = 1200, "$glass" = 500)
	reliability_base = 74
	build_path = /obj/item/device/mmi/radio_enabled
	category = list("Misc","Medical")
	
/datum/design/nanopaste
	name = "Nanopaste"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	id = "nanopaste"
	req_tech = list("materials" = 4, "engineering" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 7000, "$glass" = 7000)
	build_path = /obj/item/stack/nanopaste
	category = list("Medical")

/datum/design/reagent_scanner
	name = "Reagent Scanner"
	desc = "A device for identifying chemicals."
	id = "reagent_scanner"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 30, "$glass" = 20)
	reliability_base = 76
	build_path = /obj/item/device/reagent_scanner
	category = list("Medical")

/datum/design/synthetic_flash
	name = "Synthetic Flash"
	desc = "A synthetic flash used mostly in borg construction."
	id = "sflash"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = MECHFAB
	materials = list("$metal" = 750, "$glass" = 750)
	reliability_base = 76
	build_path = /obj/item/device/flash/synthetic
	category = list("Misc")
