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
	to_chat(user, "<span class='boldnotice'>You have [user.gathered_food] left to use.</span>")

/obj/effect/proc_holder/spell/morph/revert_cast(mob/living/simple_animal/hostile/morph/user)
	user.add_food(hunger_cost)
	to_chat(user, "<span class='boldnotice'>You have [user.gathered_food] left to use.</span>")
	..()

/obj/effect/proc_holder/spell/morph/ambush
	name = "Prepare Ambush"
	desc = "Prepare an ambush. Dealing significantly more damage on the first hit and you will weaken the target. Only works while morphed. If the target tries to use you with their hands then you will do even more damage."
	action_icon_state = "morph_ambush"
	charge_max = 8 SECONDS

/obj/effect/proc_holder/spell/morph/ambush/cast_check(charge_check = TRUE, start_recharge = TRUE, mob/living/simple_animal/hostile/morph/user = usr)
	if(!istype(user))
		return ..() // Message is in there
	if(!user.morphed)
		to_chat(user, "<span class='warning'>You can only prepare an ambush if you're disguised!</span>")
		return FALSE
	if(user.ambush_prepared)
		to_chat(user, "<span class='warning'>You are already prepared!</span>")
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/morph/ambush/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	if(!istype(user) || !user.morphed || user.ambush_prepared)
		return FALSE
	return ..()

/obj/effect/proc_holder/spell/morph/ambush/choose_targets(mob/user)
	perform(list(user), TRUE, user, FALSE)

/obj/effect/proc_holder/spell/morph/ambush/cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	to_chat(user, "<span class='sinister'>You start preparing an ambush.</span>")
	if(!do_after(user, 4 SECONDS, FALSE, user, list(CALLBACK(src, .proc/prepare_check, user), FALSE)))
		if(!user.morphed)
			to_chat(user, "<span class='warning'>You need to stay morphed to prepare the ambush!</span>")
			return
		to_chat(user, "<span class='warning'>You need to stay still to prepare the ambush!</span>")
		return
	user.prepare_ambush()

/obj/effect/proc_holder/spell/morph/ambush/proc/prepare_check(mob/living/simple_animal/hostile/morph/user)
	return !user.morphed

/obj/effect/proc_holder/spell/morph/reproduce
	name = "Reproduce"
	desc = "Split yourself in half making a new morph."
	hunger_cost = 150 // 5 humans
	charge_max = 30 SECONDS
	action_icon_state = "morph_reproduce"


/obj/effect/proc_holder/spell/morph/reproduce/choose_targets(mob/user)
	perform(list(user), TRUE, user, FALSE)

/obj/effect/proc_holder/spell/morph/reproduce/cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	to_chat(user, "<span class='sinister'>You prepare to split in two.</span>")
	var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a morph?", ROLE_MORPH, TRUE, poll_time = 10 SECONDS, source = /mob/living/simple_animal/hostile/morph)
	if(!length(candidates))
		to_chat(user, "<span class='warning'>Your body refuses to split at the moment. Try again later.</span>")
		revert_cast(user)
		return
	var/mob/C = pick(candidates)

	var/mob/living/simple_animal/hostile/morph/new_morph = new /mob/living/simple_animal/hostile/morph(get_turf(user))
	var/datum/mind/player_mind = new /datum/mind(C.key)
	player_mind.active = TRUE
	player_mind.transfer_to(new_morph)
	new_morph.make_morph_antag()
	user.create_log(MISC_LOG, "Made a new morph using [src]", new_morph)

/obj/effect/proc_holder/spell/morph/open_vent
	name = "Open Vents"
	desc = "Spit out acidic puke on nearby vents or scrubbers. Will take a little while for the acid to take effect."
	action_icon_state = "acid_vent"
	charge_max = 10 SECONDS
	hunger_cost = 10

/obj/effect/proc_holder/spell/morph/open_vent/choose_targets(mob/user)
	var/list/targets = list()
	for(var/obj/machinery/atmospherics/unary/U in view(user, 1))
		if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
			var/obj/machinery/atmospherics/unary/vent_scrubber/S = U
			if(S.welded)
				targets += S
		else if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
			var/obj/machinery/atmospherics/unary/vent_scrubber/V = U
			if(V.welded)
				targets += V

	perform(targets, TRUE, user)

/obj/effect/proc_holder/spell/morph/open_vent/cast(list/targets, mob/user)
	if(!length(targets))
		to_chat(user, "<span class='warning'>No nearby welded vents found!</span>")
		revert_cast(user)
		return
	to_chat(user, "<span class='sinister'>You begin regurgitating up some acidic puke!</span>")
	if(!do_after(user, 2 SECONDS, FALSE, user))
		to_chat(user, "<span class='warning'>You swallow the acid again.</span>")
		revert_cast(user)
		return
	for(var/thing in targets)
		var/obj/machinery/atmospherics/unary/U = thing
		U.add_overlay(GLOB.acid_overlay, TRUE)
		addtimer(CALLBACK(src, .proc/unweld_vent, U), 2 SECONDS)
		playsound(U, 'sound/items/welder.ogg', 100, TRUE)

/obj/effect/proc_holder/spell/morph/open_vent/proc/unweld_vent(obj/machinery/atmospherics/unary/U)
	if(istype(U, /obj/machinery/atmospherics/unary/vent_scrubber))
		var/obj/machinery/atmospherics/unary/vent_scrubber/S = U
		S.welded = FALSE
	else if(istype(U, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_scrubber/V = U
		V.welded = FALSE
	U.update_icon()
	U.cut_overlay(GLOB.acid_overlay, TRUE)
