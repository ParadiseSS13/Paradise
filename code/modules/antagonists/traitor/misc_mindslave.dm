//Mindslave given by an implant, if the mob is transfered they lose the implant and cant have mindslave removed otherwise
/datum/antagonist/mindslave/implant/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	owner.remove_antag_datum(/datum/antagonist/mindslave/implant)

//Mindslaved thrall risen by the wizards necromantic stone
/datum/antagonist/mindslave/necromancy
	name = "Necromancy-risen Thrall"
	master_hud_name = "wizard"
