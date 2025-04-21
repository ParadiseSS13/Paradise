/mob/living/simple_animal/demon/pulse_demon/ClickOn(atom/A, params)
	if(client?.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if(next_click > world.time)
		return

	if(try_modified_click(A, params))
		return

	// escape out of whatever we've hijacked first
	if(isapc(A) && !isturf(loc) && (A in hijacked_apcs))
		A.attack_pulsedemon(src)
	else if(current_weapon && istype(current_weapon, /obj/item/gun/energy))
		// ironically, because ion guns override their emp_act, it's perfectly safe to be in one and be emp'd
		var/obj/item/gun/energy/G = current_weapon
		// we probably shouldn't be firing from inside a recharger or someone's bag
		if(iscarbon(G.loc) || isturf(G.loc))
			G.process_fire(A, src, FALSE)
			visible_message("<span class='danger'>[G] fires itself at [A]!</span>", "<span class='danger'>You force [G] to fire at [A]!</span>", "<span class='italics'>You hear \a [G.fire_sound_text]!</span>")
			changeNext_click(CLICK_CD_RANGE) // I can't actually find what the default gun fire cooldown is, so it's 1 second until someone enlightens me
			return
	else if(current_robot)
		log_admin("[key_name_admin(src)] made [key_name_admin(current_robot)] attack [A]")
		message_admins("<span class='notice'>[key_name_admin(src)] made [key_name_admin(current_robot)] attack [A]</span>")

		current_robot.ClickOn(A, params)
		changeNext_click(0.5 SECONDS)
		return
	else if(current_bot)
		if(A == current_bot)
			A.attack_ai(src)
		else
			current_bot.attack_integrated_pulsedemon(src, A)
			changeNext_click(0.5 SECONDS)
			return
	else if(get_area(A) == controlling_area)
		A.attack_pulsedemon(src)
	else
		..()
	changeNext_click(0.1 SECONDS)

// returns TRUE if any [modifier]ClickOn was called
/mob/living/simple_animal/demon/pulse_demon/proc/try_modified_click(atom/A, params)
	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		if(modifiers["shift"])
			MiddleShiftClickOn(A)
		else
			MiddleClickOn(A)
		return TRUE
	if(modifiers["shift"])
		ShiftClickOn(A)
		return TRUE
	if(modifiers["alt"])
		AltClickOn(A)
		return TRUE
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return TRUE
	return FALSE

// check area for all of these, then do AI actions
/mob/living/simple_animal/demon/pulse_demon/MiddleShiftClickOn(atom/A)
	if(get_area(A) == controlling_area)
		A.AIShiftMiddleClick(src)

/mob/living/simple_animal/demon/pulse_demon/ShiftClickOn(atom/A)
	if(get_area(A) == controlling_area)
		A.AIShiftClick(src)
	else
		examinate(A)

/mob/living/simple_animal/demon/pulse_demon/AltClickOn(atom/A)
	if(get_area(A) == controlling_area)
		A.AIAltClick(src)
	else
		AltClickNoInteract(src, A)

/mob/living/simple_animal/demon/pulse_demon/CtrlClickOn(atom/A)
	if(get_area(A) == controlling_area)
		A.AICtrlClick(src)

// for alt-click status tab
/mob/living/simple_animal/demon/pulse_demon/TurfAdjacent(turf/T)
	return get_area(T) == controlling_area || ..()

// for overrides in general
/atom/proc/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	return

/obj/machinery/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	return attack_ai(user)

// ai not allowed to use cams consoles
/obj/machinery/computer/security/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	return attack_hand(user)

// jump back into our apc
/obj/machinery/power/apc/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	if(user.loc != src)
		user.forceMove(src)
		user.current_power = src
		user.update_controlling_area()
	else
		attack_ai(user)

/mob/living/simple_animal/bot/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	if(user.loc == src)
		return
	to_chat(user, "<span class='warning'>You are now inside [src]. If it is destroyed, you will be dropped onto the ground, and may die if there is no cable under you.</span>")
	to_chat(user, "<span class='notice'>Leave it by jumping to a hijacked APC.</span>")
	ejectpai(user)
	user.forceMove(src)
	user.current_bot = src
	hijacked = TRUE

/mob/living/simple_animal/bot/relaymove(mob/user, dir)
	if(!on)
		to_chat(user, "[src] isn't turned on!")
		return
	if(ispulsedemon(user))
		var/mob/living/simple_animal/demon/pulse_demon/demon = user
		if(demon.bot_movedelay <= world.time && dir)
			Move(get_step(get_turf(src), dir))
			demon.bot_movedelay = world.time + (BOT_STEP_DELAY * (base_speed - 1)) * ((dir in GLOB.diagonals) ? SQRT_2 : 1)

/obj/machinery/recharger/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	user.forceMove(src)
	if(!charging)
		to_chat(user, "<span class='warning'>There is no weapon charging. Click again to retry.</span>")
		return
	to_chat(user, "<span class='notice'>You are now attempting to hijack [src], this will take approximately [user.hijack_time / 10] seconds.</span>")
	if(!do_after(user, user.hijack_time, FALSE, src))
		return
	if(!charging)
		to_chat(src, "<span class='warning'>Failed to hijack [src]</span>")
		return
	to_chat(user, "<span class='notice'>You are now inside [charging]. Click on a hijacked APC to return.</span>")
	user.forceMove(charging)
	user.current_weapon = charging

/obj/machinery/cell_charger/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	user.forceMove(src)
	if(!charging)
		to_chat(user, "<span class='warning'>There is no cell charging. Click again to retry.</span>")
		return
	to_chat(user, "<span class='notice'>You are now attempting to hijack [src], this will take approximately [user.hijack_time / 10] seconds.</span>")
	if(charging.rigged)
		to_chat(user, "<span class='notice'>You are now inside [charging]. Click on a hijacked APC to return.</span>")
		user.forceMove(charging)
		return
	if(!do_after(user, user.hijack_time, FALSE, src))
		return
	if(!charging)
		to_chat(src, "<span class='warning'>Failed to hijack [src].</span>")
		return
	to_chat(user, "<span class='notice'>You are now inside [charging]. Click on a hijacked APC to return.</span>")
	user.forceMove(charging)

/obj/machinery/recharge_station/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	user.forceMove(src)
	if(!isrobot(occupant))
		to_chat(user, "<span class='warning'>There is no silicon-based occupant inside. Click again to retry.</span>")
		return
	to_chat(user, "<span class='notice'>You are now attempting to hijack [occupant], this will take approximately [user.hijack_time / 10] seconds.</span>")
	var/mob/living/silicon/robot/R = occupant
	if(R in user.hijacked_robots)
		user.do_hijack_robot(occupant)
		return
	to_chat(R, "<span class='userdanger'>ALERT: ELECTRICAL MALEVOLENCE DETECTED, TARGETING SYSTEMS HIJACK IN PROGRESS</span>")
	if(!do_after(user, user.hijack_time, FALSE, src))
		return
	if(isrobot(occupant))
		user.do_hijack_robot(occupant)
		return
	to_chat(src, "<span class='warning'>Failed to hijack [src].</span>")

/mob/living/simple_animal/demon/pulse_demon/proc/do_hijack_robot(mob/living/silicon/robot/R)
	to_chat(src, "<span class='notice'>You are now inside [R]. Click on a hijacked APC to return.</span>")
	forceMove(R)
	current_robot = R
	if(!(R in hijacked_robots))
		hijacked_robots += R
		to_chat(R, "<span class='userdanger'>TARGETING SYSTEMS HIJACKED, REPORT ALL UNWANTED ACTIVITY</span>")

/obj/machinery/camera/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	if(user.loc != src)
		user.forceMove(src)
		to_chat(user, "<span class='notice'>You jump towards [src]. Click on a hijacked APC to return.</span>")

// see pulse_demon/say
/obj/machinery/hologram/holopad/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	if(user.loc != src)
		user.forceMove(src)
		to_chat(user, "<span class='notice'>You jump towards [src]. You can now communicate via the holopad's speaker. Click on a hijacked APC to return.</span>")

/obj/item/radio/attack_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user)
	if(user.loc != src)
		user.forceMove(src)
		to_chat(user, "<span class='notice'>You jump towards [src]. You can now communicate via radio. Click on a hijacked APC to return.</span>")
	else
		attack_ai(user)

/mob/living/simple_animal/bot/proc/attack_integrated_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user, atom/A)
	if(!on)
		return
	if(Adjacent(A))
		UnarmedAttack(A)
	else
		RangedAttack(A)

/mob/living/simple_animal/bot/secbot/attack_integrated_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user, atom/A)
	if(!on)
		return
	if(Adjacent(A))
		UnarmedAttack(A)
	else if(iscarbon(A))
		speak("Внимание, обнаружена угроза уровня 10!")
		playsound(loc, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50)
		visible_message("<b>[src]</b> points at [A.name]!")

/mob/living/simple_animal/bot/floorbot/attack_integrated_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user, atom/A)
	if(!on)
		return
	if(isfloorturf(A) && Adjacent(A))
		var/turf/simulated/floor/F = A
		// there was originally a 1% chance to break to lattice, but that doesn't help a pulse demon, so I don't see the point
		F.break_tile_to_plating()
		audible_message("<span class='danger'>[src] makes an excited booping sound.</span>")

/mob/living/simple_animal/bot/cleanbot/attack_integrated_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user, atom/A)
	if(!on)
		return
	if(isfloorturf(A) && Adjacent(A))
		var/turf/simulated/floor/F = A
		if(prob(50))
			F.MakeSlippery(TURF_WET_WATER)
		if(prob(50))
			visible_message("<span class='warning'>Something flies out of [src]! It seems to be acting oddly.</span>")
			if(!(locate(/obj/effect/decal/cleanable/blood/gibs) in F))
				new /obj/effect/decal/cleanable/blood/gibs(F)
				playsound(F, 'sound/effects/blobattack.ogg', 40, TRUE)

/mob/living/simple_animal/bot/mulebot/attack_integrated_pulsedemon(mob/living/simple_animal/demon/pulse_demon/user, atom/A)
	if(!on)
		return
	if(istype(A) && Adjacent(A) && ismovable(A))
		to_chat(user, "<span class='notice'You try to load [A] onto [src].</span>")
		load(A)
		return
	if(load)
		to_chat(user, "<span class='notice'You unload [load].</span>")
		unload(0)
