/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////
/datum/design/adv_mass_spectrometer
	name = "Advanced Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood and their quantities."
	id = "adv_mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 74
	build_path = "/obj/item/device/mass_spectrometer/adv"
	category = list("Medical")

/datum/design/adv_reagent_scanner
	name = "Advanced Reagent Scanner"
	desc = "A device for identifying chemicals and their proportions."
	id = "adv_reagent_scanner"
	req_tech = list("biotech" = 2, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 74
	build_path = /obj/item/device/reagent_scanner/adv
	category = list("Medical")

/datum/design/noreactbeaker
	name = "Cryostasis Beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	req_tech = list("materials" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	reliability = 76
	build_path = /obj/item/weapon/reagent_containers/glass/beaker/noreact
	category = list("Medical")

/datum/design/cyborg_analyzer
	name = "Cyborg Analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "cyborg_analyzer"
	req_tech = list("programming" = 2, "biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 76
	build_path = /obj/item/device/robotanalyzer
	category = list("Medical")

/datum/design/healthanalyzer_upgrade
	name = "Health Analyzer Upgrade"
	desc = "An upgrade unit for expanding the functionality of a health analyzer."
	id = "healthanalyzer_upgrade"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 20)
	build_path = /obj/item/device/healthupgrade
	category = list("Medical")

/datum/design/defib
	name = "Defibrillator"
	desc = "A device that delivers powerful shocks to detachable paddles that resuscitate incapacitated patients."
	id = "defib"
	req_tech = list("materials" = 7, "biotech" = 5, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2000, MAT_SILVER = 1000)
	reliability = 76
	build_path = /obj/item/weapon/defibrillator
	category = list("Medical")


/datum/design/sensor_device
	name = "Handheld Crew Monitor"
	desc = "A device for tracking crew members on the station."
	id = "sensor_device"
	req_tech = list("biotech" = 4, "magnets" = 3, "materials" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 76
	build_path = /obj/item/device/sensor_device
	category = list("Medical")

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	req_tech = list("programming" = 2, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	construction_time = 75
	reliability = 76
	build_path = /obj/item/device/mmi
	category = list("Misc","Medical")

/datum/design/mass_spectrometer
	name = "Mass-Spectrometer"
	desc = "A device for analyzing chemicals in the blood."
	id = "mass_spectrometer"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 76
	build_path = /obj/item/device/mass_spectrometer
	category = list("Medical")

/datum/design/posibrain
	name = "Positronic Brain"
	desc = "The latest in Artificial Intelligences."
	id = "mmi_posi"
	req_tech = list("programming" = 5, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1700, MAT_GLASS = 1350, MAT_GOLD = 500) //Gold, because SWAG.
	reliability = 74
	construction_time = 75
	build_path = /obj/item/device/mmi/posibrain
	category = list("Misc","Medical")

/datum/design/mmi_radio
	name = "Radio-Enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	id = "mmi_radio"
	req_tech = list("programming" = 2, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1200, MAT_GLASS = 500)
	construction_time = 75
	reliability = 74
	build_path = /obj/item/device/mmi/radio_enabled
	category = list("Misc","Medical")

/datum/design/nanopaste
	name = "Nanopaste"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	id = "nanopaste"
	req_tech = list("materials" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000)
	build_path = /obj/item/stack/nanopaste
	category = list("Medical")

/datum/design/reagent_scanner
	name = "Reagent Scanner"
	desc = "A device for identifying chemicals."
	id = "reagent_scanner"
	req_tech = list("biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	reliability = 76
	build_path = /obj/item/device/reagent_scanner
	category = list("Medical")

/datum/design/synthetic_flash
	name = "Synthetic Flash"
	desc = "A synthetic flash used mostly in borg construction."
	id = "sflash"
	req_tech = list("magnets" = 3, "combat" = 2)
	build_type = MECHFAB
	materials = list(MAT_METAL = 750, MAT_GLASS = 750)
	construction_time = 100
	reliability = 76
	build_path = /obj/item/device/flash/synthetic
	category = list("Misc")

/datum/design/item/scalpel_laser1
	name = "Basic Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks basic and could be improved."
	id = "scalpel_laser1"
	req_tech = list("biotech" = 2, "materials" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500)
	build_path = /obj/item/weapon/scalpel/laser1
	category = list("Medical")

/datum/design/item/scalpel_laser2
	name = "Improved Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks somewhat advanced."
	id = "scalpel_laser2"
	req_tech = list("biotech" = 3, "materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_SILVER = 1000)
	build_path = /obj/item/weapon/scalpel/laser2
	category = list("Medical")

/datum/design/item/scalpel_laser3
	name = "Advanced Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks to be the pinnacle of precision energy cutlery!"
	id = "scalpel_laser3"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/weapon/scalpel/laser3
	category = list("Medical")

/datum/design/item/scalpel_manager
	name = "Incision Management System"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	id = "scalpel_manager"
	req_tech = list("biotech" = 4, "materials" = 7, "magnets" = 5, "programming" = 4)
	build_type = PROTOLATHE
	materials = list (MAT_METAL = 2000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_GOLD = 1000, MAT_DIAMOND = 1000)
	build_path = /obj/item/weapon/scalpel/manager
	category = list("Medical")


/////////////////////////////////////////
//////////Cybernetic Implants////////////
/////////////////////////////////////////

/datum/design/cyberimp_welding
	name = "Welding Shield implant"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	id = "ci-welding"
	req_tech = list("materials" = 4, "biotech" = 2)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 200, MAT_GLASS = 400)
	build_path = /obj/item/organ/internal/cyberimp/eyes/shield
	category = list("Misc", "Medical")

/datum/design/cyberimp_medical_hud
	name = "Medical HUD implant"
	desc = "These cybernetic eyes will display a medical HUD over everything you see. Wiggle eyes to control."
	id = "ci-medhud"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/medical
	category = list("Misc", "Medical")

/datum/design/cyberimp_security_hud
	name = "Security HUD implant"
	desc = "These cybernetic eyes will display a security HUD over everything you see. Wiggle eyes to control."
	id = "ci-sechud"
	req_tech = list("materials" = 6, "programming" = 5, "biotech" = 4, "combat" = 2)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 750, MAT_GOLD = 750)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/security
	category = list("Misc", "Medical")

/datum/design/cyberimp_xray
	name = "X-Ray implant"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	id = "ci-xray"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 6, "magnets" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_URANIUM = 1000, MAT_DIAMOND = 2000)
	build_path = /obj/item/organ/internal/cyberimp/eyes/xray
	category = list("Misc", "Medical")

/datum/design/cyberimp_thermals
	name = "Thermals implant"
	desc = "These cybernetic eyes will give you Thermal vision. Vertical slit pupil included."
	id = "ci-thermals"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 5, "magnets" = 5, "syndicate" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_DIAMOND = 2000)
	build_path = /obj/item/organ/internal/cyberimp/eyes/thermals
	category = list("Misc", "Medical")

/datum/design/cyberimp_antidrop
	name = "Anti-Drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	id = "ci-antidrop"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 400, MAT_GOLD = 400)
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_drop
	category = list("Misc", "Medical")

/datum/design/cyberimp_antistun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	id = "ci-antistun"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 6)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_SILVER = 500, MAT_GOLD = 1000)
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_stun
	category = list("Misc", "Medical")

/datum/design/cyberimp_clownvoice
	name = "Comical implant"
	desc = "<span class='sans'>Uh oh.</span>"
	id = "ci-clownvoice"
	req_tech = list("materials" = 2, "biotech" = 2)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_BANANIUM = 200)
	build_path = /obj/item/organ/internal/cyberimp/brain/clown_voice
	category = list("Misc", "Medical")

/datum/design/cyberimp_nutriment
	name = "Nutriment pump implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	id = "ci-nutriment"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_GOLD = 500, MAT_URANIUM = 500)
	build_path = /obj/item/organ/internal/cyberimp/chest/nutriment
	category = list("Misc", "Medical")

/datum/design/cyberimp_nutriment_plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	id = "ci-nutrimentplus"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 6)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_GOLD = 500, MAT_URANIUM = 750)
	build_path = /obj/item/organ/internal/cyberimp/chest/nutriment/plus
	category = list("Misc", "Medical")

/datum/design/cyberimp_reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	id = "ci-reviver"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 7, "syndicate" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_GOLD = 500, MAT_URANIUM = 1000, MAT_DIAMOND = 2000)
	build_path = /obj/item/organ/internal/cyberimp/chest/reviver
	category = list("Misc", "Medical")

/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////

/datum/design/implanter
	name = "Implanter"
	desc = "A sterile automatic implant injector."
	id = "implanter"
	req_tech = list("materials" = 1, "programming" = 2, "biotech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 200)
	build_path = /obj/item/weapon/implanter
	category = list("Medical")

/datum/design/implantcase
	name = "Implant Case"
	desc = "A glass case containing an implant."
	id = "implantcase"
	req_tech = list("materials" = 1, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/weapon/implantcase
	category = list("Medical")

/datum/design/implant_freedom
	name = "Freedom Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_freedom"
	req_tech = list("materials" = 2, "biotech" = 3, "magnets" = 3, "syndicate" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 500, MAT_GOLD = 250)
	build_path = /obj/item/weapon/implantcase/freedom
	category = list("Medical")

/datum/design/implant_adrenalin
	name = "Adrenalin Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_adrenalin"
	req_tech = list("materials" = 2, "biotech" = 5, "combat" = 3, "syndicate" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 50, MAT_GLASS = 500, MAT_GOLD = 500, MAT_URANIUM = 100, MAT_DIAMOND = 200)
	build_path = /obj/item/weapon/implantcase/adrenaline
	category = list("Medical")