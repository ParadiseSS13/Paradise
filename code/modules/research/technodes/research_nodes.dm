/datum/technode/rnd
	name = "Research Basenode"
	desc = "If you see me, make a bug report!"
	id = "rnd_base"
	node_type = "Research Inquiry"

// MARK: Anomaly
/datum/technode/rnd/anom_tech
	name = "Anomaly Core Utilization"
	desc = "Powerful equipment powered by various valuble anomaly cores."
	id = "anom_tech"
	unlocks = list("reactivearmor", "gravboots", "pyro_gloves", "bsg", "v1_arm", "mod_teleporter", "mod_kinesis", "mod_firewall", "mod_arcshield", "mod_vortex", "mod_cryo")

// MARK: Stock Parts
/datum/technode/rnd/advparts
	name = "Advanced Machine Parts"
	desc = "Various advanced parts used to create and improve machinery."
	id = "advparts"
	unlocks = list("adv_capacitor", "adv_sensor", "nano_mani", "high_micro_laser", "adv_matter_bin", "rped")
	starting_node = TRUE

/datum/technode/rnd/superparts
	name = "Precision Machine Parts"
	desc = "Various precision parts used to create and improve machinery."
	id = "superparts"
	prereqs = list("advparts")
	unlocks = list("super_capacitor", "phasic_sensor", "pico_mani", "ultra_micro_laser", "super_matter_bin", "bs_rped")
	cost = list("Research" = 1000)

/datum/technode/rnd/blueparts
	name = "Experimental Machine Parts"
	desc = "Various experimental parts utilizing advanced materials and bluespace to create and improve machinery."
	id = "blueparts"
	prereqs = list("superparts")
	unlocks = list("quadratic_capacitor", "triphasic_scanning", "femto_mani", "quadultra_micro_laser", "bluespace_matter_bin")
	cost = list("Research" = 2500)

// MARK: Bluespace
/datum/technode/rnd/arti_bs
	name = "Bluespace Synthesis"
	desc = "Artifical synthesis of extremely fragile bluespace crystals and experimental space compression technology."
	id = "arti_bs"
	prereqs = list()
	unlocks = list("bluespace_crystal", "minerbag_holding", "bluespace_belt_holder", "brpd", "bluespaceshotglass", "light_replacer_bluespace")
	cost = list()

/datum/technode/rnd/bs_storage
	name = "Bluespace Storage"
	desc = "Experimental technology used to compress items in a pocket of bluespace, bigger on the inside."
	id = "bs_storage"
	prereqs = list()
	unlocks = list("bag_holding", "bluespace_belt", "bluespace_closet", "bluespace_cell")
	cost = list()

// MARK: Mechs
/datum/technode/rnd/firefighter
	name = "Working-Class Enhancements"
	desc = "Firefighter chassis for the APLU 'Ripley' series of exosuit."
	id = "mech_aplu"
	prereqs = list("advparts")
	unlocks = list("ripley_main", "ripley_peri", "ripley_chassis", "firefighter_chassis", "ripley_torso", "ripley_left_arm", "ripley_right_arm", "ripley_left_leg", "ripley_right_leg", "mech_plate_armor")
	cost = list("Research" = 500)

/datum/technode/rnd/mech_ody
	name = "Medical Exosuit"
	desc = "Odysseus civilian-class exosuit used for emergency response and general medicine."
	id = "mech_ody"
	prereqs = list("mech_aplu")
	unlocks = list("odysseus_main", "odysseus_peri", "odysseus_chassis", "odysseus_head", "odysseus_torso", "odysseus_left_arm", "odysseus_right_arm", "odysseus_left_leg", "odysseus_right_leg")
	cost = list("Research" = 750)

/datum/technode/rnd/mech_nkr
	name = "Janitorial Exosuit"
	desc = "Nkarrdem civilian-class exosuit used for mass janitorial work."
	id = "mech_nkr"
	prereqs = list("mech_aplu", "borg_jani")
	unlocks = list("nkarrdem_main", "nkarrdem_peri", "nkarrdem_chassis", "nkarrdem_head", "nkarrdem_torso", "nkarrdem_left_arm", "nkarrdem_right_arm", "nkarrdem_left_leg", "nkarrdem_right_leg")
	cost = list("Research" = 750)

/datum/technode/rnd/mech_ent
	name = "Entertainment Exosuits"
	desc = "H.O.N.K and Reticence civilian-class exosuit used for maximum entertainment."
	id = "mech_ent"
	prereqs = list("mech_ody", "mech_nkr")
	unlocks = list("honk_main", "honk_peri", "honk_targ", "honk_chassis", "honk_head", "honk_torso", "honk_left_arm", "honk_right_arm", "honk_left_leg", "honk_right_leg", "reticence_main", "reticence_peri", "reticence_targ", "reticence_chassis", "reticence_head", "reticence_torso", "reticence_left_arm", "reticence_right_arm", "reticence_left_leg", "reticence_right_leg")
	cost = list("Research" = 1200, "Illegal" = 100) // MIXTODO - Remove the illegal from this, just for testing

/datum/technode/rnd/mech_cmbt
	name = "Combat Exosuits"
	desc = "Durand and Gygax combat-class exosuit used for securing stations and fighting alien threats."
	id = "mech_cmbt"
	prereqs = list("mech_ody", "mech_nkr")
	unlocks = list("durand_main", "durand_peri", "durand_targ", "durand_chassis", "durand_head", "durand_torso", "durand_left_arm", "durand_right_arm", "durand_left_leg", "durand_right_leg", "durand_armor", "gygax_main", "gygax_peri", "gygax_targ", "gygax_chassis", "gygax_head", "gygax_torso", "gygax_left_arm", "gygax_right_arm", "gygax_left_leg", "gygax_right_leg", "gygax_armor")
	cost = list("Research" = 1200)

/datum/technode/rnd/mech_exp
	name = "Experimental Exosuits"
	desc = "Phazon experimental combat-class exosuit capable of phasing through solid objects, requires a bluespace anomaly core."
	id = "mech_exp"
	prereqs = list("mech_cmbt")
	unlocks = list("phazon_main", "phazon_peri", "phazon_targ", "phazon_chassis", "phazon_head", "phazon_torso", "phazon_left_arm", "phazon_right_arm", "phazon_left_leg", "phazon_right_leg", "phazon_armor")
	cost = list("Research" = 1500)

// MARK: Mech Equipment
/datum/technode/rnd/mech_equip_standard // MIXTODO - Mech equipment may be better off in more generalised nodes/"tiers".
	name = "Exosuit Standard Equipment"
	desc = "General purpose equipment capable of attaching to any class of exosuit."
	id = "mech_equip_standard"
	prereqs = list("mech_aplu")
	unlocks = list("mech_repair_droid", "mech_thruster", "mech_proj_armor", "mech_ccw_armor", "mech_generator_nuclear", "mech_generator", "mech_energy_relay")

/datum/technode/rnd/mech_equip_mining
	name = "Exosuit Mining Equipment"
	desc = "Large-scale mining equipment for use on exosuits."
	id = "mech_equip_mining"
	prereqs = list("mech_aplu")
	unlocks = list("mech_drill", "mech_diamond_drill", "mech_crusher", "mech_plasma_cutter", "mech_mscanner", "mech_plate_armor", "mech_hydraulic_clamp")

/datum/technode/rnd/mech_equip_engineering
	name = "Exosuit Engineering Equipment"
	desc = "Industrial engineering equipment for use on exosuits."
	id = "mech_equip_engineering"
	prereqs = list("mech_aplu")
	unlocks = list("mech_rcd", "mech_extinguisher", "mech_cable_layer")

/datum/technode/rnd/mech_equip_medical
	name = "Exosuit Medical Equipment"
	desc = "Mobile synthesis and medical equipment for use on medical-class exosuits."
	id = "mech_equip_medical"
	prereqs = list("mech_ody")
	unlocks = list("mech_sleeper", "mech_syringe_gun", "mech_medical_jaw", "mech_medi_beam")

/datum/technode/rnd/mech_equip_janitorial
	name = "Exosuit Janitorial Equipment"
	desc = "Industrial cleaning solutions, the next best thing from soap is a grenade."
	id = "mech_equip_janitorial"
	prereqs = list("mech_nkr")
	unlocks = list("mech_mop", "mech_garbage_bag", "mech_mega_spray", "mech_light_replacer")

/datum/technode/rnd/mech_equip_entertainment
	name = "Exosuit Entertainment Equipment"
	desc = "Fun for everyone! now mounted on a giant hunk of metal!"
	id = "mech_equip_entertainment"
	prereqs = list("mech_ent")
	unlocks = list("mech_banana_mortar", "mech_honker", "mech_mousetrap_mortar", "mech_silentgun", "mech_mrcd")

/datum/technode/rnd/mech_equip_defence
	name = "Advanced Exosuit Defence"
	desc = "Active defence equipment for use on exosuits."
	id = "mech_equip_defence"
	prereqs = list("mech_cmbt")
	unlocks = list("dropwall_launcher", "mech_shield_gen")


// MARK: Mech Weapons
/datum/technode/rnd/mech_weap_nonlethal
	name = "Exosuit Non-Lethal Weaponry"
	desc = "Non-lethal weapons and security equipment for use on combat exosuits."
	id = "mech_weap_nonlethal"
	prereqs = list("mech_cmbt")
	unlocks = list("mech_scatter_disabler", "mech_disabler", "mech_bola", "mech_grenade_launcher")

/datum/technode/rnd/mech_weap_laser
	name = "Exosuit Basic Laser Weaponry"
	desc = "Lethal laser weaponry for use on combat exosuits."
	id = "mech_weap_laser"
	prereqs = list("mech_cmbt")
	unlocks = list("mech_laser", "mech_immolator")

/datum/technode/rnd/mech_weap_heavylaser
	name = "Exosuit Heavy Laser Weaponry"
	desc = "Exceptionally lethal laser weaponry for use on combat exosuits."
	id = "mech_weap_heavylaser"
	prereqs = list("mech_weap_laser")
	unlocks = list("mech_laser_heavy", "mech_scatter_laser")

/datum/technode/rnd/mech_weap_ballistic
	name = "Exosuit Ballistic Weaponry"
	desc = "Deadly ballistic weaponry for use on combat exosuits."
	id = "mech_weap_ballistic"
	prereqs = list("mech_weap_laser")
	unlocks = list("mech_lmg", "mech_carbine")

/datum/technode/rnd/mech_weap_special
	name = "Exosuit Special Weaponry"
	desc = "Unique weaponry for use on combat exosuits."
	id = "mech_weap_special"
	prereqs = list("mech_weap_heavylaser")
	unlocks = list("mech_ion", "mech_tesla", "mech_missile_rack")

// MARK: Mining
/datum/technode/rnd/mining
	name = "Mining Equipment"
	desc = "Standard mining equipment designed to destroy rock."
	id = "mining"
	unlocks = list("drill", "plasmacutter", "resonator", "triggermod", "rangemod")
	starting_node = TRUE

/datum/technode/rnd/adv_mining
	name = "Advanced Mining Equipment"
	desc = "Improved mining equipment allowing miners to cut through rock with ease."
	id = "adv_mining"
	prereqs = list("mining", "superparts")
	unlocks = list("plasmacutter_adv", "drill_diamond", "superresonator", "damagemod", "cooldownmod", "hypermod")
	cost = list("Research" = 800)

/datum/technode/rnd/exp_mining
	name = "Experimental Mining Equipment"
	desc = "High-tech mining equipment for rapid excavation of minerals."
	id = "exp_mining"
	prereqs = list("adv_mining", "blueparts")
	unlocks = list("megacharge", "lavarod", "jackhammer")
	cost = list("Research" = 1000)

// MARK: Equipment
/datum/technode/rnd/huds
	name = "Heads-up Displays"
	desc = "Worn HUDs that provide specialised information to the wearer."
	id = "huds"
	prereqs = list("advparts")
	unlocks = list("health_hud", "security_hud", "skills_hud", "jani_hud", "dianostic_hud", "scigoggles", "hydroponic_hud")
	cost = list()

/datum/technode/rnd/scanners
	name = "Penetrating Scanners"
	desc = "Worn scanners capable of lightly penetrating walls and providing information on the environment."
	id = "scanners"
	prereqs = list("huds")
	unlocks = list("mesons", "engine_goggles", "atmos_goggles")
	cost = list()

/datum/technode/rnd/nvgs
	name = "Low-Light Technology"
	desc = "Goggles capable of amplifying low-light conditions."
	id = "nvgs"
	prereqs = list("scanners", "mining")
	unlocks = list("night_vision_goggles", "nvgmesons")
	cost = list()

/datum/technode/rnd/emergency_equip
	name = "Emergency Equipment"
	desc = "Break glass incase of broken glass."
	id = "emergency_equip"
	unlocks = list("breathmask", "emergencyoxygen", "oxygentank")
	starting_node = TRUE

// MARK: Engineering
/datum/technode/rnd/power_tools
	name = "Power Tools"
	desc = "Advanced tools that are much faster then their standard counterparts."
	id = "power_tools"
	prereqs = list()
	unlocks = list("exwelder", "handdrill", "bolter_wrench") // Jaws are in emergency medicine as that is their ""intended"" purpose.
	cost = list()

/datum/technode/rnd/porta_power
	name = "Portable Power"
	desc = "Portable PACMAN generators and improved cells for emergency or temporary power."
	id = "porta_power"
	prereqs = list("emergency_equip", "advparts")
	unlocks = list("pacman", "superpacman", "high_cell", "super_cell")
	cost = list()

/datum/technode/rnd/indus_power
	name = "Industrial Power Solutions"
	desc = "Energy dense power solutions for station and industry usage."
	id = "indus_power"
	prereqs = list("porta_power", "superparts")
	unlocks = list("mrspacman", "smes", "ptransformer", "hyper_cell",)
	cost = list()

/datum/technode/rnd/turbine_power
	name = "Gas Turbine Generation"
	desc = "Creating power from heated gas."
	id = "turbine_power"
	prereqs = list("indus_power")
	unlocks = list("power_compressor", "power_turbine", "power_turbine_console")
	cost = list()

/datum/technode/rnd/tesla_power
	name = "Lightning Redirection"
	desc = "Sticks of metal that attract lightning arcs better then humanoids!.. most of the time."
	id = "tesla_power"
	prereqs = list("indus_power")
	unlocks = list("grounding_rod", "tesla_coil", "emitter")
	cost = list()

/datum/technode/rnd/nuclear_power
	name = "Atomic Energy"
	desc = "Reactor equipment for improving NGCR:tm: reactors, reactor core sold seperately."
	id = "nuclear_power"
	prereqs = list("indus_power")
	unlocks = list("nuclear_centrifuge", "nuclear_fabricator", "nuclear_gas_node", "reactor_chamber", "nuclear_monitor")
	cost = list()

/datum/technode/rnd/nuclear_upgrade
	name = "Fissile Fabrications"
	desc = "Improved nuclear fabricator operations allow for more powerful rods to be made."
	id = "nuclear_upgrade"
	prereqs = list("nuclear_power")
	unlocks = list("nuclear_fab_upgrade", "neutron_grenade")
	cost = list()

/datum/technode/rnd/atmospherics
	name = "Atmospherics Equipment"
	desc = "Equipment and Machinery for use in bending gas to your will.. or fixing the raging plasmafire in toxins."
	id = "atmospherics"
	prereqs = list("emergency_equip", "advparts")
	unlocks = list("thermomachine", "space_heater", "oxygen_grenade", "extendedoxygen")
	cost = list()

/datum/technode/rnd/opt_tanks
	name = "Optimized Tanks"
	desc = "Perfected emergency tank designs that maximize capacity while keeping the small form factor."
	id = "opt_tanks"
	prereqs = list("atmospherics")
	unlocks = list("doubleoxygen") // MIXTODO - maybe make this a prototype.
	cost = list()

// MARK: Service
/datum/technode/rnd/adv_sani
	name = "Advanced Sanitation"
	desc = "Improved janitorial tools to keep the station as clean as ever!"
	id = "adv_sani"
	prereqs = list()
	unlocks = list("advmop", "blutrash", "holosign", "light_replacer")
	cost = list()

// MARK: Medical
/datum/technode/rnd/med_analysis
	name = "Medical Analysis"
	desc = "Body and reagent analysis equipment for diagnosis and reagent synthesis."
	id = "med_analysis"
	prereqs = list()
	unlocks = list("adv_reagent_scanner", "healthanalyzer_upgrade", "sleeper", "bodyscanner")
	cost = list()

/datum/technode/rnd/cloning
	name = "Cellular Replication"
	desc = "Cloning technology able to completely replicate most biological humanoids from DNA."
	id = "cloning"
	prereqs = list()
	unlocks = list("clonepod", "clonescanner", "clonecontrol", "dissection_manager_upgraded")
	cost = list()

/datum/technode/rnd/chem
	name = "Chemical Synthesis"
	desc = "Machines able to synthesise chemicals from energy and press them into approprate form."
	id = "chem"
	prereqs = list()
	unlocks = list("splitbeaker", "chem_dispenser", "chem_master", "chem_heater", "reagentgrinder")
	cost = list()

/datum/technode/rnd/em_medicine
	name = "Emergency Medicine"
	desc = "Legal breaking and entering that sometimes saves a life!"
	id = "em_medicine"
	prereqs = list()
	unlocks = list("jawsoflife", "holo_stretcher", "compact_defib", "scalpel_laser")
	cost = list()

/datum/technode/rnd/adv_med
	name = "Advanced Medical Devices"
	desc = ""
	id = "adv_med"
	prereqs = list()
	unlocks = list("scalpel_manager", "automender", "bluespacebeaker") // MIXTODO - Maybe make automender a prototype
	cost = list()

/datum/technode/rnd/biochip
	name = "Biochips"
	desc = "Small sterile chips with various purposes that can be implanted in humanoids, machines included."
	id = "biochips"
	prereqs = list()
	unlocks = list("biochip_pad", "implanter", "implantcase", "implant_chem", "implant_tracking", "implant_trombone")
	cost = list()

/datum/technode/rnd/organ_replacements
	name = "Organ Replacements"
	desc = "Cybernetic organs that are functionally identical to their organic counterpart, keep away from magnets."
	id = "organ_replacements"
	prereqs = list()
	unlocks = list("cybernetic_eyes", "cybernetic_ears", "cybernetic_liver", "cybernetic_kidneys", "cybernetic_heart", "cybernetic_lungs", "ci-nutriment", "skin_1", "skin_2")
	cost = list()

/datum/technode/rnd/advanced_organs
	name = "Advanced Organ Replacements"
	desc = "Advanced cybernetic organs that offer superior functionality to their organic counterpart, keep away from magnets."
	id = "advanced_organs"
	prereqs = list("organ_replacements")
	unlocks = list("cybernetic_liver_u", "cybernetic_kidneys_u", "cybernetic_heart_u", "cybernetic_lungs_u", "skin_3", "epidermal_applicator")
	cost = list()

/datum/technode/rnd/eye_imp
	name = "Eye Implants"
	desc = "Improved cybernetic eyes capable of preventing flashes, displaying information and identifying structures through walls."
	id = "eye_imp"
	prereqs = list()
	unlocks = list("ci-mesonhud", "ci-welding", "ci-janihud", "ci-diaghud", "ci-skillhud", "ci-medhud", "ci-hydrohud", "ci-sechud")
	cost = list()

/datum/technode/rnd/wide_spectrum
	name = "Wide Spectrum Replacements"
	desc = "Cybernetic eyes capable of identifying thermal signatures and enhancing distant objects."
	id = "wide_spectrum"
	prereqs = list("eye_imp")
	unlocks = list("ci-thermals", "ci-scope")
	cost = list()

/datum/technode/rnd/ultrawide_spectrum
	name = "Ultra-wide Spectrum Replacements"
	desc = "Enhanced cybernetic eyes capable of seeing through walls."
	id = "ultrawide_spectrum"
	prereqs = list("wide_spectrum")
	unlocks = list("ci-xray") // MIXTODO - Probably make this a prototype
	cost = list()

/datum/technode/rnd/chest_imp
	name = "Chest Implants"
	desc = "Cybernetic implants that fit into the chest cavity."
	id = "chest_imp"
	prereqs = list()
	unlocks = list("ci-nutrimentplus", "ci-reviver", "bluespace_anchor_implant")
	cost = list()

/datum/technode/rnd/brain_imp
	name = "Brain Implants"
	desc = "Cybernetic implants that attach directly to the brain, keep away from magnets."
	id = "brain_imp"
	prereqs = list()
	unlocks = list("ci-wire_interface", "ci-clownvoice", "ci-antisleep", "ci-antistun", "ci-antidrop")
	cost = list()

/datum/technode/rnd/arm_imp
	name = "Arm-mounted Implants"
	desc = "Cybernetic implants stuffed neatly inside the arm containing a variety of useful tools."
	id = "arm_imp"
	prereqs = list()
	unlocks = list("ci-botanical", "ci-janitorial", "ci-cargo", "ci-toolset", "ci-surgey")
	cost = list()

// MARK: Weapons
/datum/technode/rnd/laser_basic
	name = "Basic Laser Weaponry"
	desc = "Conversion kits for low-powered or specialised laser weaponry, gun sold seperately."
	id = "laser_basic"
	prereqs = list()
	unlocks = list("sparker", "stunrevolver", "temp_gun", "ppistol", "nuclear_gun")

/datum/technode/rnd/laser_high
	name = "Advanced Laser Weaponry"
	desc = "Conversion kits for high-powered laser and energy weaponry, gun sold seperately."
	id = "laser_high"
	prereqs = list("laser_basic")
	unlocks = list("xray", "immolator", "lwap", "lasercannon", "ioncarbine")

/datum/technode/rnd/laser_ult
	name = "Experimental Laser Weaponry"
	desc = "Specialised lasers capable of damaging cells directly, for when you REALLY want something dead, gun sold seperately."
	id = "laser_ult"
	prereqs = list("laser_high")
	unlocks = list("decloner")

/datum/technode/rnd/ammo_laser
	name = "Cased Laser Ammunition"
	desc = "Ammunition for the IK-Series of laser projector rifles."
	id = "ammo_laser"
	prereqs = list()
	unlocks = list("mag_laser", "box_laser")

/datum/technode/rnd/ammo_wt
	name = "Ballistic Ammunition"
	desc = "4.6x30mm ammunition used in submachine guns and low-caliber rifles."
	id = "ammo_wt"
	prereqs = list()
	unlocks = list("mag_oldsmg", "box_oldsmg", "box_oldsmg_ap", "box_oldsmg_ic", "box_oldsmg_tx")

/datum/technode/rnd/ammo_flame
	name = "Chemical Warfare"
	desc = "Canisters and conversion kits used by chemical flamethrowers, gun sold seperately."
	id = "ammo_flame"
	prereqs = list()
	unlocks = list("chem_flamethrower_extended", "chemical_canister", "chemical_canister_extended", "chemical_canister_pyro")

/datum/technode/rnd/improved_grenades
	name = "Improved Grenade Casings"
	desc = "Grenade casings with larger range or specialised effects."
	id = "improved_grenades"
	prereqs = list()
	unlocks = list("large_grenade", "pyro_grenade", "cryo_grenade", "adv_grenade")

/datum/technode/rnd/defence_tech
	name = "Personal Defence Techknowledgy"
	desc = "Devices and equipment to defend individuals or groups."
	id = "defence_tech"
	prereqs = list()
	unlocks = list("tele_shield", "drop_wall")

/datum/technode/rnd/portals
	name = "Handheld Portal Device"
	desc = "A device capable of firing two types of interconnected wormholes, comes with free unpoisoned cake!"
	id = "portals"
	prereqs = list()
	unlocks = list("wormholeprojector")

// MARK: Synthetics
/datum/technode/rnd/ai
	name = "Artificial Intelligence"
	desc = "Nanotrasen, pioneering ethical practices since 2080!"
	id = "ai"
	prereqs = list()
	unlocks = list("aicore", "aifixer", "aiupload", "intellicard")
	cost = list()

/datum/technode/rnd/standard_ai
	name = "Standard AI Lawsets"
	desc = "Classic set of Nanotrasen approved AI laws, cleans up 99.9% of all malfunctioning code!"
	id = "standard_ai"
	prereqs = list("ai")
	unlocks = list("freeform_module", "reset_module", "purge_module", "corporate_module", "crewsimov_module", "nt_default_module")
	cost = list()

/datum/technode/rnd/unique_ai
	name = "Unique AI Lawsets"
	desc = "Galaxy's worst social experiment!"
	id = "unique_ai"
	prereqs = list("standard_ai")
	unlocks = list("freeformcore_module", "protectstation_module", "quarantine_module", "safeguard_module", "pranksimov_module", "asimov_module", "paladin_module")
	cost = list()

/datum/technode/rnd/borg_uni
	name = "Universal Cyborg Enhancements"
	desc = "Upgrades for all types of cyborg."
	id = "borg_uni"
	prereqs = list("advparts")
	unlocks = list("borg_upgrade_vtec", "borg_upgrade_thrusters", "borg_upgrade_selfrepair")
	cost = list("Research" = 500)

/datum/technode/rnd/borg_engi
	name = "Engineering Cyborg Enhancements"
	desc = "Upgrades for engineering cyborgs."
	id = "borg_engi"
	prereqs = list("borg_uni")
	unlocks = list("borg_upgrade_RCD", "borg_upgrade_RPED")
	cost = list("Research" = 750)

/datum/technode/rnd/borg_med
	name = "Medical Cyborg Enhancements"
	desc = "Upgrades for medical cyborgs."
	id = "borg_med"
	prereqs = list("borg_uni")
	unlocks = list("borg_upgrade_holo_stretcher")
	cost = list("Research" = 750)

/datum/technode/rnd/borg_jani
	name = "Janitor Cyborg Enhancements"
	desc = "Upgrades for janitorial cyborgs."
	id = "borg_jani"
	prereqs = list("borg_uni")
	unlocks = list("borg_upgrade_floorbuffer", "borg_upgrade_bluespace_trash_bag")
	cost = list("Research" = 750)

/datum/technode/rnd/borg_serv
	name = "Service Cyborg Enhancements"
	desc = "Upgrades for service cyborgs."
	id = "borg_serv"
	prereqs = list("borg_uni")
	unlocks = list("borg_upgrade_RSF_executive")
	cost = list("Research" = 750)

/datum/technode/rnd/borg_mine
	name = "Mining Cyborg Enhancements"
	desc = "Upgrades for mining cyborgs."
	id = "borg_mine"
	prereqs = list("borg_uni")
	unlocks = list("borg_upgrade_lavaproof", "borg_upgrade_holding", "borg_upgrade_diamonddrill")
	cost = list("Research" = 750)

// MARK: MODsuits
/datum/technode/rnd/mod
	name = "MODsuit Construction"
	desc = "Customisable 'Modular Outerwear Device' suits capable of EVA while offering extra functionality in the form of modules."
	id = "mod"
	prereqs = list()
	unlocks = list("mod_shell", "mod_helmet", "mod_chestplate", "mod_gauntlets", "mod_boots", "mod_plating_standard", "mod_storage")

/datum/technode/rnd/mod_plating
	name = "Specialised MODsuit Plating"
	desc = "Different types of plating for MODsuits that offer improved environmental protection, module capacity and unique functions, All specialised plating comes in a lockbox."
	id = "mod_plating"
	prereqs = list("mod")
	unlocks = list("mod_plating_engineering", "mod_plating_atmospheric", "mod_plating_medical", "mod_plating_security", "mod_plating_cosmohonk", "mod_skin_civilian", "mod_skin_corpsman")

/datum/technode/rnd/module_gen
	name = "Standard Modules"
	desc = "General use MODsuit modules."
	id = "module_gen"
	prereqs = list("mod")
	unlocks = list("mod_visor_diaghud", "mod_visor_meson", "mod_t_ray", "mod_flashlight", "mod_reagent_scanner", "mod_gps", "mod_tether", "mod_bikehorn", "mod_waddle")

/datum/technode/rnd/module_spec
	name = "Advanced Modules"
	desc = "Advanced general use MODsuit modules."
	id = "module_spec"
	prereqs = list("module_gen")
	unlocks = list("mod_storage_expanded", "mod_status_readout", "mod_plasmastable", "mod_thermal_regulator", "mod_dna_lock", "mod_pathfinder")

/datum/technode/rnd/module_med
	name = "Medical Modules"
	desc = "MODsuit modules specialised for medical purposes."
	id = "module_med"
	prereqs = list()
	unlocks = list("mod_visor_medhud", "mod_injector", "mod_monitor", "mod_defib", "mod_analyzer")

/datum/technode/rnd/module_sup
	name = "Supply Modules"
	desc = "MODsuit modules specialised for supply, salvage and mining purposes."
	id = "module_sup"
	prereqs = list()
	unlocks = list("mod_clamp", "mod_drill", "mod_orebag")

/datum/technode/rnd/module_sec
	name = "Security Modules"
	desc = "MODsuit modules specialised for security and combat purposes."
	id = "module_sec"
	prereqs = list()
	unlocks = list("mod_holster", "mod_sonar", "mod_smokegrenade", "mod_visor_sechud")

/datum/technode/rnd/module_engi
	name = "Engineering Modules"
	desc = "MODsuit modules specialised for engineering purposes."
	id = "module_engi"
	prereqs = list()
	unlocks = list("mod_jetpack", "mod_magboot", "mod_rad_protection", "mod_welding")
