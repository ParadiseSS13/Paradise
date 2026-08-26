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
	unlocks = list("super_capacitor", "phasic_sensor", "pico_mani", "ultra_micro_laser", "super_matter_bin")
	prereqs = list("advparts")
	cost = list("Research" = 1000)

/datum/technode/rnd/blueparts
	name = "Experimental Machine Parts"
	desc = "Various experimental parts utilizing advanced materials and bluespace to create and improve machinery."
	id = "blueparts"
	unlocks = list("quadratic_capacitor", "triphasic_sensor", "femto_mani", "quadultra_micro_laser", "bluespace_matter_bin")
	prereqs = list("superparts")
	cost = list("Research" = 2500)

/datum/technode/rnd/aplu_mech
	name = "Working-Class Exosuits"
	desc = "APLU working-class exosuits used for mining and heavy industry applications."
	id = "mech_aplu"
	unlocks = list("ripley_main", "ripley_peri", "ripley_chassis", "firefighter_chassis", "ripley_torso", "ripley_left_arm", "ripley_right_arm", "ripley_left_leg", "ripley_right_leg")
	starting_node = TRUE

/datum/technode/rnd/mech_ody
	name = "Medical Exosuit"
	desc = "Odysseus civilian-class exosuit used for emergency response and general medicine."
	id = "mech_ody"
	prereqs = list("mech_aplu")
	unlocks = list("odysseus_main", "odysseus_peri", "odysseus_chassis", "odysseus_torso", "odysseus_left_arm", "odysseus_right_arm", "odysseus_left_leg", "odysseus_right_leg")
	cost = list("Research" = 750)

/datum/technode/rnd/mech_nkr
	name = "Janitorial Exosuit"
	desc = "Nkarrdem civilian-class exosuit used for ."
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
	desc = "Durand and Gygax combat-class exosuit used for maximum entertainment."
	id = "mech_cmbt"
	prereqs = list("mech_ody", "mech_nkr")
	unlocks = list("durand_main", "durand_peri", "durand_chassis", "durand_torso", "durand_left_arm", "durand_right_arm", "durand_left_leg", "durand_right_leg", "gygax_main", "gygax_peri", "gygax_chassis", "gygax_torso", "gygax_left_arm", "gygax_right_arm", "gygax_left_leg", "gygax_right_leg")
	cost = list("Research" = 1200)
