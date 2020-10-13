
//Current rate: 132500 research points in 90 minutes
//Current cargo price: 250000 points for fullmaxed R&D.

//Base Node
/datum/techweb_node/base
	id = "base"
	starting_node = TRUE
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	design_ids = list("basic_matter_bin", "basic_cell", "basic_sensor", "basic_capacitor", "basic_micro_laser", "micro_mani",
	"destructive_analyzer", "circuit_imprinter", "experimentor", "rdconsole", "design_disk", "rdserver", "rdservercontrol", "mechfab", "protolathe", "podfab")
	//Default research tech, prevents bricking

/////////////////////////Biotech/////////////////////////
/datum/techweb_node/biotech
	id = "biotech"
	display_name = "Biological Technology"
	description = "What makes us tick."	//the MC, silly!
	prereq_ids = list("base")
	design_ids = list("reagent_scanner", "chem_heater", "chem_master", "chem_dispenser", "sleeper", "pandemic", "breathmask", "scalpel_laser1")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_biotech
	id = "adv_biotech"
	display_name = "Advanced Biotechnology"
	description = "Advanced Biotechnology"
	prereq_ids = list("biotech")
	design_ids = list("adv_reagent_scanner", "scalpel_laser2", "defib", "defib_mount", "handheld_defib", "healthanalyzer_upgrade", "sensor_device", "nanopaste")
	research_cost = 2500
	export_price = 10000

/////////////////////////data theory tech/////////////////////////
/datum/techweb_node/datatheory //Computer science
	id = "datatheory"
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prereq_ids = list("base")
	design_ids = list("datadisk", "digitalcamera")
	research_cost = 2500
	export_price = 10000

/////////////////////////engineering tech/////////////////////////
/datum/techweb_node/engineering
	id = "engineering"
	description = "Modern Engineering Technology."
	display_name = "Industrial Engineering"
	prereq_ids = list("base")
	design_ids = list("solarcontrol", "recharger", "powermonitor", "rped", "pacman", "adv_capacitor", "adv_sensor", "emitter", "high_cell", "adv_matter_bin",
	"atmosalerts", "air_management", "recycler", "autolathe", "high_micro_laser", "nano_mani", "weldingmask", "mesons", "thermomachine", "tesla_coil", "grounding_rod",
	"emergencyoxygen", "extendedoxygen", "doubleoxygen", "oxygentank")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_engi
	id = "adv_engi"
	description = "Advanced Engineering research"
	display_name = "Advanced Engineering"
	prereq_ids = list("engineering", "emp_basic")
	design_ids = list("diagnostic_hud", "magboots", "GAC", "tankcontrol")
	research_cost = 2500
	export_price = 10000

/////////////////////////Bluespace tech/////////////////////////
/datum/techweb_node/bluespace_basic //Bluespace-memery
	id = "bluespace_basic"
	display_name = "Basic Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prereq_ids = list("base")
	design_ids = list("beacon", "xenobioconsole", "telesci_Gps")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_bluespace
	id = "adv_bluespace"
	display_name = "Advanced Bluespace Research"
	description = "Deeper understanding of how the Bluespace dimension works"
	prereq_ids = list("practical_bluespace", "high_efficiency")
	design_ids = list("bluespace_matter_bin", "femto_mani", "triphasic_scanning", "tele_station", "tele_hub", "quantumpad", "telepad_beacon",
	"teleconsole", "bag_holding", "bluespace_crystal", "wormholeprojector", "brpd", "bluespace_belt", "bluespace_belt_holder", "tele_perma")
	research_cost = 2500
	export_price = 10000

/////////////////////////plasma tech/////////////////////////
/datum/techweb_node/basic_plasma
	id = "basic_plasma"
	display_name = "Basic Plasma Research"
	description = "Research into the mysterious and dangerous substance, plasma."
	prereq_ids = list("engineering")
	design_ids = list("mech_generator")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_plasma
	id = "adv_plasma"
	display_name = "Advanced Plasma Research"
	description = "Research on how to fully exploit the power of plasma."
	prereq_ids = list("basic_plasma")
	design_ids = list("mech_plasma_cutter")
	research_cost = 2500
	export_price = 10000

/////////////////////////robotics tech/////////////////////////
/datum/techweb_node/robotics
	id = "robotics"
	display_name = "Basic Robotics Research"
	description = "Programmable machines that make our lives lazier."
	prereq_ids = list("base")
	design_ids = list("paicard")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_robotics
	id = "adv_robotics"
	display_name = "Advanced Robotics Research"
	description = "It can even do the dishes!"
	prereq_ids = list("robotics")
	design_ids = list("borg_upgrade_diamonddrill", "mmi_radio_upgrade", "integrated_robotic_chassis")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/ipc_repair
	id = "IPC repair"
	display_name = "IPC Repair"
	description = "Keep out of harm"
	prereq_ids = list("robotics")
	design_ids = list("ipc_head", "ipc_cell", "ipc_charger", "ipc_optics", "ipc_microphone")
	research_cost = 2500
	export_price = 10000

/////////////////////////EMP tech/////////////////////////
/datum/techweb_node/emp_basic //EMP tech for some reason
	id = "emp_basic"
	display_name = "Electromagnetic Theory"
	description = "Study into usage of frequencies in the electromagnetic spectrum."
	prereq_ids = list("base")
	design_ids = list("holosign", "holopad")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/emp_adv
	id = "emp_adv"
	display_name = "Advanced Electromagnetic Theory"
	prereq_ids = list("emp_basic")
	design_ids = list("ultra_micro_laser")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/emp_super
	id = "emp_super"
	display_name = "Quantum Electromagnetic Technology"	//bs
	description = "Even better electromagnetic technology"
	prereq_ids = list("emp_adv")
	design_ids = list("quadultra_micro_laser")
	research_cost = 2500
	export_price = 10000

/////////////////////////Clown + Mime tech/////////////////////////
/datum/techweb_node/clown
	id = "clown"
	display_name = "Clown Technology"
	description = "Honk?!"
	prereq_ids = list("base")
	design_ids = list("air_horn", "honker_main", "honker_peri", "honker_targ", "honk_chassis", "honk_head", "honk_torso", "honk_left_arm", "honk_right_arm",
	"honk_left_leg", "honk_right_leg", "mech_banana_mortar", "mech_mousetrap_mortar", "mech_honker")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mime
	id = "mime"
	display_name = "Mime Technology"
	description = "..."
	prereq_ids = list("base")
	design_ids = list("mech_mrcd", "mech_silentgun", "reticence_main", "reticence_peri", "reticence_targ", "reticence_chassis", "reticence_torso", "reticence_head",
	"reticence_left_arm", "reticence_right_arm", "reticence_left_leg", "reticence_right_leg")
	research_cost = 2500
	export_price = 10000

////////////////////////Computer tech////////////////////////
/datum/techweb_node/comptech
	id = "comptech"
	display_name = "Computer Consoles"
	description = "Computers and how they work."
	prereq_ids = list("datatheory")
	design_ids = list("supplycomp", "ordercomp", "aifixer", "crewconsole", "comconsole", "idcardconsole", "operating",
	"seccamera", "spacepodc", "brigcells", "sm_monitor", "message_monitor", "dronecontrol", "pod")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/computer_board_gaming
	id = "computer_board_gaming"
	display_name = "Arcade Games"
	description = "For the slackers on the station."
	prereq_ids = list("comptech")
	design_ids = list("arcademachineorion", "arcademachinebattle", "gameboard", "prize_counter", "clawgame")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/comp_recordkeeping
	id = "comp_recordkeeping"
	display_name = "Computerized Recordkeeping"
	description = "Organized record databases and how they're used."
	prereq_ids = list("comptech")
	design_ids = list("secdata", "med_data", "prisonmanage")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/telecomms
	id = "telecomms"
	display_name = "Telecommunications Technology"
	description = "Subspace transmission technology for near-instant communications devices."
	prereq_ids = list("comptech", "bluespace_basic")
	research_cost = 2500
	export_price = 10000
	design_ids = list("s-relay", "s-hub")

/datum/techweb_node/integrated_HUDs
	id = "integrated_HUDs"
	display_name = "Integrated HUDs"
	description = "The usefulness of computerized records, projected straight onto your eyepiece!"
	prereq_ids = list("comp_recordkeeping", "emp_basic")
	design_ids = list("health_hud", "security_hud", "diagnostic_hud", "scigoggles", "skills_hud", "hydroponic_hud")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/NVGtech
	id = "NVGtech"
	display_name = "Night Vision Technology"
	description = "Allows seeing in the dark without actual light!"
	prereq_ids = list("integrated_HUDs", "adv_engi", "emp_adv")
	design_ids = list("health_hud_night", "security_hud_night", "diagnostic_hud_night", "night_vision_goggles", "nvgmesons", "hydroponic_hud_night", "nvscigoggles")
	research_cost = 2500
	export_price = 10000

////////////////////////AI & Cyborg tech////////////////////////
/datum/techweb_node/neural_programming
	id = "neural_programming"
	display_name = "Neural Programming"
	description = "Study into networks of processing units that mimic our brains."
	prereq_ids = list("biotech", "datatheory")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mmi
	id = "mmi"
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	prereq_ids = list("biotech", "neural_programming")
	design_ids = list("mmi")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/roboticbrain
	id = "roboticbrain"
	display_name = "Robotic brain Brain"
	description = "Applied usage of neural technology allowing for autonomous AI units based on special metallic cubes with conductive and processing circuits."
	prereq_ids = list("mmi", "neural_programming")
	design_ids = list("mmi_robotic")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/cyborg
	id = "cyborg"
	display_name = "Cyborg Construction"
	description = "Sapient robots with preloaded tool modules and programmable laws."
	prereq_ids = list("mmi", "robotics")
	research_cost = 2500
	export_price = 10000
	design_ids = list("robocontrol", "sflash", "borg_suit", "borg_head", "borg_chest", "borg_r_arm", "borg_l_arm", "borg_r_leg", "borg_l_leg", "borgupload",
	"cyborgrecharger", "borg_upgrade_restart", "borg_upgrade_rename", "borg_upgrade_reset", "cyborg_analyzer", "borg_binary_communication", "borg_radio",
	"borg_diagnosis_unit", "borg_camera", "borg_armor", "borg_actuator")

/datum/techweb_node/cyborg_upg_util
	id = "cyborg_upg_util"
	display_name = "Cyborg Upgrades: Utility"
	description = "Utility upgrades for cybogs."
	prereq_ids = list("engineering", "cyborg")
	design_ids = list("borg_upgrade_holding", "borg_upgrade_lavaproof", "borg_upgrade_thrusters", "borg_upgrade_selfrepair")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/cyborg_upg_combat
	id = "cyborg_upg_combat"
	display_name = "Cyborg Upgrades: Combat"
	description = "Military grade upgrades for cyborgs."
	prereq_ids = list("adv_robotics", "adv_engi")
	design_ids = list("borg_upgrade_vtec", "borg_upgrade_disablercooler")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/ai
	id = "ai"
	display_name = "Artificial Intelligence"
	description = "AI unit research."
	prereq_ids = list("robotics", "neural_programming")
	design_ids = list("aicore", "safeguard_module", "onecrewmember_module", "protectstation_module", "quarantine_module", "oxygen_module", "freeform_module",
	"reset_module", "purge_module", "freeformcore_module", "asimov_module", "paladin_module", "tyrant_module", "corporate_module", "antimov_module", "crewsimov_module",
	"mecha_tracking_ai_control", "aiupload", "intellicard")
	research_cost = 2500
	export_price = 10000

////////////////////////Medical////////////////////////
/datum/techweb_node/cloning
	id = "cloning"
	display_name = "Genetic Engineering"
	description = "We have the technology to make him."
	prereq_ids = list("biotech")
	design_ids = list("clonecontrol", "clonepod", "clonescanner", "scan_console")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/cryotech
	id = "cryotech"
	display_name = "Cryostasis Technology"
	description = "Smart freezing of objects to preserve them!"
	prereq_ids = list("adv_engi", "emp_basic", "biotech")
	design_ids = list("splitbeaker", "cryotube", "cryo_Grenade")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/subdermal_implants
	id = "subdermal_implants"
	display_name = "Subdermal Implants"
	description = "Electronic implants buried beneath the skin."
	prereq_ids = list("biotech")
	design_ids = list("implanter", "implantcase", "implant_chem", "implant_tracking")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/cyber_organs
	id = "cyber_organs"
	display_name = "Cybernetic Organs"
	description = "We have the technology to rebuild him."
	prereq_ids = list("adv_biotech", "cyborg")
	design_ids = list("cybernetic_heart", "cybernetic_liver", "cybernetic_eyes", "cybernetic_ears", "cybernetic_kidneys",
	"cybernetic_heart_u", "cybernetic_lungs", "cybernetic_lungs_u")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/cyber_implants
	id = "cyber_implants"
	display_name = "Cybernetic Implants"
	description = "Electronic implants that improve humans."
	prereq_ids = list("adv_biotech", "cyborg", "datatheory")
	design_ids = list("ci-nutriment", "ci-nutrimentplus", "ci-breather", "ci-welding", "ci-medhud", "ci-sechud", "ci-diaghud", "ci-mesonhud", "ci-clownvoice")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_cyber_implants
	id = "adv_cyber_implants"
	display_name = "Advanced Cybernetic Implants"
	description = "Upgraded and more powerful cybernetic implants."
	prereq_ids = list("neural_programming", "cyber_implants")
	design_ids = list("ci-toolset", "ci-surgery", "ci-reviver")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/combat_cyber_implants
	id = "combat_cyber_implants"
	display_name = "Combat Cybernetic Implants"
	description = "Military grade combat implants to improve performance."
	prereq_ids = list("adv_cyber_implants")	//Needs way more reqs.
	design_ids = list("ci-xray", "ci-thermals", "ci-antidrop", "ci-antistun")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/improved_surgery
	id = "improved_surgery"
	display_name = "Medical Surgical Upgrades"
	description = "Now with 25% less casualties."
	prereq_ids = list("biotech")
	design_ids = list("scalpel_laser3", "scalpel_manager")
	research_cost = 2500
	export_price = 10000

////////////////////////generic biotech////////////////////////
/datum/techweb_node/bio_process
	id = "bio_process"
	display_name = "Biological Processing"
	description = "From slimes to kitchens."
	prereq_ids = list("biotech")
	design_ids = list("smartfridge", "gibber", "deepfryer", "monkey_recycler", "processor", "gibber", "microwave")
	research_cost = 2500
	export_price = 10000

////////////////////////generic engineering////////////////////////
/datum/techweb_node/high_efficiency
	id = "high_efficiency"
	display_name = "High Efficiency Parts"
	description = "High Efficiency Parts"
	prereq_ids = list("engineering", "datatheory")
	design_ids = list("pico_mani", "super_matter_bin")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_power
	id = "adv_power"
	display_name = "Advanced Power Manipulation"
	description = "How to get more zap."
	prereq_ids = list("engineering")
	design_ids = list("smes", "super_cell", "hyper_cell", "super_capacitor", "superpacman", "mrspacman", "power_turbine", "power_turbine_console", "power_compressor")
	research_cost = 2500
	export_price = 10000

////////////////////////Tools////////////////////////
/datum/techweb_node/basic_mining
	id = "basic_mining"
	display_name = "Mining Technology"
	description = "Better than Efficiency V."
	prereq_ids = list("engineering")
	design_ids = list("drill", "superresonator", "triggermod", "damagemod", "cooldownmod", "rangemod", "ore_redemption", "mining_equipment_vendor")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_mining
	id = "adv_mining"
	display_name = "Advanced Mining Technology"
	description = "Efficiency Level 127"	//dumb mc references
	prereq_ids = list("basic_mining", "adv_engi", "adv_power", "adv_plasma")
	design_ids = list("drill_diamond", "jackhammer", "hypermod", "plasmacutter", "plasmacutter_adv", "hyperaoemod", "repeatermod", "resonatormod", "bountymod")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/practical_bluespace
	id = "practical_bluespace"
	display_name = "Applied Bluespace Research"
	description = "Using bluespace to make things faster and better."
	prereq_ids = list("bluespace_basic", "engineering")
	design_ids = list("bs_rped", "minerbag_holding", "bluespacebeaker", "phasic_sensor", "bluespace_closet")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/janitor
	id = "janitor"
	display_name = "Advanced Sanitation Technology"
	description = "Clean things better, faster, stronger, and harder!"
	prereq_ids = list("adv_engi")
	design_ids = list("advmop", "buffer", "blutrash", "light_replacer")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/botany
	id = "botany"
	display_name = "Botanical Engineering"
	description = "Botanical tools"
	prereq_ids = list("adv_engi", "biotech")
	design_ids = list("diskplantgene", "portaseeder", "plantgenes", "flora_gun", "hydro_tray", "biogenerator", "seed_extractor", "bodyscanner")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/exp_tools
	id = "exp_tools"
	display_name = "Experimental Tools"
	description = "Highly advanced construction tools."
	design_ids = list("exwelder", "jawsoflife", "handdrill")
	prereq_ids = list("adv_engi")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/bluespace_power
	id = "bluespace_power"
	display_name = "Bluespace Power Technology"
	description = "Even more powerful.. power!"
	prereq_ids = list("adv_power", "adv_bluespace")
	design_ids = list("bluespace_cell", "quadratic_capacitor")
	research_cost = 2500
	export_price = 10000

/////////////////////////weaponry tech/////////////////////////
/datum/techweb_node/weaponry
	id = "weaponry"
	display_name = "Weapon Development Technology"
	description = "Our researchers have found new to weaponize just about everything now."
	prereq_ids = list("engineering")
	design_ids = list("mag_oldsmg", "mag_oldsmg_ap", "mag_oldsmg_ic", "mag_oldsmg_tx")
	research_cost = 10000
	export_price = 10000

/datum/techweb_node/electric_weapons
	id = "electronic_weapons"
	display_name = "Electric Weapons"
	description = "Weapons using electric technology"
	prereq_ids = list("weaponry", "adv_power")
	design_ids = list("stunrevolver", "stunshell", "tele_shield")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/radioactive_weapons
	id = "radioactive_weapons"
	display_name = "Radioactive Weaponry"
	description = "Weapons using radioactive technology."
	prereq_ids = list("adv_engi", "weaponry")
	design_ids = list("nuclear_gun", "decloner")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/medical_weapons
	id = "medical_weapons"
	display_name = "Medical Weaponry"
	description = "Weapons using medical technology."
	prereq_ids = list("adv_biotech", "weaponry")
	design_ids = list("rapidsyringe")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/beam_weapons
	id = "beam_weapons"
	display_name = "Beam Weaponry"
	description = "Various basic beam weapons"
	prereq_ids = list("weaponry")
	design_ids = list("ioncarbine", "immolator")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_beam_weapons
	id = "adv_beam_weapons"
	display_name = "Advanced Beam Weaponry"
	description = "Various advanced beam weapons"
	prereq_ids = list("beam_weapons")
	design_ids = list("xray", "lasercannon")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/explosive_weapons
	id = "explosive_weapons"
	display_name = "Explosive & Pyrotechnical Weaponry"
	description = "If the light stuff just won't do it."
	prereq_ids = list("weaponry")
	design_ids = list("temp_gun", "large_Grenade", "pyro_Grenade", "adv_Grenade", "ppistol")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/tech_shell
	id = "tech_shell"
	display_name = "Technological Shells"
	description = "They're more technological than regular shot."
	prereq_ids = list("weaponry")
	design_ids = list("techshotshell")
	research_cost = 2500
	export_price = 10000

////////////////////////mech technology////////////////////////
/datum/techweb_node/mech
	id = "mecha"
	display_name = "Mechanical Exosuits"
	description = "Mechanized exosuits that are several magnitudes stronger and more powerful than the average human."
	prereq_ids = list("robotics", "adv_engi")
	design_ids = list("mecha_tracking", "mechacontrol", "mechapower", "mech_recharger", "ripley_chassis", "firefighter_chassis", "ripley_torso", "ripley_left_arm", "ripley_right_arm", "ripley_left_leg", "ripley_right_leg",
	"ripley_main", "ripley_peri", "mech_hydraulic_clamp")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_mecha
	id = "adv_mecha"
	display_name = "Mechanical Exosuits"
	description = "Mechanized exosuits that are several magnitudes stronger and more powerful than the average human."
	prereq_ids = list("adv_robotics", "mecha")
	design_ids = list("mech_repair_droid")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/odysseus
	id = "mecha_odysseus"
	display_name = "EXOSUIT: Odysseus"
	description = "Odysseus exosuit designs"
	prereq_ids = list("mecha")
	design_ids = list("odysseus_chassis", "odysseus_torso", "odysseus_head", "odysseus_left_arm", "odysseus_right_arm" ,"odysseus_left_leg", "odysseus_right_leg",
	"odysseus_main", "odysseus_peri")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/gygax
	id = "mech_gygax"
	display_name = "EXOSUIT: Gygax"
	description = "Gygax exosuit designs"
	prereq_ids = list("adv_mecha", "weaponry")
	design_ids = list("gygax_chassis", "gygax_torso", "gygax_head", "gygax_left_arm", "gygax_right_arm", "gygax_left_leg", "gygax_right_leg", "gygax_main",
	"gygax_peri", "gygax_targ", "gygax_armor")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/durand
	id = "mech_durand"
	display_name = "EXOSUIT: Durand"
	description = "Durand exosuit designs"
	prereq_ids = list("adv_mecha", "weaponry")
	design_ids = list("durand_chassis", "durand_torso", "durand_head", "durand_left_arm", "durand_right_arm", "durand_left_leg", "durand_right_leg", "durand_main",
	"durand_peri", "durand_targ", "durand_armor")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/phazon
	id = "mecha_phazon"
	display_name = "EXOSUIT: Phazon"
	description = "Phazon exosuit designs"
	prereq_ids = list("adv_mecha", "weaponry")
	design_ids = list("phazon_chassis", "phazon_torso", "phazon_head", "phazon_left_arm", "phazon_right_arm", "phazon_left_leg", "phazon_right_leg", "phazon_main",
	"phazon_peri", "phazon_targ", "phazon_armor")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_tools
	id = "mech_tools"
	display_name = "Basic Exosuit Equipment"
	description = "Various tools fit for basic mech units"
	prereq_ids = list("mecha", "engineering")
	design_ids = list("mech_drill", "mech_mscanner", "mech_extinguisher", "mech_cable_layer")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_voicemods
	id = "mech_voicemods"
	display_name = "Mecha Voice Modifications"
	description = "Change how your mecha screams at you for low power"
	prereq_ids = list("mecha", "engineering")
	design_ids = list("voice_standard", "voice_silent", "voice_nanotrasen")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/e_mech_voicemods
	id = "e_mech_voicemods"
	display_name = "Exotic Mecha Voice Modifications"
	description = "Why are we even researching these?!"
	prereq_ids = list("mech_voicemods", "clown", "syndicate_basic")
	design_ids = list("voice_honk", "voice_syndicate")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/adv_mecha_tools
	id = "adv_mecha_tools"
	display_name = "Advanced Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list("adv_mecha", "mech_tools", "adv_engi")
	design_ids = list("mech_rcd")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/med_mech_tools
	id = "med_mech_tools"
	display_name = "Medical Exosuit Equipment"
	description = "Tools for high level mech suits"
	prereq_ids = list("mecha", "adv_biotech", "mech_tools")
	design_ids = list("mech_sleeper", "mech_syringe_gun")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_modules
	id = "adv_mecha_modules"
	display_name = "Basic Exosuit Modules"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("adv_mecha", "adv_power")
	design_ids = list("mech_energy_relay", "mech_ccw_armor", "mech_proj_armor", "mech_generator_nuclear")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_scattershot
	id = "mecha_scattershot"
	display_name = "Exosuit Weapon (LBX AC 10 \"Scattershot\")"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "weaponry")
	design_ids = list("mech_scattershot")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_carbine
	id = "mech_carbine"
	display_name = "Exosuit Weapon (FNX-99 \"Hades\" Carbine)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "weaponry")
	design_ids = list("mech_carbine")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_stuns
	id = "mech_stuns"
	display_name = "Mecha Stun Weaponary"
	description = "Weapons to knock out, not wipe out"
	prereq_ids = list("mecha", "weaponry")
	design_ids = list("mech_bola", "mech_disabler")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_ion
	id = "mmech_ion"
	display_name = "Exosuit Weapon (MKIV Ion Heavy Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "weaponry", "emp_adv")
	design_ids = list("mech_ion")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_tesla
	id = "mech_tesla"
	display_name = "Exosuit Weapon (MKI Tesla Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "weaponry", "adv_power")
	design_ids = list("mech_tesla")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_laser
	id = "mech_laser"
	display_name = "Exosuit Weapon (CH-PL \"Firedart\" Laser)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("mecha", "beam_weapons")
	design_ids = list("mech_laser")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_laser_immolator
	id = "mech_laser_immolator"
	display_name = "Exosuit Weapon (ZFI Immolation Beam Gun)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("mecha", "beam_weapons")
	design_ids = list("mech_immolator")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_laser_heavy
	id = "mech_laser_heavy"
	display_name = "Exosuit Weapon (CH-LC \"Solaris\" Laser Cannon)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "weaponry", "adv_beam_weapons")
	design_ids = list("mech_laser_heavy")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_grenade_launcher
	id = "mech_grenade_launcher"
	display_name = "Exosuit Weapon (SGL-6 Grenade Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "explosive_weapons")
	design_ids = list("mech_grenade_launcher")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_missile_rack
	id = "mech_missile_rack"
	display_name = "Exosuit Weapon (SRM-8 Missile Rack)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "explosive_weapons")
	design_ids = list("mech_missile_rack")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/clusterbang_launcher
	id = "clusterbang_launcher"
	display_name = "Exosuit Module (SOB-3 Clusterbang Launcher)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "weaponry")
	design_ids = list("clusterbang_launcher")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_teleporter
	id = "mech_teleporter"
	display_name = "Exosuit Module (Teleporter Module)"
	description = "An advanced piece of mech Equipment"
	prereq_ids = list("mecha", "mech_tools", "adv_bluespace")
	design_ids = list("mech_teleporter")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_wormhole_gen
	id = "mech_wormhole_gen"
	display_name = "Exosuit Module (Localized Wormhole Generator)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "mech_tools", "adv_bluespace")
	design_ids = list("mech_wormhole_gen")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_gravpult
	id = "mech_gravpult"
	display_name = "Exosuit Module (Gravitational Catapult)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "mech_tools", "adv_bluespace")
	design_ids = list("mech_gravcatapult")
	research_cost = 2500
	export_price = 10000


/datum/techweb_node/mech_medjaws
	id = "mech_medjaws"
	display_name = "Exosuit Module (Rescue Jaw)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("mecha", "mech_tools", "adv_bluespace")
	design_ids = list("mech_medical_jaw")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_taser
	id = "mech_taser"
	display_name =  "Exosuit Weapon (PBT \"Pacifier\" Mounted Taser)"
	description = "A basic piece of mech weaponry"
	prereq_ids = list("mecha", "weaponry")
	design_ids = list("mech_taser")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_lmg
	id = "mech_lmg"
	display_name =  "Exosuit Weapon (\"Ultra AC 2\" LMG)"
	description = "An advanced piece of mech weaponry"
	prereq_ids = list("adv_mecha", "weaponry")
	design_ids = list("mech_lmg")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/mech_diamond_drill
	id = "mech_diamond_drill"
	display_name =  "Exosuit Diamond Drill"
	description = "A diamond drill fit for a large exosuit"
	prereq_ids = list("mecha", "adv_mining")
	design_ids = list("mech_diamond_drill")
	research_cost = 2500
	export_price = 10000

///// Misc Nodes /////
/datum/techweb_node/chef
	id = "chef"
	display_name = "Chef Research"
	description = "Dont forget to eat"
	prereq_ids = list("base")
	design_ids = list("oven", "grill", "candymaker", "reagentgrinder")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/security_misc
	id = "security_misc"
	display_name = "Misc. Security Research"
	description = "CC cannot provide a description"
	prereq_ids = list("base")
	// why the hell are these even things anyways
	design_ids = list("safetymuzzle", "shockmuzzle")
	research_cost = 2500
	export_price = 10000

////////////////////////Alien technology////////////////////////
/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	id = "alientech"
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list("base")
	boost_item_paths = list(/obj/item/gun/energy/alien = 0, /obj/item/scalpel/alien = 0, /obj/item/hemostat/alien = 0, /obj/item/retractor/alien = 0, /obj/item/circular_saw/alien = 0,
	/obj/item/cautery/alien = 0, /obj/item/surgicaldrill/alien = 0, /obj/item/screwdriver/abductor = 0, /obj/item/wrench/abductor = 0, /obj/item/crowbar/abductor = 0, /obj/item/multitool/abductor = 0,
	/obj/item/weldingtool/abductor = 0, /obj/item/wirecutters/abductor = 0, /obj/item/abductor_baton = 0)
	research_cost = 2500
	export_price = 10000
	hidden = TRUE
	design_ids = list("alienalloy")

/datum/techweb_node/alien_bio
	id = "alien_bio"
	display_name = "Alien Biological Tools"
	description = "Advanced biological tools."
	prereq_ids = list("alientech", "biotech")
	design_ids = list("alien_scalpel", "alien_hemostat", "alien_retractor", "alien_saw", "alien_drill", "alien_cautery",
	"borg_upgrade_abductor_medi", "alien_bonegel", "alien_bonesetter", "alien_fixovein")
	boost_item_paths = list(/obj/item/gun/energy/alien = 0, /obj/item/scalpel/alien = 0, /obj/item/hemostat/alien = 0, /obj/item/retractor/alien = 0, /obj/item/circular_saw/alien = 0,
	/obj/item/cautery/alien = 0, /obj/item/surgicaldrill/alien = 0, /obj/item/screwdriver/abductor = 0, /obj/item/wrench/abductor = 0, /obj/item/crowbar/abductor = 0, /obj/item/multitool/abductor = 0,
	/obj/item/weldingtool/abductor = 0, /obj/item/wirecutters/abductor = 0, /obj/item/abductor_baton = 0)
	research_cost = 2500
	export_price = 10000
	hidden = TRUE

/datum/techweb_node/alien_engi
	id = "alien_engi"
	display_name = "Alien Engineering"
	description = "Alien engineering tools"
	prereq_ids = list("alientech", "adv_engi")
	boost_item_paths = list(/obj/item/screwdriver/abductor = 0, /obj/item/wrench/abductor = 0, /obj/item/crowbar/abductor = 0, /obj/item/multitool/abductor = 0,
	/obj/item/weldingtool/abductor = 0, /obj/item/wirecutters/abductor = 0, /obj/item/abductor_baton = 0)
	design_ids = list("alien_wrench", "alien_wirecutters", "alien_screwdriver", "alien_crowbar", "alien_welder", "alien_multitool", "borg_upgrade_abductor_engi")
	research_cost = 2500
	export_price = 10000
	hidden = TRUE

// Syndicate stuffs
/datum/techweb_node/syndicate_basic
	id = "syndicate_basic"
	display_name = "Illegal Technology"
	description = "Dangerous research used to create dangerous objects."
	prereq_ids = list("adv_engi", "weaponry", "explosive_weapons")
	design_ids = list("suppressor", "largecrossbow", "borg_syndicate_module")
	research_cost = 2500
	export_price = 5000
	hidden = TRUE

//Crappy way of making syndicate gear decon supported until there's another way.
// I really do hate this, -AA
/datum/techweb_node/syndicate_basic/New()
	. = ..()
	boost_item_paths = list()
	for(var/path in subtypesof(/datum/uplink_item))
		var/datum/uplink_item/UI = new path
		if(!UI.item || !UI.illegal_tech)
			continue
		boost_item_paths |= UI.item	//allows deconning to unlock.


///// Shitty Ass Spacepods /////
/datum/techweb_node/spacepod_tech
	id = "spacepod_tech"
	display_name =  "Spacepods"
	description = "Technology which allows us to cruise space with ease"
	prereq_ids = list("base")
	design_ids = list("spacepod_main", "podframefp", "podframeap", "podframefs", "podframeas", "podcore", "podarmor_civ", "podcargo_sec_lootbox", "podcargo_sec_seat",
	"podlock_keyed", "podkey", "podmisc_tracker")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/spacepod_cargo
	id = "spacepod_cargo"
	display_name =  "Spacepod Cargo"
	description = "Cruise space with more space"
	prereq_ids = list("spacepod_tech")
	design_ids = list("podcargo_ore", "podcargo_crate")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/spacepod_weapons
	id = "spacepod_weapons"
	display_name =  "Spacepod Hostile Weaponry"
	description = "Research which can put a gun on a spacepod"
	prereq_ids = list("spacepod_tech", "weaponry")
	design_ids = list("podgun_taser", "podgun_btaser", "podgun_laser")
	research_cost = 2500
	export_price = 10000

/datum/techweb_node/spacepod_mining_weapons
	id = "spacepod_mining_weapons"
	display_name =  "Spacepod Mining Weaponry"
	description = "This is what happens when you mix kinetic accelerators and spacepods"
	prereq_ids = list("spacepod_tech", "adv_mining") // adv mining because its a mid-range KA inside pretty much
	design_ids = list("pod_mining_laser", "pod_mining_laser_basic")
	research_cost = 2500
	export_price = 10000

/proc/total_techweb_points()
	var/list/datum/techweb_node/processing = list()
	for(var/i in subtypesof(/datum/techweb_node))
		processing += new i
	. = 0
	for(var/i in processing)
		var/datum/techweb_node/TN = i
		. += TN.research_cost
