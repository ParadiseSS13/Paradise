/datum/spell_handler/morph
	/// How much food it costs the morph to use this
	var/hunger_cost = 0

/datum/spell_handler/morph/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message, datum/spell/spell)
	if(!istype(user))
		if(show_message)
			to_chat(user, "<span class='warning'>You should not be able to use this ability! Report this as a bug on github please.</span>")
		return FALSE

	if(user.gathered_food < hunger_cost)
		if(show_message)
			to_chat(user, "<span class='warning'>You require at least [hunger_cost] stored food to use this ability!</span>")
		return FALSE

	return TRUE

/datum/spell_handler/morph/spend_spell_cost(mob/living/simple_animal/hostile/morph/user, datum/spell/spell)
	user.use_food(hunger_cost)

/datum/spell_handler/morph/before_cast(list/targets, mob/living/simple_animal/hostile/morph/user, datum/spell/spell)
	if(hunger_cost)
		to_chat(user, "<span class='boldnotice'>You have [user.gathered_food] left to use.</span>")

/datum/spell_handler/morph/revert_cast(mob/living/simple_animal/hostile/morph/user, datum/spell/spell)
	user.add_food(hunger_cost)
	to_chat(user, "<span class='boldnotice'>You have [user.gathered_food] left to use.</span>")
