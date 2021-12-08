/obj/effect/proc_holder/spell/morph
	action_background_icon_state = "bg_morph"
	clothes_req = FALSE
	/// How much food it costs the morph to use this
	var/hunger_cost = 0

/obj/effect/proc_holder/spell/morph/Initialize(mapload)
	. = ..()
	if(hunger_cost)
		name = "[name] ([hunger_cost])"

/obj/effect/proc_holder/spell/morph/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/living/simple_animal/hostile/morph/user = usr)
	if(!istype(user))
		to_chat(user, "<span class='warning'>You should not be able to use this abilty! Report this as a bug on github please.</span>")
		stack_trace()
		log_debug("[user] has the spell [src] while he is not a morph")
		return FALSE
	if(user.gathered_food < hunger_cost)
		to_chat(user, "<span class='warning'>You require at least [hunger_cost] stored food to use this ability!</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/morph/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	if(!istype(user) || user.gathered_food < hunger_cost)
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/morph/before_cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	user.use_food(hunger_cost)
	if(hunger_cost)
		to_chat(user, "<span class='boldnotice'>You have [user.gathered_food] left to use.</span>")

/obj/effect/proc_holder/spell/morph/revert_cast(mob/living/simple_animal/hostile/morph/user)
	user.add_food(hunger_cost)
	to_chat(user, "<span class='boldnotice'>You have [user.gathered_food] left to use.</span>")
	..()
