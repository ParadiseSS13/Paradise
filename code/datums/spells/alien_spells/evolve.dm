/obj/effect/proc_holder/spell/alien_spell/evolve
	desc = "Evolve into reporting this issue."
	action_icon_state = "larva2"
	action_icon = 'icons/mob/alien.dmi'
	action_icon_state = "AlienMMI"
	plasma_cost = 500
	var/queen_check = FALSE
	var/evolution_path = /mob/living/carbon/alien/larva


/obj/effect/proc_holder/spell/alien_spell/evolve/praetorian
	name = "Evolve"
	desc = "Become a Praetorian, Royal Guard to the Queen."
	action_icon_state = "aliens_running"
	evolution_path = /mob/living/carbon/alien/humanoid/praetorian


/obj/effect/proc_holder/spell/alien_spell/evolve/queen
	name = "Evolve"
	desc = "Evolve into an Alien Queen."
	action_icon_state = "alienq_running"
	queen_check = TRUE
	evolution_path = /mob/living/carbon/alien/humanoid/queen/large


/obj/effect/proc_holder/spell/alien_spell/evolve/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/alien_spell/evolve/cast(list/targets, mob/living/carbon/user)

	if(queen_check)
		for(var/mob/living/carbon/alien/humanoid/queen/living_queen in GLOB.alive_mob_list)
			if(living_queen.key && living_queen.get_int_organ(/obj/item/organ/internal/brain)) // We do a once over to check the queen didn't end up going away into the magic land of semi-dead
				to_chat(user, "<span class='notice'>We already have an alive queen.</span>")
				return

	if(user.has_brain_worms())
		to_chat(user, "<span class='warning'>We cannot perform this ability at the present time!</span>")
		revert_cast(user)
		return

	// If there is no queen, that means we can evolve
	to_chat(user, "<span class='noticealien'>You begin to evolve!</span>")
	user.visible_message("<span class='alertalien'>[user] begins to twist and contort!</span>")
	var/mob/living/carbon/alien/new_xeno = new evolution_path(user.loc)
	user.mind.transfer_to(new_xeno)
	new_xeno.mind.name = new_xeno.name
	playsound_xenobuild(user.loc)
	SSblackbox.record_feedback("tally", "alien_growth", 1, "[new_xeno]")
	qdel(user)

