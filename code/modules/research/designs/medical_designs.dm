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
	reliability_base = 76
	build_path = /obj/item/device/robotanalyzer
	category = list("Medical")

/datum/design/healthanalyzer
	name = "Health Analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	id = "healthanalyzer"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list("$metal" = 20, "$glass" = 20)
	build_path = /obj/item/device/healthanalyzer
	category = list("Medical")

/datum/design/healthanalyzer_upgrade
	name = "Health Analyzer Upgrade"
	desc = "An upgrade unit for expanding the functionality of a health analyzer."
	id = "healthanalyzer_upgrade"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 20, "$glass" = 20)
	build_path = /obj/item/device/healthupgrade
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


/datum/design/sensor_device
	name = "Handheld Crew Monitor"
	desc = "A device for tracking crew members on the station."
	id = "sensor_device"
	req_tech = list("biotech" = 4, "magnets" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list("$metal" = 30, "$glass" = 20)
	reliability_base = 76
	build_path = /obj/item/device/sensor_device
	category = list("Medical")

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list("$metal" = 1000, "$glass" = 500)
	construction_time = 75
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
	construction_time = 75
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
	construction_time = 100
	reliability_base = 76
	build_path = /obj/item/device/flash/synthetic
	category = list("Misc")
