/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/adv_reagent_scanner
	name = "Advanced Reagent Scanner"
	desc = "A device for identifying chemicals and their proportions."
	id = "adv_reagent_scanner"
	req_tech = list("biotech" = 3, "magnets" = 4, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/reagent_scanner/adv
	category = list("Medical")

/datum/design/bluespacebeaker
	name = "Bluespace Beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology and Element Cuban combined with the Compound Pete. Can hold up to 300 units."
	id = "bluespacebeaker"
	req_tech = list("bluespace" = 6, "materials" = 5, "plasmatech" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 3000, MAT_PLASMA = 3000, MAT_DIAMOND = 250, MAT_BLUESPACE = 250)
	build_path = /obj/item/reagent_containers/glass/beaker/bluespace
	category = list("Medical")

/datum/design/noreactbeaker
	name = "Cryostasis Beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions. Can hold up to 50 units."
	id = "splitbeaker"
	req_tech = list("materials" = 3, "engineering" = 3, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 3000)
	build_path = /obj/item/reagent_containers/glass/beaker/noreact
	category = list("Medical")

/datum/design/cyborg_analyzer
	name = "Cyborg Analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries."
	id = "cyborg_analyzer"
	req_tech = list("programming" = 2, "biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/robotanalyzer
	category = list("Medical")

/datum/design/healthanalyzer_upgrade
	name = "Health Analyzer Upgrade"
	desc = "An upgrade unit for expanding the functionality of a health analyzer."
	id = "healthanalyzer_upgrade"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 20)
	build_path = /obj/item/healthupgrade
	category = list("Medical")

/datum/design/handheld_defib
	name = "Handheld Defibrillator"
	desc = "A smaller defibrillator only capable of treating cardiac arrest."
	id = "handheld_defib"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 20, MAT_GLASS = 20)
	build_path = /obj/item/handheld_defibrillator
	category = list("Medical")

/datum/design/defib
	name = "Defibrillator"
	desc = "A device that delivers powerful shocks to detachable paddles that resuscitate incapacitated patients."
	id = "defib"
	req_tech = list("materials" = 7, "biotech" = 5, "powerstorage" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 5000, MAT_GLASS = 2000, MAT_SILVER = 1000)
	build_path = /obj/item/defibrillator
	category = list("Medical")

/datum/design/defib_mount
	name = "Defibrillator Wall Mount"
	desc = "A wall mount for defibrillator units."
	id = "defib_mount"
	req_tech = list("magnets" = 3, "biotech" = 3, "powerstorage" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/mounted/frame/defib_mount
	category = list("Medical")

/datum/design/sensor_device
	name = "Handheld Crew Monitor"
	desc = "A device for tracking crew members on the station."
	id = "sensor_device"
	req_tech = list("programming" = 3, "magnets" = 2, "biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/sensor_device
	category = list("Medical")

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	id = "mmi"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 2)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	construction_time = 75
	build_path = /obj/item/mmi
	category = list("Misc","Medical")

/datum/design/robotic_brain
	name = "Robotic Brain"
	desc = "The latest in non-sentient Artificial Intelligences."
	id = "mmi_robotic"
	req_tech = list("programming" = 5, "biotech" = 4, "plasmatech" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1700, MAT_GLASS = 1350, MAT_GOLD = 500) //Gold, because SWAG.
	construction_time = 75
	build_path = /obj/item/mmi/robotic_brain
	category = list("Misc","Medical")

/datum/design/mmi_radio_upgrade
	name = "Man-Machine Interface Radio Upgrade"
	desc = "Enables radio capability on MMIs when either installed directly on the MMI, or through a cyborg's chassis."
	id = "mmi_radio_upgrade"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 2)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 200)
	construction_time = 50
	build_path = /obj/item/mmi_radio_upgrade
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
	req_tech = list("magnets" = 2, "plasmatech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 30, MAT_GLASS = 20)
	build_path = /obj/item/reagent_scanner
	category = list("Medical")

/datum/design/item/scalpel_laser1
	name = "Basic Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks basic and could be improved."
	id = "scalpel_laser1"
	req_tech = list("biotech" = 2, "materials" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500)
	build_path = /obj/item/scalpel/laser/laser1
	category = list("Medical")

/datum/design/item/scalpel_laser2
	name = "Improved Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks somewhat advanced."
	id = "scalpel_laser2"
	req_tech = list("biotech" = 3, "materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_SILVER = 1000)
	build_path = /obj/item/scalpel/laser/laser2
	category = list("Medical")

/datum/design/item/scalpel_laser3
	name = "Advanced Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks to be the pinnacle of precision energy cutlery!"
	id = "scalpel_laser3"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/scalpel/laser/laser3
	category = list("Medical")

/datum/design/item/scalpel_manager
	name = "Incision Management System"
	desc = "A true extension of the surgeon's body, this marvel instantly and completely prepares an incision allowing for the immediate commencement of therapeutic steps."
	id = "scalpel_manager"
	req_tech = list("biotech" = 4, "materials" = 7, "magnets" = 5, "programming" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_GOLD = 1000, MAT_DIAMOND = 1000)
	build_path = /obj/item/scalpel/laser/manager
	category = list("Medical")

/datum/design/alienscalpel
	name = "Alien Scalpel"
	desc = "An advanced scalpel obtained through Abductor technology."
	id = "alien_scalpel"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/scalpel/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical")

/datum/design/alienhemostat
	name = "Alien Hemostat"
	desc = "An advanced hemostat obtained through Abductor technology."
	id = "alien_hemostat"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/hemostat/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical")

/datum/design/alienretractor
	name = "Alien Retractor"
	desc = "An advanced retractor obtained through Abductor technology."
	id = "alien_retractor"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/retractor/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical")

/datum/design/aliensaw
	name = "Alien Circular Saw"
	desc = "An advanced surgical saw obtained through Abductor technology."
	id = "alien_saw"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/circular_saw/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 1500)
	category = list("Medical")

/datum/design/aliendrill
	name = "Alien Drill"
	desc = "An advanced drill obtained through Abductor technology."
	id = "alien_drill"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/surgicaldrill/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2500, MAT_PLASMA = 1000, MAT_TITANIUM = 1500)
	category = list("Medical")

/datum/design/aliencautery
	name = "Alien Cautery"
	desc = "An advanced cautery obtained through Abductor technology."
	id = "alien_cautery"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/cautery/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical")

/datum/design/alienbonegel
	name = "Alien Bone Gel"
	desc = "Advanced bone gel obtained through Abductor technology."
	id = "alien_bonegel"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/bonegel/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical")

/datum/design/alienbonesetter
	name = "Alien Bone Setter"
	desc = "An advanced bone setter obtained through Abductor technology."
	id = "alien_bonesetter"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/bonesetter/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical")

/datum/design/alienfixovein
	name = "Alien FixOVein"
	desc = "An advanced FixOVein obtained through Abductor technology."
	id = "alien_fixovein"
	req_tech = list("biotech" = 4, "materials" = 4, "abductor" = 3)
	build_path = /obj/item/FixOVein/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical")

/////////////////////////////////////////
//////////Cybernetic Implants////////////
/////////////////////////////////////////

/datum/design/cyberimp_welding
	name = "Welding Shield implant"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	id = "ci-welding"
	req_tech = list("materials" = 4, "biotech" = 4, "engineering" = 5, "plasmatech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 600, MAT_GLASS = 400)
	build_path = /obj/item/organ/internal/cyberimp/eyes/shield
	category = list("Misc", "Medical")

/datum/design/cyberimp_breather
	name = "Breathing Tube Implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	id = "ci-breather"
	req_tech = list("materials" = 2, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 35
	materials = list(MAT_METAL = 600, MAT_GLASS = 250)
	build_path = /obj/item/organ/internal/cyberimp/mouth/breathing_tube
	category = list("Misc", "Medical")

/datum/design/cyberimp_surgical
	name = "Surgical Arm Implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	id = "ci-surgey"
	req_tech = list("materials" = 3, "engineering" = 3, "biotech" = 3, "programming" = 2, "magnets" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/surgery
	category = list("Misc", "Medical")

/datum/design/cyberimp_toolset
	name = "Toolset Arm Implant"
	desc = "A stripped-down version of engineering cyborg toolset, designed to be installed on subject's arm."
	id = "ci-toolset"
	req_tech = list("materials" = 3, "engineering" = 4, "biotech" = 4, "powerstorage" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/toolset
	category = list("Misc", "Medical")

/datum/design/cyberimp_diagnostic_hud
	name = "Diagnostic HUD implant"
	desc = "These cybernetic eye implants will display a diagnostic HUD over everything you see. Wiggle eyes to control."
	id = "ci-diaghud"
	req_tech = list("materials" = 5, "engineering" = 4, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	category = list("Misc", "Medical")

/datum/design/cyberimp_medical_hud
	name = "Medical HUD implant"
	desc = "These cybernetic eyes will display a medical HUD over everything you see. Wiggle eyes to control."
	id = "ci-medhud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/medical
	category = list("Misc", "Medical")

/datum/design/cyberimp_security_hud
	name = "Security HUD implant"
	desc = "These cybernetic eyes will display a security HUD over everything you see. Wiggle eyes to control."
	id = "ci-sechud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4, "combat" = 3)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 750, MAT_GOLD = 750)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/security
	category = list("Misc", "Medical")

/datum/design/cyberimp_meson
	name = "Meson scanner implant"
	desc = "These cybernetic eyes will allow you to see the structural layout of the station, and, well, everything else."
	id = "ci-mesonhud"
	req_tech = list("materials" = 4, "biotech" = 4, "engineering" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500, MAT_GOLD = 300)
	build_path = /obj/item/organ/internal/cyberimp/eyes/meson
	category = list("Misc", "Medical")

/datum/design/cyberimp_xray
	name = "X-Ray implant"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	id = "ci-xray"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 7, "magnets" = 5,"plasmatech" = 6)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_URANIUM = 1000, MAT_DIAMOND = 1000, MAT_BLUESPACE = 1000)
	build_path = /obj/item/organ/internal/cyberimp/eyes/xray
	category = list("Misc", "Medical")

/datum/design/cyberimp_thermals
	name = "Thermals implant"
	desc = "These cybernetic eyes will give you Thermal vision. Vertical slit pupil included."
	id = "ci-thermals"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 7, "magnets" = 5,"plasmatech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_DIAMOND = 2000)
	build_path = /obj/item/organ/internal/cyberimp/eyes/thermals
	category = list("Misc", "Medical")

/datum/design/cyberimp_antidrop
	name = "Anti-Drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	id = "ci-antidrop"
	req_tech = list("materials" = 5, "programming" = 6, "biotech" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 400, MAT_GOLD = 400)
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_drop
	category = list("Misc", "Medical")

/datum/design/cyberimp_antistun
	name = "CNS Rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	id = "ci-antistun"
	req_tech = list("materials" = 6, "programming" = 5, "biotech" = 6)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 1000)
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
	req_tech = list("materials" = 3, "powerstorage" = 4, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/chest/nutriment
	category = list("Misc", "Medical")

/datum/design/cyberimp_nutriment_plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	id = "ci-nutrimentplus"
	req_tech = list("materials" = 5, "powerstorage" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_GOLD = 500, MAT_URANIUM = 750)
	build_path = /obj/item/organ/internal/cyberimp/chest/nutriment/plus
	category = list("Misc", "Medical")

/datum/design/cyberimp_reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	id = "ci-reviver"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 800, MAT_GLASS = 800, MAT_GOLD = 300, MAT_URANIUM = 500)
	build_path = /obj/item/organ/internal/cyberimp/chest/reviver
	category = list("Misc", "Medical")

/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////

/datum/design/implanter
	name = "Implanter"
	desc = "A sterile automatic implant injector."
	id = "implanter"
	req_tech = list("materials" = 2, "biotech" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 200)
	build_path = /obj/item/implanter
	category = list("Medical")

/datum/design/implantcase
	name = "Implant Case"
	desc = "A glass case containing an implant."
	id = "implantcase"
	req_tech = list("biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/implantcase
	category = list("Medical")

/datum/design/implant_chem
	name = "Chemical Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_chem"
	req_tech = list("materials" = 3, "biotech" = 5,)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 700)
	build_path = /obj/item/implantcase/chem
	category = list("Medical")

/datum/design/implant_tracking
	name = "Tracking Implant Case"
	desc = "A glass case containing an implant."
	id = "implant_tracking"
	req_tech = list("materials" = 2, "biotech" = 3, "magnets" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/implantcase/track
	category = list("Medical")

//Cybernetic organs

/datum/design/cybernetic_eyes
	name = "Cybernetic Eyes"
	desc = "A cybernetic pair of eyes"
	id = "cybernetic_eyes"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/organ/internal/eyes/cybernetic
	category = list("Medical")

/datum/design/cybernetic_liver
	name = "Cybernetic Liver"
	desc = "A cybernetic liver"
	id = "cybernetic_liver"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/organ/internal/liver/cybernetic
	category = list("Medical")

/datum/design/cybernetic_kidneys
	name = "Cybernetic Kidneys"
	desc = "A cybernetic pair of kidneys"
	id = "cybernetic_kidneys"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/organ/internal/kidneys/cybernetic
	category = list("Medical")

/datum/design/cybernetic_heart
	name = "Cybernetic Heart"
	desc = "A cybernetic heart"
	id = "cybernetic_heart"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/organ/internal/heart/cybernetic
	category = list("Medical")

/datum/design/cybernetic_heart_u
	name = "Upgraded Cybernetic Heart"
	desc = "An upgraded cybernetic heart."
	id = "cybernetic_heart_u"
	req_tech = list("biotech" = 5, "materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500)
	build_path = /obj/item/organ/internal/heart/cybernetic/upgraded
	category = list("Medical")

/datum/design/cybernetic_lungs
	name = "Cybernetic Lungs"
	desc = "A pair of cybernetic lungs."
	id = "cybernetic_lungs"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/organ/internal/lungs/cybernetic
	category = list("Medical")

/datum/design/cybernetic_lungs_u
	name = "Upgraded Cybernetic Lungs"
	desc = "A pair of upgraded cybernetic lungs."
	id = "cybernetic_lungs_u"
	req_tech = list("biotech" = 5, "materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500)
	build_path = /obj/item/organ/internal/lungs/cybernetic/upgraded
	category = list("Medical")
