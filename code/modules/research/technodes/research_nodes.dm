/datum/technode/rnd
	name = "Research Basenode"
	desc = "If you see me, make a bug report!"
	id = "rnd_base"
	node_type = "Research Inquiry"

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

/datum/technode/rnd/bs_storage
	name = "Bluespace Storage"
	desc = "Experimental technology used to compress items in a pocket of bluespace, bigger on the inside."
	id = "bs_storage"
	prereqs = list()
	unlocks = list("bag_holding", "bluespace_belt", "bluespace_closet")

// MARK: Mechs
/datum/technode/rnd/aplu_mech
	name = "Working-Class Exosuits"
	desc = "APLU working-class exosuits used for mining and heavy industry applications."
	id = "mech_aplu"
	prereqs = list("advparts")
	unlocks = list("ripley_main", "ripley_peri", "ripley_chassis", "firefighter_chassis", "ripley_torso", "ripley_left_arm", "ripley_right_arm", "ripley_left_leg", "ripley_right_leg")

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
	prereqs = list("mech_aplu")
	unlocks = list("nkarrdem_main", "nkarrdem_peri", "nkarrdem_chassis", "nkarrdem_head", "nkarrdem_torso", "nkarrdem_left_arm", "nkarrdem_right_arm", "nkarrdem_left_leg", "nkarrdem_right_leg")
	cost = list("Research" = 750)

/datum/technode/rnd/mech_ent
	name = "Entertainment Exosuits"
	desc = "H.O.N.K and Reticence civilian-class exosuit used for maximum entertainment."
	id = "mech_ent"
	prereqs = list("mech_ody", "mech_nkr")
	unlocks = list("honk_main", "honk_peri", "honk_chassis", "honk_head", "honk_torso", "honk_left_arm", "honk_right_arm", "honk_left_leg", "honk_right_leg", "reticence_main", "reticence_peri", "reticence_chassis", "reticence_head", "reticence_torso", "reticence_left_arm", "reticence_right_arm", "reticence_left_leg", "reticence_right_leg")
	cost = list("Research" = 1200, "Illegal" = 100) // MIXTODO - Remove the illegal from this, just for testing

/datum/technode/rnd/mech_cmbt
	name = "Combat Exosuits"
	desc = "Durand and Gygax combat-class exosuit used for securing stations and fighting alien threats."
	id = "mech_cmbt"
	prereqs = list("mech_ody", "mech_nkr")
	unlocks = list("durand_main", "durand_peri", "durand_chassis", "durand_head", "durand_torso", "durand_left_arm", "durand_right_arm", "durand_left_leg", "durand_right_leg", "durand_armor", "gygax_main", "gygax_peri", "gygax_chassis", "gygax_head", "gygax_torso", "gygax_left_arm", "gygax_right_arm", "gygax_left_leg", "gygax_right_leg", "gygax_armor")
	cost = list("Research" = 1200)

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

/datum/technode/rnd/scanners
	name = "Penetrating Scanners"
	desc = "Worn scanners capable of lightly penetrating walls and providing information on the environment."
	id = "scanners"
	prereqs = list("huds")
	unlocks = list("mesons", "engine_goggles", "atmos_goggles")

/datum/technode/rnd/nvgs
	name = "Low-Light Technology"
	desc = "Goggles capable of amplifying low-light conditions."
	id = "nvgs"
	prereqs = list("scanners", "mining")
	unlocks = list("night_vision_goggles", "nvgmesons")

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

/datum/technode/rnd/porta_power
	name = "Portable Power"
	desc = "Portable PACMAN generators and improved cells for emergency or temporary power."
	id = "porta_power"
	prereqs = list("emergency_equip", "advparts")
	unlocks = list("pacman", "superpacman", "high_cell", "super_cell")

/datum/technode/rnd/indus_power
	name = "Industrial Power Solutions"
	desc = "Energy dense power solutions for station and industry usage."
	id = "indus_power"
	prereqs = list("porta_power", "superparts")
	unlocks = list("mrspacman", "smes", "ptransformer", "hyper_cell",)

/datum/technode/rnd/turbine_power
	name = "Gas Turbine Generation"
	desc = "Creating power from heated gas."
	id = "turbine_power"
	prereqs = list("indus_power")
	unlocks = list("power_compressor", "power_turbine", "power_turbine_console")

/datum/technode/rnd/tesla_power
	name = "Lightning Redirection"
	desc = "Sticks of metal that attract lightning arcs better then humanoids!.. most of the time."
	id = "tesla_power"
	prereqs = list("indus_power")
	unlocks = list("grounding_rod", "tesla_coil", "emitter")

/datum/technode/rnd/nuclear_power
	name = "Atomic Energy"
	desc = "Reactor equipment for improving NGCR:tm: reactors, reactor core sold seperately."
	id = "nuclear_power"
	prereqs = list("indus_power")
	unlocks = list("nuclear_centrifuge", "nuclear_fabricator", "nuclear_gas_node", "reactor_chamber")

/datum/technode/rnd/nuclear_upgrade
	name = "Fissile Fabrications"
	desc = "Improved nuclear fabricator operations allow for more powerful rods to be made."
	id = "nuclear_upgrade"
	prereqs = list("nuclear_power")
	unlocks = list("nuclear_fab_upgrade", "neutron_grenade")

/datum/technode/rnd/atmospherics
	name = "Atmospherics Equipment"
	desc = "Equipment and Machinery for use in bending gas to your will.. or fixing the raging plasmafire in toxins."
	id = "atmospherics"
	prereqs = list("emergency_equip", "advparts")
	unlocks = list("thermomachine", "space_heater", "oxygen_grenade", "extendedoxygen")

/datum/technode/rnd/opt_tanks
	name = "Optimized Tanks"
	desc = "Perfected emergency tank designs that maximize capacity while keeping the small form factor."
	id = "opt_tanks"
	prereqs = list("atmospherics")
	unlocks = list("doubleoxygen") // MIXTODO - maybe make this a prototype.

// MARK: Service
/datum/technode/rnd/adv_sani
	name = "Advanced Sanitation"
	desc = "Improved janitorial tools to keep the station as clean as ever!"
	id = "adv_sani"
	prereqs = list()
	unlocks = list("advmop", "blutrash", "holosign", "light_replacer")

// MARK: Medical
/datum/technode/rnd/med_analysis
	name = "Medical Analysis"
	desc = "Body and reagent analysis equipment for diagnosis and reagent synthesis."
	id = "med_analysis"
	prereqs = list()
	unlocks = list("adv_reagent_scanner", "healthanalyzer_upgrade", "sleeper", "bodyscanner")

/datum/technode/rnd/cloning
	name = "Cellular Replication"
	desc = "Cloning technology able to completely replicate most biological humanoids from DNA."
	id = "cloning"
	prereqs = list()
	unlocks = list("clonepod", "clonescanner", "clonecontrol", "dissection_manager_upgraded")

/datum/technode/rnd/chem
	name = "Chemical Synthesis"
	desc = "Machines able to synthesise chemicals from energy and press them into approprate form."
	id = "chem"
	prereqs = list()
	unlocks = list("splitbeaker", "chem_dispenser", "chem_master", "chem_heater", "reagentgrinder")

/datum/technode/rnd/em_medicine
	name = "Emergency Medicine"
	desc = "Legal breaking and entering that sometimes saves a life!"
	id = "em_medicine"
	prereqs = list()
	unlocks = list("jawsoflife", "automender", "holo_stretcher", "compact_defib") // MIXTODO - Maybe make automender a prototype

/datum/technode/rnd/biochip
	name = "Biochips"
	desc = "Small sterile chips with various purposes that can be implanted in humanoids, machines included."
	id = "biochips"
	prereqs = list()
	unlocks = list("biochip_pad", "implanter", "implantcase", "implant_chem", "implant_tracking", "implant_trombone")

/datum/technode/rnd/organ_replacements
	name = "Organ Replacements"
	desc = "Cybernetic organs that are functionally identical to their organic counterpart, keep away from magnets."
	id = "organ_replacements"
	prereqs = list()
	unlocks = list("cybernetic_eyes", "cybernetic_ears", "cybernetic_liver", "cybernetic_kidneys", "cybernetic_heart", "cybernetic_lungs", "ci-nutriment")

/datum/technode/rnd/advanced_organs
	name = "Advanced Organ Replacements"
	desc = "Advanced cybernetic organs that offer superior functionality to their organic counterpart, keep away from magnets."
	id = "advanced_organs"
	prereqs = list("organ_replacements")
	unlocks = list("cybernetic_liver_u", "cybernetic_kidneys_u", "cybernetic_heart_u", "cybernetic_lungs_u")

/datum/technode/rnd/eye_imp
	name = "Eye Implants"
	desc = "Improved cybernetic eyes capable of preventing flashes, displaying information and identifying structures through walls."
	id = "eye_imp"
	prereqs = list()
	unlocks = list("ci-mesonhud", "ci-welding", "ci-janihud", "ci-diaghud", "ci-skillhud", "ci-medhud", "ci-hydrohud", "ci-sechud")

/datum/technode/rnd/wide_spectrum
	name = "Wide Spectrum Replacements"
	desc = "Cybernetic eyes capable of identifying thermal signatures and enhancing distant objects."
	id = "wide_spectrum"
	prereqs = list("eye_imp")
	unlocks = list("ci-thermals", "ci-scope")

/datum/technode/rnd/ultrawide_spectrum
	name = "Ultra-wide Spectrum Replacements"
	desc = "Enhanced cybernetic eyes capable of seeing through walls."
	id = "ultrawide_spectrum"
	prereqs = list("wide_spectrum")
	unlocks = list("ci-xray") // MIXTODO - Probably make this a prototype

/datum/technode/rnd/chest_imp
	name = "Chest Implants"
	desc = "Cybernetic implants that fit into the chest cavity."
	id = "chest_imp"
	prereqs = list()
	unlocks = list("ci-nutrimentplus", "ci-reviver", "bluespace_anchor_implant")

/datum/technode/rnd/brain_imp
	name = "Brain Implants"
	desc = "Cybernetic implants that attach directly to the brain, keep away from magnets."
	id = "brain_imp"
	prereqs = list()
	unlocks = list("ci-wire_interface", "ci-clownvoice", "ci-antisleep", "ci-antistun", "ci-antidrop")

/datum/technode/rnd/arm_imp
	name = "Arm-mounted Implants"
	desc = "Cybernetic implants stuffed neatly inside the arm containing a variety of useful tools."
	id = "arm_imp"
	prereqs = list()
	unlocks = list("ci-botanical", "ci-janitorial", "ci-cargo", "ci-toolset", "ci-surgey")
