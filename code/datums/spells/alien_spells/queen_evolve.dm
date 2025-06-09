/datum/spell/alien_spell/evolve_queen
	name = "Evolve into an alien queen"
	desc = "Evolve into an alien queen."
	plasma_cost = 300
	action_icon_state = "alien_evolve_drone"

/datum/spell/alien_spell/evolve_queen/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/alien_spell/evolve_queen/cast(list/targets, mob/living/carbon/user)
	/// First we check if there is a living queen
	for(var/mob/living/carbon/alien/humanoid/queen/living_queen in GLOB.alive_mob_list)
		if(living_queen.key || !living_queen.get_int_organ(/obj/item/organ/internal/brain)) // We do a once over to check the queen didn't end up going away into the magic land of semi-dead
			to_chat(user, "<span class='notice'>We already have a living queen.</span>")
			revert_cast(user)
			return
	// If there is no queen, that means we can evolve
	to_chat(user, "<span class='noticealien'>You begin to evolve!</span>")
	user.visible_message("<span class='alertalien'>[user] begins to twist and contort!</span>")
	var/mob/living/carbon/alien/humanoid/queen/new_xeno = new(get_turf(user))
	user.mind.transfer_to(new_xeno)
	new_xeno.mind.name = new_xeno.name
	SSblackbox.record_feedback("tally", "alien_growth", 1, "queen")
	qdel(user)
