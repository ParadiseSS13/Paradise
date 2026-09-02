/datum/technode/rnd
	name = "Research Basenode"
	desc = "If you see me, make a bug report!"
	id = "rnd_base"
	node_type = "Research Inquiry"

/datum/technode/rnd/advparts
	name = "Advanced Machine Parts"
	desc = "Various advanced parts used to create and improve machinery."
	id = "advparts"
	unlocks = list("adv_capacitor", "adv_sensor", "nano_mani", "high_micro_laser", "adv_matter_bin")
	starting_node = TRUE

/datum/technode/rnd/superparts
	name = "Precision Machine Parts"
	desc = "Various precision parts used to create and improve machinery."
	id = "superparts"
	prereqs = list("advparts")
	unlocks = list("super_capacitor", "phasic_sensor", "pico_mani", "ultra_micro_laser", "super_matter_bin")
	cost = list("Research" = 1000)

/datum/technode/rnd/blueparts
	name = "Experimental Machine Parts"
	desc = "Various experimental parts utilizing advanced materials and bluespace to create and improve machinery."
	id = "blueparts"
	prereqs = list("superparts")
	unlocks = list("quadratic_capacitor", "triphasic_sensor", "femto_mani", "quadultra_micro_laser", "bluespace_matter_bin")
	cost = list("Research" = 2500)

/datum/technode/rnd/aplu_mech
	name = "Working-Class Exosuits"
	desc = "APLU working-class exosuits used for mining and heavy industry applications."
	id = "mech_aplu"
	prereqs = list("adv_parts")
	unlocks = list("ripley_main", "ripley_peri", "ripley_chassis", "firefighter_chassis", "ripley_torso", "ripley_left_arm", "ripley_right_arm", "ripley_left_leg", "ripley_right_leg")

/datum/technode/rnd/mech_ody
	name = "Medical Exosuit"
	desc = "Odysseus civilian-class exosuit used for emergency response and general medicine."
	id = "mech_ody"
	prereqs = list("mech_aplu")
	unlocks = list("odysseus_main", "odysseus_peri", "odysseus_chassis", "odysseus_torso", "odysseus_left_arm", "odysseus_right_arm", "odysseus_left_leg", "odysseus_right_leg")
	cost = list("Research" = 750)

/datum/technode/rnd/mech_nkr
	name = "Janitorial Exosuit"
	desc = "Nkarrdem civilian-class exosuit used for mass janitorial work."
	id = "mech_nkr"
	prereqs = list("mech_aplu")
	unlocks = list("nkarrdem_main", "nkarrdem_peri", "nkarrdem_chassis", "nkarrdem_torso", "nkarrdem_left_arm", "nkarrdem_right_arm", "nkarrdem_left_leg", "nkarrdem_right_leg")
	cost = list("Research" = 750)

/datum/technode/rnd/mech_ent
	name = "Entertainment Exosuits"
	desc = "H.O.N.K and Reticence civilian-class exosuit used for maximum entertainment."
	id = "mech_ent"
	prereqs = list("mech_ody", "mech_nkr")
	unlocks = list("honk_main", "honk_peri", "honk_chassis", "honk_torso", "honk_left_arm", "honk_right_arm", "honk_left_leg", "honk_right_leg", "reticence_main", "reticence_peri", "reticence_chassis", "reticence_torso", "reticence_left_arm", "reticence_right_arm", "reticence_left_leg", "reticence_right_leg")
	cost = list("Research" = 1200, "Illegal" = 100) // MIXTODO - Remove the illegal from this, just for testing

/datum/technode/rnd/mech_cmbt
	name = "Combat Exosuits"
	desc = "Durand and Gygax combat-class exosuit used for securing stations and fighting alien threats."
	id = "mech_cmbt"
	prereqs = list("mech_ody", "mech_nkr")
	unlocks = list("durand_main", "durand_peri", "durand_chassis", "durand_torso", "durand_left_arm", "durand_right_arm", "durand_left_leg", "durand_right_leg", "gygax_main", "gygax_peri", "gygax_chassis", "gygax_torso", "gygax_left_arm", "gygax_right_arm", "gygax_left_leg", "gygax_right_leg")
	cost = list("Research" = 1200)

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

/datum/technode/rnd/porta_power
	name = "Portable Generation"
	desc = "Portable PACMAN generators for emergency or temporary power solutions."
	id = "porta_power"
	prereqs = list("emergency_equip", "advparts")
	unlocks = list() // MIXTODO - genuinely cant find the pacman designs currently so i'll fill this later.

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

