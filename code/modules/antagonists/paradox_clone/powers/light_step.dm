/datum/spell/paradox_spell/self/light_step
	name = "Light Step"
	desc = "Allows you to spit on the laws of physics during the action of this ability, in return for stamina."
	action_icon_state = "light_step"
	base_cooldown = 2 SECONDS

/datum/spell/paradox_spell/self/light_step/cast(list/targets, mob/user = usr)
	var/datum/antagonist/paradox_clone/para_clone_datum = user.mind.has_antag_datum(/datum/antagonist/paradox_clone)

	if(para_clone_datum.light_step)
		to_chat(user, "<span class='notice'>Returning to zero.</span>") //holy shit jojo golden wind reference
	else
		para_clone_datum.light_step = TRUE
		var/mob/living/carbon/human/H = user
		H.adjustStaminaLoss(10)
		to_chat(user, "<span class='notice'>Everything feels so soft and wet.</span>") //holy shit jojolion reference

	add_attack_logs(user, user, "(Paradox Clone) Light Steped")

/mob/living/Process_Spacemove(movement_dir = 0)
	var/datum/antagonist/paradox_clone/pc = mind.has_antag_datum(/datum/antagonist/paradox_clone)

	if(pc?.light_step)
		adjustStaminaLoss(5)
		return TRUE

	..()