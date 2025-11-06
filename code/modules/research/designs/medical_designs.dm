/////////////////////////////////////////
////////////Medical Tools////////////////
/////////////////////////////////////////

/datum/design/adv_reagent_scanner
	name = "Advanced Reagent Scanner"
	desc = "A device for identifying chemicals and their proportions."
	id = "adv_reagent_scanner"
	req_tech = list("biotech" = 3, "magnets" = 4, "plasmatech" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
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

/datum/design/machine_analyzer
	name = "Machine Analyzer"
	desc = "A hand-held scanner able to diagnose robotic injuries and the condition of machinery."
	id = "machine_analyzer"
	req_tech = list("programming" = 2, "biotech" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
	build_path = /obj/item/robotanalyzer
	category = list("Medical")

/datum/design/healthanalyzer_upgrade
	name = "Health Analyzer Upgrade"
	desc = "An upgrade unit for expanding the functionality of a health analyzer."
	id = "healthanalyzer_upgrade"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200)
	build_path = /obj/item/healthupgrade
	category = list("Medical")

/datum/design/automender
	name = "Auto-mender"
	id = "automender"
	req_tech = list("biotech" = 7, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_TITANIUM = 3000, MAT_GLASS = 1000)
	build_path = /obj/item/reagent_containers/applicator
	category = list("Medical")

/datum/design/handheld_defib
	name = "Handheld Defibrillator"
	desc = "A smaller defibrillator only capable of treating cardiac arrest."
	id = "handheld_defib"
	req_tech = list("biotech" = 2, "magnets" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 200, MAT_GLASS = 200)
	build_path = /obj/item/handheld_defibrillator
	category = list("Medical")

/datum/design/holostretcher
	name = "Holo Stretcher"
	desc = "A hardlight projector for transporting patients."
	id = "holo_stretcher"
	req_tech = list("magnets" = 5, "powerstorage" = 4)
	build_path = /obj/item/roller/holo
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_SILVER = 500, MAT_GLASS = 500, MAT_DIAMOND = 200)
	category = list("Medical")

/datum/design/crutches
	name = "Crutches"
	desc = "A pair of crutches to help those who have injured or missing legs to walk."
	id = "crutches"
	req_tech = list("biotech" = 3)
	build_path = /obj/item/crutches
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 1000, MAT_TITANIUM = 500)
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

/datum/design/compact_defib
	name = "Compact Defibrillator"
	desc = "A belt-mounted defibrillator for rapid deployment."
	id = "compact_defib"
	req_tech = list("materials" = 7, "biotech" = 7, "powerstorage" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 10000, MAT_GLASS = 4000, MAT_SILVER = 2000)
	build_path = /obj/item/defibrillator/compact
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
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
	build_path = /obj/item/sensor_device
	category = list("Medical")

/datum/design/mmi
	name = "Man-Machine Interface"
	desc = "A compact, highly portable self-contained life support system, capable of housing a single brain and allowing it to seamlessly interface with whatever it is installed into."
	id = "mmi"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 2)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	construction_time = 75
	build_path = /obj/item/mmi
	category = list("Medical")

/datum/design/robotic_brain
	name = "Robotic Brain"
	desc = "The latest in non-sapient Artificial Intelligences."
	id = "mmi_robotic"
	req_tech = list("programming" = 5, "biotech" = 4, "plasmatech" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 1700, MAT_GLASS = 1350, MAT_GOLD = 500) //Gold, because SWAG.
	construction_time = 75
	build_path = /obj/item/mmi/robotic_brain
	category = list("Medical")

/datum/design/mmi_radio_upgrade
	name = "Man-Machine Interface Radio Upgrade"
	desc = "Enables radio capability on MMIs when either installed directly on the MMI, or through a cyborg's chassis."
	id = "mmi_radio_upgrade"
	req_tech = list("programming" = 3, "biotech" = 2, "engineering" = 2)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 200)
	construction_time = 50
	build_path = /obj/item/mmi_radio_upgrade
	category = list("Medical")

/datum/design/nanopaste
	name = "Nanopaste"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	id = "nanopaste"
	req_tech = list("materials" = 3, "engineering" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 7000, MAT_GLASS = 7000)
	build_path = /obj/item/stack/nanopaste
	category = list("Medical")

/datum/design/skin_1
	name = "level-1 synthetic skin plate"
	desc = "A sheet of level-1 synthetic skin plating. Used as a cheap covering for cybernetic organs, is able to match the colour of the limb but not the texture."
	id = "skin_1"
	req_tech = list("biotech" = 1, "materials" = 1)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 20
	materials = list(MAT_METAL = 1000, MAT_GLASS = 500)
	build_path = /obj/item/stack/synthetic_skin
	category = list("Medical")

/datum/design/skin_2
	name = "level-2 synthetic skin patch"
	desc = "A sealed patch of synthetic skin. An improvement over the basic version, more water resistant and less prone to peeling off."
	id = "skin_2"
	req_tech = list("biotech" = 5, "materials" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000, MAT_TITANIUM = 250)
	build_path = /obj/item/stack/synthetic_skin/level_2
	category = list("Medical")

/datum/design/skin_3
	name = "level-3 synthetic skin foam"
	desc = "A nanite foam injector meeting the requirements of level-3 synthetic skin. The best one can buy, best used to hide major cybernetic alterations, for beauty or for infiltration."
	id = "skin_3"
	req_tech = list("biotech" = 7, "materials" = 7)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 2500, MAT_GLASS = 2000, MAT_TITANIUM = 500, MAT_BLUESPACE = 250)
	build_path = /obj/item/stack/synthetic_skin/level_3
	category = list("Medical")

/datum/design/reagent_scanner
	name = "Reagent Scanner"
	desc = "A device for identifying chemicals."
	id = "reagent_scanner"
	req_tech = list("magnets" = 2, "plasmatech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 300, MAT_GLASS = 200)
	build_path = /obj/item/reagent_scanner
	category = list("Medical")

/datum/design/scalpel_laser1
	name = "Basic Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks basic and could be improved."
	id = "scalpel_laser1"
	req_tech = list("biotech" = 2, "materials" = 2, "magnets" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500)
	build_path = /obj/item/scalpel/laser/laser1
	category = list("Medical")

/datum/design/scalpel_laser2
	name = "Improved Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks somewhat advanced."
	id = "scalpel_laser2"
	req_tech = list("biotech" = 3, "materials" = 4, "magnets" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_SILVER = 1000)
	build_path = /obj/item/scalpel/laser/laser2
	category = list("Medical")

/datum/design/scalpel_laser3
	name = "Advanced Laser Scalpel"
	desc = "A scalpel augmented with a directed laser, for more precise cutting without blood entering the field. This one looks to be the pinnacle of precision energy cutlery!"
	id = "scalpel_laser3"
	req_tech = list("biotech" = 4, "materials" = 6, "magnets" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500, MAT_SILVER = 1000, MAT_GOLD = 1000)
	build_path = /obj/item/scalpel/laser/laser3
	category = list("Medical")

/datum/design/scalpel_manager
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
	build_path = /obj/item/scalpel/laser/alien
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
	build_path = /obj/item/fix_o_vein/alien
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_SILVER = 1500, MAT_PLASMA = 500, MAT_TITANIUM = 1500)
	category = list("Medical")

/datum/design/dissector
	name = "Dissection Manager"
	desc = "An advanced handheld device that assists with the preparation and removal of non-standard alien organs."
	id = "dissection_manager"
	req_tech = list("biotech" = 3, "materials" = 3,  "programming" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1500)
	build_path = /obj/item/dissector
	category = list("Medical")

/datum/design/improved_dissector
	name = "Improved Dissection Manager"
	desc = "An advanced handheld device that assists with the preparation and removal of non-standard alien organs. This one has had several improvements applied to it."
	id = "dissection_manager_upgraded"
	req_tech = list("biotech" = 7, "materials" = 6,  "engineering" = 6)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 4000, MAT_GLASS = 2000, MAT_SILVER = 1500, MAT_GOLD = 2000)
	build_path = /obj/item/dissector/upgraded
	category = list("Medical")

// allows for perfect dissections, should be very hard to obtain.
/datum/design/alien_dissector
	name = "Alien Dissection Manager"
	desc = "A tool of alien origin, capable of near impossible levels of precision during dissections."
	id = "dissection_manager_alien"
	req_tech = list("biotech" = 7, "materials" = 7, "abductor" = 4)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 6000, MAT_GLASS = 4500, MAT_DIAMOND = 3000, MAT_TITANIUM = 4000, MAT_PLASMA = 4000)
	build_path = /obj/item/dissector/alien
	category = list("Medical")

/////////////////////////////////////////
//////////Cybernetic Implants////////////
/////////////////////////////////////////

/datum/design/cyberimp_welding
	name = "Welding Shield Implant"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	id = "ci-welding"
	req_tech = list("materials" = 4, "biotech" = 4, "engineering" = 5, "plasmatech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 600, MAT_GLASS = 400)
	build_path = /obj/item/organ/internal/eyes/cybernetic/shield
	category = list("Medical")

/datum/design/cyberimp_breather
	name = "Breathing Tube Implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	id = "ci-breather"
	req_tech = list("materials" = 2, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 35
	materials = list(MAT_METAL = 600, MAT_GLASS = 250)
	build_path = /obj/item/organ/internal/cyberimp/mouth/breathing_tube
	category = list("Medical")

/datum/design/cyberimp_surgical
	name = "Surgical Arm Implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	id = "ci-surgey"
	req_tech = list("materials" = 3, "engineering" = 3, "biotech" = 3, "programming" = 2, "magnets" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/surgery
	category = list("Medical")

/datum/design/cyberimp_toolset
	name = "Toolset Arm Implant"
	desc = "A stripped-down version of an engineering cyborg toolset, designed to be installed on subject's arm."
	id = "ci-toolset"
	req_tech = list("materials" = 3, "engineering" = 4, "biotech" = 4, "powerstorage" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/toolset
	category = list("Medical")

/datum/design/cyberimp_cargo
	name = "Cargo Arm Implant"
	desc = "A set of everything a cargo technician needs to have to do their job, besides a forklift. Designed to be installed on subject's arm."
	id = "ci-cargo"
	req_tech = list("materials" = 3, "engineering" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/cargo
	category = list("Medical")

/datum/design/cyberimp_janitorial
	name = "Janitorial Toolset Implant"
	desc = "A set of janitorial tools hidden behind a concealed panel on the user's arm."
	id = "ci-janitorial"
	req_tech = list("materials" = 3, "engineering" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/janitorial
	category = list("Medical")

/datum/design/cyberimp_botanical
	name = "Botanical Toolset Implant"
	desc = "A set of botanical tools hidden behind a concealed panel on the user's arm."
	id = "ci-botanical"
	req_tech = list("materials" = 3, "engineering" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/botanical
	category = list("Medical")

/datum/design/cyberimp_shell_launcher
	name = "Shell Launch System Implant"
	desc = "A mounted, single-shot housing for a shell launch cannon; capable of firing twelve-gauge shotgun shells."
	id = "ci-shell_launcher"
	req_tech = list("materials" = 7, "engineering" = 5, "combat" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 2500, MAT_GLASS = 1500, MAT_SILVER = 1500)
	construction_time = 20 SECONDS
	build_path = /obj/item/organ/internal/cyberimp/arm/shell_launcher
	category = list("Medical")

/datum/design/cyberimp_razorwire_spool
	name = "Razorwire Spool Arm Implant"
	desc = "A long length of monomolecular filament, built into the back of your hand. \
		Impossibly thin and flawlessly sharp, it should slice through organic materials with no trouble; \
		even from a few steps away. However, results against anything more durable will heavily vary."
	id = "ci-razorwire-spool"
	req_tech = list("combat" = 6, "biotech" = 6, "syndicate" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 5000, MAT_SILVER = 2000, MAT_DIAMOND = 2000, MAT_BLUESPACE = 2000)
	construction_time = 10 SECONDS
	build_path = /obj/item/organ/internal/cyberimp/arm/razorwire
	category = list("Medical")

/datum/design/cyberimp_sensory_enhancer
	name = "Qani-Laaca Sensory Computer Implant"
	desc = "An experimental implant replacing the spine of organics. When activated, it can give a temporary boost to mental processing speed, \
		which many users perceive as a slowing of time and quickening of their ability to act. Due to its nature, it is incompatible with \
		systems that heavily influence the user's nervous system, like the central nervous system rebooter. \
		As a bonus effect, you are immune to the burst of heart damage that comes at the end of mephedrone usage, as the computer is able to regulate \
		your heart's rhythm back to normal after its use."
	id = "ci-sensory-enhancer"
	req_tech = list("combat" = 7, "biotech" = 7, "syndicate" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 10000, MAT_SILVER = 2000, MAT_PLASMA = 10000, MAT_DIAMOND = 4000, MAT_BLUESPACE = 4000)
	construction_time = 10 SECONDS
	build_path = /obj/item/organ/internal/cyberimp/brain/sensory_enhancer/rnd
	category = list("Medical")

/datum/design/cyberimp_toolset_abductor
	name = "Abductor Toolset Implant"
	desc = "An alien toolset, designed to be installed on the subject's arm."
	id = "ci-hacking"
	req_tech = list("materials" = 6, "engineering" = 6, "plasmatech" = 6, "abductor" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 20000, MAT_SILVER = 10000, MAT_PLASMA = 9000, MAT_TITANIUM = 8000, MAT_DIAMOND = 8000)
	construction_time = 200
	build_path = /obj/item/organ/internal/cyberimp/arm/toolset_abductor
	category = list("Medical")

/datum/design/cyberimp_janitorial_abductor
	name = "Abductor Janitorial Toolset Implant"
	desc = "An alien janitorial toolset, designed to be installed on the subject's arm."
	id = "ci-jani-abductor"
	req_tech = list("materials" = 6, "engineering" = 6, "biotech" = 6, "abductor" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 20000, MAT_SILVER = 10000, MAT_PLASMA = 9000, MAT_TITANIUM = 8000, MAT_DIAMOND = 8000)
	construction_time = 20 SECONDS
	build_path = /obj/item/organ/internal/cyberimp/arm/janitorial_abductor
	category = list("Medical")

/datum/design/cyberimp_surgical_abductor
	name = "Abductor Surgical Toolset Implant"
	desc = "An alien surgical toolset, designed to be installed on the subject's arm."
	id = "ci-med-abductor"
	req_tech = list("materials" = 6, "magnets" = 6, "biotech" = 6, "abductor" = 3)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 20000, MAT_SILVER = 10000, MAT_PLASMA = 9000, MAT_TITANIUM = 8000, MAT_DIAMOND = 8000)
	construction_time = 20 SECONDS
	build_path = /obj/item/organ/internal/cyberimp/arm/surgical_abductor
	category = list("Medical")

/datum/design/cyberimp_jani_hud
	name = "Janitor HUD Implant"
	desc = "These cybernetic eye implants will display a filth HUD over everything you see. Wiggle eyes to control."
	id = "ci-janihud"
	req_tech = list("materials" = 5, "engineering" = 4, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 5 SECONDS
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/jani
	category = list("Medical")

/datum/design/cyberimp_diagnostic_hud
	name = "Diagnostic HUD Implant"
	desc = "These cybernetic eye implants will display a diagnostic HUD over everything you see. Wiggle eyes to control."
	id = "ci-diaghud"
	req_tech = list("materials" = 5, "engineering" = 4, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/diagnostic
	category = list("Medical")

/datum/design/cyberimp_employment_hud
	name = "Employment HUD Implant"
	desc = "These cybernetic eyes will display an employment HUD over everything you see. Wiggle eyes to control."
	id = "ci-skillhud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 5 SECONDS
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/skill
	category = list("Medical")

/datum/design/cyberimp_medical_hud
	name = "Medical HUD Implant"
	desc = "These cybernetic eyes will display a medical HUD over everything you see. Wiggle eyes to control."
	id = "ci-medhud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/medical
	category = list("Medical")

/datum/design/cyberimp_hydroponics_hud
	name = "Hydroponic HUD Implant"
	desc = "These cybernetic eye implants will display a hydroponics HUD over everything you see. Wiggle eyes to control."
	id = "ci-hydrohud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4, "magnets" = 3)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 5 SECONDS
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 700, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/hydroponic
	category = list("Medical")

/datum/design/cyberimp_security_hud
	name = "Security HUD Implant"
	desc = "These cybernetic eyes will display a security HUD over everything you see. Wiggle eyes to control."
	id = "ci-sechud"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4, "combat" = 3)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 750, MAT_GOLD = 750)
	build_path = /obj/item/organ/internal/cyberimp/eyes/hud/security
	category = list("Medical")

/datum/design/cyberimp_meson
	name = "Meson Scanner Implant"
	desc = "These cybernetic eyes will allow you to see the structural layout of the station, and, well, everything else."
	id = "ci-mesonhud"
	req_tech = list("materials" = 4, "biotech" = 4, "engineering" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500, MAT_GOLD = 300)
	build_path = /obj/item/organ/internal/eyes/cybernetic/meson
	category = list("Medical")

/datum/design/cyberimp_xray
	name = "X-Ray Implant"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	id = "ci-xray"
	req_tech = list("materials" = 7, "programming" = 5, "biotech" = 8, "magnets" = 5,"plasmatech" = 6)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_URANIUM = 1000, MAT_DIAMOND = 1000, MAT_BLUESPACE = 1000)
	build_path = /obj/item/organ/internal/eyes/cybernetic/xray
	category = list("Medical")

/datum/design/cyberimp_thermals
	name = "Thermals Implant"
	desc = "These cybernetic eyes will give you Thermal vision. Vertical slit pupil included."
	id = "ci-thermals"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 7, "magnets" = 5,"plasmatech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_DIAMOND = 2000)
	build_path = /obj/item/organ/internal/eyes/cybernetic/thermals
	category = list("Medical")

/datum/design/cyberimp_scope
	name = "Kaleido Optics Implant"
	desc = "These cybernetic eye implants will let you zoom in on far away objects. Many users find it disorienting, and find it hard to interact with things near them when active."
	id = "ci-scope"
	req_tech = list("materials" = 6, "programming" = 4, "biotech" = 7, "magnets" = 5,"plasmatech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 600, MAT_GOLD = 600, MAT_PLASMA = 1000, MAT_DIAMOND = 2000)
	build_path = /obj/item/organ/internal/eyes/cybernetic/scope
	category = list("Medical")

/datum/design/cyberimp_antidrop
	name = "Anti-Drop Implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	id = "ci-antidrop"
	req_tech = list("materials" = 5, "programming" = 6, "biotech" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 400, MAT_GOLD = 400)
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_drop
	category = list("Medical")

/datum/design/cyberimp_antistun
	name = "CNS Rebooter Implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when fatigued. Incompatible with the Neural Jumpstarter."
	id = "ci-antistun"
	req_tech = list("materials" = 6, "programming" = 5, "biotech" = 6)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 1000)
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_stam
	category = list("Medical")

/datum/design/cyberimp_antisleep
	name = "Neural Jumpstarter Implant"
	desc = "This implant will automatically attempt to jolt you awake when it detects you have fallen unconscious. Has a short cooldown, incompatible with the CNS Rebooter."
	id = "ci-antisleep"
	req_tech = list("materials" = 6, "programming" = 5, "biotech" = 6)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 500, MAT_GOLD = 1000)
	build_path = /obj/item/organ/internal/cyberimp/brain/anti_sleep
	category = list("Medical")

/datum/design/cyberimp_clownvoice
	name = "Comical Implant"
	desc = "<span class='sans'>Uh oh.</span>"
	id = "ci-clownvoice"
	req_tech = list("materials" = 2, "biotech" = 2)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 200, MAT_GLASS = 200, MAT_BANANIUM = 200)
	build_path = /obj/item/organ/internal/cyberimp/brain/clown_voice
	category = list("Medical")

/datum/design/cyberimp_nutriment
	name = "Nutriment Pump Implant"
	desc = "When you're starving, this implant will synthesize a small amount of nutriment and pump it into your bloodstream."
	id = "ci-nutriment"
	req_tech = list("materials" = 3, "powerstorage" = 4, "biotech" = 3)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 40
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_GOLD = 500)
	build_path = /obj/item/organ/internal/cyberimp/chest/nutriment
	category = list("Medical")

/datum/design/cyberimp_nutriment_plus
	name = "Nutriment Pump Implant PLUS"
	desc = "When you're hungry, this implant will synthesize a small amount of nutriment and pump it into your bloodstream."
	id = "ci-nutrimentplus"
	req_tech = list("materials" = 5, "powerstorage" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 50
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_GOLD = 500, MAT_URANIUM = 750)
	build_path = /obj/item/organ/internal/cyberimp/chest/nutriment/plus
	category = list("Medical")

/datum/design/cyberimp_reviver
	name = "Reviver Implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	id = "ci-reviver"
	req_tech = list("materials" = 5, "programming" = 6, "biotech" = 7)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 800, MAT_GLASS = 800, MAT_GOLD = 300, MAT_URANIUM = 500)
	build_path = /obj/item/organ/internal/cyberimp/chest/reviver
	category = list("Medical")

/datum/design/cyberimp_wire_interface
	name = "Wire Interface Implant"
	desc = "This cybernetic brain implant will allow you to interface with electrical currents to sense the purpose of wires."
	id = "ci-wire_interface"
	req_tech = list("materials" = 5, "programming" = 4, "biotech" = 4)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 60
	materials = list(MAT_METAL = 600, MAT_GLASS = 600, MAT_SILVER = 400, MAT_GOLD = 400)
	build_path = /obj/item/organ/internal/cyberimp/brain/wire_interface
	category = list("Medical")

/datum/design/bluespace_anchor
	name = "Bluespace Anchor Implant"
	desc = "This large cybernetic implant anchors you in bluespace, preventing almost any teleportation effects from working. It disrupts GPS systems however."
	id = "bluespace_anchor_implant"
	req_tech = list("bluespace" = 7, "biotech" = 5)
	build_type = PROTOLATHE | MECHFAB
	construction_time = 6 SECONDS
	materials = list(MAT_METAL = 10000, MAT_BLUESPACE = 2000)
	build_path = /obj/item/organ/internal/cyberimp/chest/bluespace_anchor
	category = list("Medical")

/////////////////////////////////////////
////////////Regular Implants/////////////
/////////////////////////////////////////

/datum/design/bio_chip_pad
	name = "Bio-chip Pad"
	desc = "Used to modify bio-chips."
	id = "biochip_pad"
	req_tech = list("materials" = 3, "biotech" = 4, "programming" = 3)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 2000, MAT_GLASS = 1000)
	build_path = /obj/item/bio_chip_pad
	category = list("Medical")

/datum/design/bio_chip_implanter
	name = "Bio-chip Implanter"
	desc = "A sterile automatic bio-chip injector."
	id = "implanter"
	req_tech = list("materials" = 2, "biotech" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 600, MAT_GLASS = 200)
	build_path = /obj/item/bio_chip_implanter
	category = list("Medical")

/datum/design/bio_chip_case
	name = "Bio-chip Case"
	desc = "A glass case containing a bio-chip."
	id = "implantcase"
	req_tech = list("biotech" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500)
	build_path = /obj/item/bio_chip_case
	category = list("Medical")

/datum/design/bio_chip_chem
	name = "Chemical Bio-chip Case"
	desc = "A glass case containing a bio-chip."
	id = "implant_chem"
	req_tech = list("materials" = 3, "biotech" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 700)
	build_path = /obj/item/bio_chip_case/chem
	category = list("Medical")

/datum/design/bio_chip_sad_trombone
	name = "Sad Trombone Bio-chip Case"
	desc = "Makes death amusing."
	id = "implant_trombone"
	req_tech = list("materials" = 3, "biotech" = 5)
	build_type = PROTOLATHE
	materials = list(MAT_GLASS = 500, MAT_BANANIUM = 500)
	build_path = /obj/item/bio_chip_case/sad_trombone
	category = list("Medical")

/datum/design/bio_chip_tracking
	name = "Tracking Bio-chip Case"
	desc = "A glass case containing a bio-chip."
	id = "implant_tracking"
	req_tech = list("materials" = 2, "biotech" = 3, "magnets" = 3, "programming" = 2)
	build_type = PROTOLATHE
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	build_path = /obj/item/bio_chip_case/tracking
	category = list("Medical")

//Cybernetic organs

/datum/design/cybernetic_eyes
	name = "Cybernetic Eyes"
	desc = "A cybernetic pair of eyes."
	id = "cybernetic_eyes"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/eyes/cybernetic
	category = list("Medical")

/datum/design/cybernetic_ears
	name = "Cybernetic Ears"
	desc = "A cybernetic pair of ears."
	id = "cybernetic_ears"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/ears/cybernetic
	category = list("Medical")

/datum/design/cybernetic_liver
	name = "Cybernetic Liver"
	desc = "A cybernetic liver."
	id = "cybernetic_liver"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/liver/cybernetic
	category = list("Medical")

/datum/design/cybernetic_kidneys
	name = "Cybernetic Kidneys"
	desc = "A cybernetic pair of kidneys."
	id = "cybernetic_kidneys"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/kidneys/cybernetic
	category = list("Medical")

/datum/design/cybernetic_heart
	name = "Cybernetic Heart"
	desc = "A cybernetic heart."
	id = "cybernetic_heart"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/heart/cybernetic
	category = list("Medical")

/datum/design/cybernetic_heart_u
	name = "Upgraded Cybernetic Heart"
	desc = "An upgraded cybernetic heart."
	id = "cybernetic_heart_u"
	req_tech = list("biotech" = 5, "materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/heart/cybernetic/upgraded
	category = list("Medical")

/datum/design/cybernetic_lungs
	name = "Cybernetic Lungs"
	desc = "A pair of cybernetic lungs."
	id = "cybernetic_lungs"
	req_tech = list("biotech" = 4, "materials" = 4)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/lungs/cybernetic
	category = list("Medical")

/datum/design/cybernetic_lungs_u
	name = "Upgraded Cybernetic Lungs"
	desc = "A pair of upgraded cybernetic lungs."
	id = "cybernetic_lungs_u"
	req_tech = list("biotech" = 5, "materials" = 5, "engineering" = 5)
	build_type = PROTOLATHE | MECHFAB
	materials = list(MAT_METAL = 500, MAT_GLASS = 500, MAT_SILVER = 500)
	construction_time = 60
	build_path = /obj/item/organ/internal/lungs/cybernetic/upgraded
	category = list("Medical")
