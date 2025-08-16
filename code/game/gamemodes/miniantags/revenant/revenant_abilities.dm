///Harvest
/mob/living/simple_animal/revenant/ClickOn(atom/A, params) //Copypaste from ghost code - revenants can't interact with the world directly.

	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["middle"] && modifiers["shift"] && modifiers["ctrl"])
		MiddleShiftControlClickOn(A)
		return
	if(modifiers["middle"] && modifiers["shift"])
		MiddleShiftClickOn(A)
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["shift"] && modifiers["alt"])
		AltShiftClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"])
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(world.time <= next_move)
		return
	A.attack_ghost(src)
	if(ishuman(A) && in_range(src, A))
		if(isLivingSSD(A) && client.send_ssd_warning(A)) //Do NOT Harvest SSD people unless you accept the warning
			return
		Harvest(A)

/mob/living/simple_animal/revenant/proc/Harvest(mob/living/carbon/human/target)
	if(!castcheck(0))
		return
	if(draining)
		to_chat(src, "<span class='revenwarning'>You are already siphoning the essence of a soul!</span>")
		return
	var/mob_UID = target.UID()
	if(mob_UID in drained_mobs)
		to_chat(src, "<span class='revenwarning'>[target]'s soul is dead and empty.</span>")
		return
	if(!target.stat)
		to_chat(src, "<span class='revennotice'>This being's soul is too strong to harvest.</span>")
		if(prob(10))
			to_chat(target, "You feel as if you are being watched.")
		return
	draining = TRUE
	essence_drained = rand(15, 20)
	to_chat(src, "<span class='revennotice'>You search for the soul of [target].</span>")
	if(do_after(src, 10, 0, target = target)) //did they get deleted in that second?
		if(target.ckey)
			to_chat(src, "<span class='revennotice'>Their soul burns with intelligence.</span>")
			essence_drained += rand(20, 30)
		if(target.stat != DEAD)
			to_chat(src, "<span class='revennotice'>Their soul blazes with life!</span>")
			essence_drained += rand(40, 50)
		else
			to_chat(src, "<span class='revennotice'>Their soul is weak and faltering.</span>")
		if(do_after(src, 20, 0, target = target)) //did they get deleted NOW?
			switch(essence_drained)
				if(1 to 30)
					to_chat(src, "<span class='revennotice'>[target] will not yield much essence. Still, every bit counts.</span>")
				if(30 to 70)
					to_chat(src, "<span class='revennotice'>[target] will yield an average amount of essence.</span>")
				if(70 to 90)
					to_chat(src, "<span class='revennotice bold'>Such a feast! [target] will yield much essence to you.</span>")
				if(90 to INFINITY)
					to_chat(src, "<span class='revenbignotice'>Ah, the perfect soul. [target] will yield massive amounts of essence to you.</span>")
			if(do_after(src, 20, 0, target = target)) //how about now
				if(!target.stat)
					to_chat(src, "<span class='revenwarning'>They are now powerful enough to fight off your draining.</span>")
					to_chat(target, "<span class='boldannounceic'>You feel something tugging across your body before subsiding.</span>")
					draining = FALSE
					return //hey, wait a minute...
				to_chat(src, "<span class='revenminor'>You begin siphoning essence from [target]'s soul.</span>")
				if(target.stat != DEAD)
					to_chat(target, "<span class='warning'>You feel a horribly unpleasant draining sensation as your grip on life weakens...</span>")
				icon_state = "revenant_draining"
				reveal(27)
				stun(27)
				target.visible_message("<span class='warning'>[target] suddenly rises slightly into the air, [target.p_their()] skin turning an ashy gray.</span>")
				target.Beam(src,icon_state="drain_life",icon='icons/effects/effects.dmi',time=26)
				if(do_after(src, 30, 0, target)) //As one cannot prove the existance of ghosts, ghosts cannot prove the existance of the target they were draining.
					change_essence_amount(essence_drained, 0, target)
					if(essence_drained > 90)
						essence_regen_cap += 25
						perfectsouls += 1
						to_chat(src, "<span class='revennotice bold'>The perfection of [target]'s soul has increased your maximum essence level. Your new maximum essence is [essence_regen_cap].</span>")
					to_chat(src, "<span class='revennotice'>[target]'s soul has been considerably weakened and will yield no more essence for the time being.</span>")
					target.visible_message("<span class='warning'>[target] slumps onto the ground.</span>", \
										"<span class='revenwarning'>Violets lights, dancing in your vision, getting clo--</span>")
					drained_mobs.Add(mob_UID)
					add_attack_logs(src, target, "revenant harvested soul")
					target.death()
				else
					to_chat(src, "<span class='revenwarning'>[target ? "[target] has":"They have"] been drawn out of your grasp. The link has been broken.</span>")
					draining = 0
					essence_drained = 0
					if(target) //Wait, target is WHERE NOW?
						target.visible_message("<span class='warning'>[target] slumps onto the ground.</span>", \
											"<span class='revenwarning'>Violets lights, dancing in your vision, receding--</span>")
					return
			else
				to_chat(src, "<span class='revenwarning'>You are not close enough to siphon [target ? "[target]'s":"their"] soul. The link has been broken.</span>")
				draining = FALSE
				essence_drained = 0
				return
	draining = FALSE
	essence_drained = 0
	return

//Toggle night vision: lets the revenant toggle its night vision
/datum/spell/night_vision/revenant
	base_cooldown = 0
	message = "<span class='revennotice'>You toggle your night vision.</span>"
	action_icon_state = "r_nightvision"
	action_background_icon_state = "bg_revenant"

//Transmit: the revemant's only direct way to communicate. Sends a single message silently to a single mob
/datum/spell/revenant_transmit
	name = "Transmit"
	desc = "Telepathically transmits a message to the target."
	base_cooldown = 0
	clothes_req = FALSE
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_revenant"
	antimagic_flags = MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND

/datum/spell/revenant_transmit/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	return T

/datum/spell/revenant_transmit/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	for(var/mob/living/M in targets)
		spawn(0)
			var/msg = tgui_input_text(user, "What do you wish to tell [M]?", "Transmit")
			if(!msg)
				cooldown_handler.revert_cast()
				return
			log_say("(REVENANT to [key_name(M)]) [msg]", user)
			to_chat(user, "<span class='revennotice'><b>You transmit to [M]:</b> [msg]</span>")
			to_chat(M, "<span class='revennotice'><b>An alien voice resonates from all around...</b></span><i> [msg]</I>")

/datum/spell/aoe/revenant
	clothes_req = FALSE
	action_background_icon_state = "bg_revenant"
	/// How long it reveals the revenant in deciseconds
	var/reveal = 8 SECONDS
	/// How long it stuns the revenant in deciseconds
	var/stun = 2 SECONDS
	/// If it's locked and needs to be unlocked before use
	var/locked = TRUE
	/// How much essence it costs to unlock
	var/unlock_amount = 100
	/// How much essence it costs to use
	var/cast_amount = 50
	antimagic_flags = MAGIC_RESISTANCE_HOLY

/datum/spell/aoe/revenant/New()
	..()
	if(locked)
		name = "[initial(name)] ([unlock_amount]E)"
	else
		name = "[initial(name)] ([cast_amount]E)"
	action.name = name
	action.desc = desc
	action.build_all_button_icons()

/datum/spell/aoe/revenant/revert_cast(mob/user)
	. = ..()
	to_chat(user, "<span class='revennotice'>Your ability wavers and fails!</span>")
	var/mob/living/simple_animal/revenant/R = user
	R?.essence += cast_amount //refund the spell and reset

/datum/spell/aoe/revenant/can_cast(mob/living/simple_animal/revenant/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.inhibited)
		return FALSE
	if(cooldown_handler.is_on_cooldown())
		return FALSE
	if(locked)
		if(user.essence <= unlock_amount)
			return FALSE
	if(user.essence <= cast_amount)
		return FALSE
	return TRUE

/datum/spell/aoe/revenant/proc/attempt_cast(mob/living/simple_animal/revenant/user = usr)
	if(locked)
		if(!user.castcheck(-unlock_amount))
			cooldown_handler.revert_cast()
			return FALSE
		name = "[initial(name)] ([cast_amount]E)"
		to_chat(user, "<span class='revennotice'>You have unlocked [initial(name)]!</span>")
		locked = FALSE
		cooldown_handler.revert_cast()
		return FALSE
	if(!user.castcheck(-cast_amount))
		cooldown_handler.revert_cast()
		return FALSE
	name = "[initial(name)] ([cast_amount]E)"
	user.reveal(reveal)
	user.stun(stun)
	if(action)
		action.build_all_button_icons()
	return TRUE

//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/datum/spell/aoe/revenant/overload
	name = "Overload Lights"
	desc = "Directs a large amount of essence into nearby electrical lights, causing lights to shock those nearby."
	base_cooldown = 20 SECONDS
	stun = 3 SECONDS
	cast_amount = 45
	var/shock_range = 2
	var/shock_damage = 40
	action_icon_state = "overload_lights"
	aoe_range = 5

/datum/spell/aoe/revenant/overload/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()
	targeting.range = aoe_range
	targeting.allowed_type = /obj/machinery/light
	return targeting

/datum/spell/aoe/revenant/overload/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/obj/machinery/light/L as anything in targets)
			INVOKE_ASYNC(src, PROC_REF(shock_lights), L, user)

/datum/spell/aoe/revenant/overload/proc/shock_lights(obj/machinery/light/L, mob/living/simple_animal/revenant/user)
	if(!L.on)
		return
	L.visible_message("<span class='warning'><b>\The [L] suddenly flares brightly and begins to spark!</b></span>")
	do_sparks(4, 0, L)
	new /obj/effect/temp_visual/revenant(L.loc)
	sleep(2 SECONDS)
	if(!L.on) //wait, wait, don't shock me
		return
	flick("[L.base_state]2", L)
	for(var/mob/living/M in view(shock_range, L))
		if(M == user)
			continue
		M.Beam(L, icon_state = "purple_lightning", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
		M.electrocute_act(shock_damage, L, flags = SHOCK_NOGLOVES)
		M.Stun(3 SECONDS)
		do_sparks(4, 0, M)
		playsound(M, 'sound/machines/defib_zap.ogg', 50, TRUE, -1)

//Defile: Corrupts nearby stuff, unblesses floor tiles.
/datum/spell/aoe/revenant/defile
	name = "Defile"
	desc = "Twists and corrupts the nearby area as well as dispelling holy auras on floors. The presence of the living empowers the effects."
	base_cooldown = 15 SECONDS
	stun = 1 SECONDS
	reveal = 4 SECONDS
	unlock_amount = 75
	cast_amount = 30
	action_icon_state = "defile"
	aoe_range = 4

/datum/spell/aoe/revenant/defile/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/targeting = new()
	targeting.range = aoe_range
	return targeting

/datum/spell/aoe/revenant/defile/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!attempt_cast(user))
		return
	for(var/turf/T in targets)
		T.defile()
		for(var/atom/A in T.contents)
			if(istype(A, /obj/structure/window)) // we want to handle glass seperately
				continue
			A.defile()
		for(var/mob/living/carbon/human/living in T.contents)
			if(!living.mind || living.stat == DEAD) // shouldnt work on dead or mindless mobs
				continue
			var/obj/effect/warp_effect/supermatter/warp = new(T)
			warp.pixel_x += 16
			warp.pixel_y += 16
			animate(warp, time = 0.9 SECONDS, transform = matrix().Scale(0.2,0.2))
			for(var/obj/structure/window/W in range(2, living))
				W.defile()
			addtimer(CALLBACK(src, PROC_REF(delete_pulse), warp), 1 SECONDS)

/datum/spell/aoe/revenant/defile/proc/delete_pulse(warp)
	qdel(warp)

//Malfunction: Makes bad stuff happen to robots and machines.
/datum/spell/aoe/revenant/malfunction
	name = "Malfunction"
	desc = "Corrupts and damages nearby machines and mechanical objects."
	base_cooldown = 200
	cast_amount = 45
	unlock_amount = 150
	action_icon_state = "malfunction"
	aoe_range = 2

/datum/spell/aoe/revenant/malfunction/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/targeting = new()
	targeting.range = aoe_range
	return targeting

//A note to future coders: do not replace this with an EMP because it will wreck malf AIs and gang dominators and everyone will hate you.
/datum/spell/aoe/revenant/malfunction/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			INVOKE_ASYNC(src, PROC_REF(effect), user, T)

/datum/spell/aoe/revenant/malfunction/proc/effect(mob/living/simple_animal/revenant/user, turf/T)
	T.rev_malfunction(TRUE)
	for(var/atom/A in T.contents)
		A.rev_malfunction(TRUE)

/**
 * Makes objects be haunted and then throws them at conscious people to do damage, spooky!
 */
/datum/spell/aoe/revenant/haunt_object
	name = "Haunt Objects"
	desc = "Empower nearby objects to you with ghostly energy, causing them to attack nearby mortals. \
		Items closer to you are more likely to be haunted."
	action_icon_state = "haunt"
	base_cooldown = 60 SECONDS
	unlock_amount = 150
	stun = 3 SECONDS
	reveal = 10 SECONDS
	/// The maximum number of objects to haunt
	var/max_targets = 7
	/// A list of all attack timers started by this spell being cast
	var/list/attack_timers = list()

/datum/spell/aoe/revenant/haunt_object/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()
	targeting.range = aoe_range
	targeting.allowed_type = /obj/item
	return targeting

/datum/spell/aoe/revenant/haunt_object/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!attempt_cast(user))
		return

	var/successes = 0
	for(var/obj/item/nearby_item as anything in targets)
		if(successes >= max_targets) // End loop if we've already got 7 spooky items
			break

		// Don't throw around anchored things or dense things
		// (Or things not on a turf but I am not sure if range can catch that)
		if(nearby_item.anchored || nearby_item.density || nearby_item.move_resist == INFINITY || !isturf(nearby_item.loc))
			continue
		// Don't throw abstract things
		if(nearby_item.flags & ABSTRACT)
			continue
		// Don't throw things we can't see
		if(nearby_item.invisibility > user.see_invisible)
			continue

		var/distance_from_user = max(get_dist(get_turf(nearby_item), get_turf(user)), 1) // get_dist() for same tile dists return -1, we do not want that
		var/chance_of_haunting = 150 / distance_from_user // The further away things are, the less likely they are to be picked
		if(!prob(chance_of_haunting))
			continue

		make_spooky(nearby_item, user)
		successes++

	if(!successes) //no items to throw
		revert_cast()
		return

	// Stop the looping attacks after 65 seconds, roughly 14 attack cycles depending on lag
	addtimer(CALLBACK(src, PROC_REF(stop_timers)), 65 SECONDS, TIMER_UNIQUE)

/// Handles making an object haunted and setting it up to attack
/datum/spell/aoe/revenant/haunt_object/proc/make_spooky(obj/item/item_to_possess, mob/living/simple_animal/revenant/user)
	new /obj/effect/temp_visual/revenant(get_turf(item_to_possess)) // Thematic spooky visuals
	var/mob/living/basic/possessed_object/revenant/possessed_object = new(item_to_possess) // Begin haunting object
	addtimer(CALLBACK(possessed_object, TYPE_PROC_REF(/mob/living/basic/possessed_object, death)), 70 SECONDS, TIMER_UNIQUE) // De-haunt the object

/// Stop all attack timers cast by the previous spell use
/datum/spell/aoe/revenant/haunt_object/proc/stop_timers()
	for(var/I in attack_timers)
		deltimer(I)

/**
 * Gives everyone in a 7 tile radius 2 minutes of hallucinations
 */
/datum/spell/aoe/revenant/hallucinations
	name = "Hallucination Aura"
	desc = "Toy with the living nearby, giving them glimpses of things that could be or once were."
	action_icon_state = "hallucinations"
	base_cooldown = 15 SECONDS
	unlock_amount = 50
	cast_amount = 25
	stun = 1 SECONDS
	reveal = 3 SECONDS

/datum/spell/aoe/revenant/hallucinations/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()
	targeting.range = aoe_range
	targeting.allowed_type = /mob/living/carbon
	return targeting

/datum/spell/aoe/revenant/hallucinations/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!attempt_cast(user))
		return

	for(var/mob/living/carbon/M as anything in targets)
		M.AdjustHallucinate(120 SECONDS, bound_upper = 300 SECONDS) //Lets not let them get more than 5 minutes of hallucinations
		new /obj/effect/temp_visual/revenant(get_turf(M))

/// Begin defile and malfunction on-atom definitions

/atom/proc/defile()
	return

/atom/proc/rev_malfunction(cause_emp = TRUE)
	return

/mob/living/carbon/human/rev_malfunction(cause_emp = TRUE)
	to_chat(src, "<span class='warning'>You feel [pick("your sense of direction flicker out", "a stabbing pain in your head", "your mind fill with static")].</span>")
	new /obj/effect/temp_visual/revenant(loc)
	if(cause_emp)
		emp_act(EMP_HEAVY)

/mob/living/simple_animal/bot/rev_malfunction(cause_emp = TRUE)
	if(!emagged)
		new /obj/effect/temp_visual/revenant(loc)
		locked = FALSE
		open = TRUE
		emag_act(usr)

/obj/rev_malfunction(cause_emp = TRUE)
	if(prob(20))
		if(prob(50))
			new /obj/effect/temp_visual/revenant(loc)
		emag_act(usr)
	else if(cause_emp)
		emp_act(EMP_HEAVY)

/obj/machinery/clonepod/rev_malfunction(cause_emp = TRUE)
	..(cause_emp = FALSE)

/obj/machinery/power/apc/rev_malfunction(cause_emp = TRUE)
	return

/obj/machinery/power/smes/rev_malfunction(cause_emp = TRUE)
	return

/obj/machinery/computer/emergency_shuttle/rev_malfunction(cause_emp = TRUE)
	return

/mob/living/silicon/robot/rev_malfunction(cause_emp = TRUE)
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 1)
	new /obj/effect/temp_visual/revenant(loc)
	spark_system.start()
	if(cause_emp)
		emp_act(EMP_HEAVY)

/turf/defile()
	if(flags & BLESSED_TILE)
		flags &= ~BLESSED_TILE
		new /obj/effect/temp_visual/revenant(loc)

/turf/simulated/wall/defile()
	..()
	if(prob(15))
		new/obj/effect/temp_visual/revenant(loc)
		magic_rust_turf()

/turf/simulated/wall/indestructible/defile()
	return

/turf/simulated/wall/r_wall/defile()
	..()
	if(prob(15))
		new/obj/effect/temp_visual/revenant(loc)
		magic_rust_turf()

/mob/living/carbon/human/defile()
	to_chat(src, "<span class='warning'>You suddenly feel [pick("sick and tired", "tired and confused", "nauseated", "dizzy")].</span>")
	apply_damage(60, STAMINA)
	adjustToxLoss(5)
	AdjustConfused(40 SECONDS, bound_lower = 0, bound_upper = 60 SECONDS)
	new /obj/effect/temp_visual/revenant(loc)

/obj/structure/window/defile()
	take_damage(rand(30,80))
	if(fulltile)
		new /obj/effect/temp_visual/revenant/cracks(loc)

/obj/structure/closet/defile()
	open()

/obj/structure/morgue/defile()
	if(!connected && prob(25))
		toggle_tray()

/turf/simulated/floor/defile()
	..()
	if(locate(/mob/living/silicon/ai) in src) // Revs don't need a 1-button kill switch on AI cores
		return
	if(prob(15))
		if(intact && floor_tile)
			new floor_tile(src)
		broken = FALSE
		burnt = FALSE
		make_plating(1)
		magic_rust_turf()

/turf/simulated/floor/plating/defile()
	magic_rust_turf()
	if(flags & BLESSED_TILE)
		flags &= ~BLESSED_TILE
		new /obj/effect/temp_visual/revenant(loc)

/turf/simulated/floor/engine/cult/defile()
	if(flags & BLESSED_TILE)
		flags &= ~BLESSED_TILE
		new /obj/effect/temp_visual/revenant(loc)

/obj/machinery/light/defile()
	flicker(30)
