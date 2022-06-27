/obj/effect/proc_holder/spell/targeted/morph_spell
	action_background_icon_state = "bg_morph"
	clothes_req = FALSE
	/// How much food it costs the morph to use this
	var/hunger_cost = 0

/obj/effect/proc_holder/spell/targeted/morph_spell/proc/update_name()
	if(hunger_cost)
		name = "[initial(name)] ([hunger_cost])"
		if (action)
			action.name = name

/obj/effect/proc_holder/spell/targeted/morph_spell/Initialize(mapload)
	. = ..()
	update_name()

/obj/effect/proc_holder/spell/targeted/morph_spell/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(user.gathered_food < hunger_cost)
		if(show_message)
			to_chat(user, "<span class='warning'>You require at least [hunger_cost] stored food to use this ability!</span>")
		return FALSE

/obj/effect/proc_holder/spell/targeted/click/morph_spell
	action_background_icon_state = "bg_morph"
	clothes_req = FALSE
	/// How much food it costs the morph to use this
	var/hunger_cost = 0

/obj/effect/proc_holder/spell/targeted/click/morph_spell/Initialize(mapload)
	. = ..()
	if(hunger_cost)
		name = "[name] ([hunger_cost])"

/obj/effect/proc_holder/spell/targeted/click/morph_spell/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(user.gathered_food < hunger_cost)
		if(show_message)
			to_chat(user, "<span class='warning'>You require at least [hunger_cost] stored food to use this ability!</span>")
		return FALSE
