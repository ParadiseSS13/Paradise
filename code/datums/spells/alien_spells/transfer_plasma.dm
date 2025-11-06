/datum/spell/alien_spell/transfer_plasma
	name = "Transfer Plasma"
	desc = "Transfers 50 plasma to a nearby alien."
	action_icon_state = "alien_transfer"
	plasma_cost = 50

/datum/spell/alien_spell/transfer_plasma/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/datum/spell/alien_spell/transfer_plasma/cast(list/targets, mob/living/carbon/user)
	var/mob/living/carbon/alien/target = targets[1]
	var/turf/T = user.loc
	if(!istype(T) || !istype(target))
		revert_cast()
		return FALSE

	user.Beam(target, icon_state = "sendbeam", time = 2 SECONDS, beam_color = "#f180bd")
	target.add_plasma(50)
	to_chat(user, "<span class='noticealien'>You have transferred 50 plasma to [target].</span>")
	to_chat(target, "<span class='noticealien'>[user] has transferred 50 plasma to you!</span>")
	return TRUE

/datum/spell/alien_spell/syphon_plasma
	name = "Syphon plasma"
	desc = "Syphons 150 plasma from a nearby alien."
	action_icon_state = "alien_transfer"
	base_cooldown = 10 SECONDS

/datum/spell/alien_spell/syphon_plasma/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/datum/spell/alien_spell/syphon_plasma/cast(list/targets, mob/living/carbon/user)
	var/mob/living/carbon/alien/target = targets[1]
	var/turf/T = user.loc
	if(!istype(T) || !istype(target))
		revert_cast()
		return FALSE

	user.Beam(target, icon_state = "drainbeam", time = 2 SECONDS, beam_color = "#f180bd")
	var/obj/item/organ/internal/alien/plasmavessel/vessel = target.get_int_organ(/obj/item/organ/internal/alien/plasmavessel)
	if(!vessel)
		return
	var/plasma_syphoned
	if(vessel.stored_plasma < 150)
		user.add_plasma(vessel.stored_plasma)
		plasma_syphoned = vessel.stored_plasma
		vessel.stored_plasma = 0
	else
		user.add_plasma(150)
		plasma_syphoned = 50
		vessel.stored_plasma = vessel.stored_plasma - 150
	to_chat(user, "<span class='noticealien'>You have syphoned [plasma_syphoned] plasma from [target].</span>")
	to_chat(target, "<span class='noticealien'>[user] has syphoned [plasma_syphoned] from you!</span>")
	return TRUE
