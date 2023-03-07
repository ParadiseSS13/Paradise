#define PD_HIJACK_CB(pd, proc) (CALLBACK(pd, TYPE_PROC_REF(/mob/living/simple_animal/pulse_demon, proc), src))
#define PD_HIJACK_FAIL(pd) (CALLBACK(pd, TYPE_PROC_REF(/mob/living/simple_animal/pulse_demon, fail_hijack)))

/mob/living/simple_animal/pulse_demon/ClickOn(atom/A, params)
	if (client && client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	if (next_click > world.time)
		return

	if (try_modified_click(A, params))
		return

	// escape out of whatever we've hijacked first
	if (istype(A, /obj/machinery/power/apc) && !isturf(loc) && (A in hijacked_apcs))
		A.attack_pulsedemon(src)
	else if (current_weapon && istype(current_weapon, /obj/item/gun/energy))
		// ironically, because ion guns override their emp_act, it's perfectly safe to be in one and be emp'd
		var/obj/item/gun/energy/G = current_weapon
		// we probably shouldn't be firing from inside a recharger or someone's bag
		if (iscarbon(G.loc) || isturf(G.loc))
			G.process_fire(A, src, FALSE)
			visible_message("<span class='danger'>[G] fires itself at [A]!</span>", "<span class='danger'>You force [G] to fire at [A]!</span>", "<span class='italics'>You hear \a [G.fire_sound_text]!</span>")
			changeNext_click(G.fire_delay)
			return
	else if (current_robot)
		log_admin("[key_name(src)] made [key_name(current_robot)] attack [A]")
		message_admins("<span class='notice'>[key_name(src)] made [key_name(current_robot)] attack [A]</span>")

		current_robot.ClickOn(A, params)
		changeNext_click(0.5 SECONDS)
		return
	else if (current_bot)
		if (A == current_bot)
			A.attack_ai(src)
		else
			current_bot.attack_integrated_pulsedemon(src, A)
			changeNext_click(0.5 SECONDS)
			return
	else if (get_area(A) == controlling_area)
		A.attack_pulsedemon(src)
	else
		..()
	changeNext_click(0.1 SECONDS)

// returns TRUE if any [modifier]ClickOn was called
/mob/living/simple_animal/pulse_demon/proc/try_modified_click(atom/A, params)
	var/list/modifiers = params2list(params)
	if (modifiers["middle"])
		if (modifiers["shift"])
			MiddleShiftClickOn(A)
		else
			MiddleClickOn(A)
		return TRUE
	if (modifiers["shift"])
		ShiftClickOn(A)
		return TRUE
	if (modifiers["alt"])
		AltClickOn(A)
		return TRUE
	if (modifiers["ctrl"])
		CtrlClickOn(A)
		return TRUE
	return FALSE

// check area for all of these, then do AI actions
/mob/living/simple_animal/pulse_demon/MiddleShiftClickOn(atom/A)
	if (get_area(A) == controlling_area)
		A.AIShiftMiddleClick(src)

/mob/living/simple_animal/pulse_demon/ShiftClickOn(atom/A)
	if (get_area(A) == controlling_area)
		A.AIShiftClick(src)
	else
		examinate(A)

/mob/living/simple_animal/pulse_demon/AltClickOn(atom/A)
	if (get_area(A) == controlling_area)
		A.AIAltClick(src)
	else
		AltClickNoInteract(src, A)

/mob/living/simple_animal/pulse_demon/CtrlClickOn(atom/A)
	if (get_area(A) == controlling_area)
		A.AICtrlClick(src)

// for alt-click status tab
/mob/living/simple_animal/pulse_demon/TurfAdjacent(turf/T)
	return (get_area(T) == controlling_area) || ..()

// for overrides in general
/atom/proc/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	return

/obj/machinery/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	return attack_ai(user)

// ai not allowed to use cams consoles
/obj/machinery/computer/security/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	return attack_hand(user)

// jump back into our apc
/obj/machinery/power/apc/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if (user.loc != src)
		user.forceMove(src)
		user.current_power = src
		user.controlling_area = apc_area
		user.current_robot = null
		if (user.current_bot)
			user.current_bot.hijacked = FALSE
		user.current_bot = null
		user.current_weapon = null
	else
		attack_ai(user)

/mob/living/simple_animal/bot/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if (user.loc != src)
		// TODO: maybe change bot death to just dump the demon on the ground?
		to_chat(user, "<span class='warning'>You are now inside [src]. If it is destroyed, you will instantly die.</span>")
		to_chat(user, "<span class='notice'>Leave it by jumping to a hijacked APC.</span>")
		ejectpai(user)
		user.forceMove(src)
		user.current_bot = src
		hijacked = TRUE

/mob/living/simple_animal/bot/relaymove(mob/user, dir)
	if (!on || !isturf(loc))
		return
	if (ispulsedemon(user))
		var/mob/living/simple_animal/pulse_demon/PD = user
		if (PD.bot_movedelay <= world.time && dir)
			step(src, dir)
			PD.bot_movedelay = world.time + (BOT_STEP_DELAY * (base_speed - 1)) * ((dir in GLOB.diagonals) ? SQRT_2 : 1)

/obj/machinery/recharger/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	user.forceMove(src)
	if (user.check_valid_recharger(src))
		if (!user.pb_helper.start(user, src, user.hijack_time, TRUE, PD_HIJACK_CB(user, check_valid_recharger), PD_HIJACK_CB(user, finish_hijack_recharger), PD_HIJACK_FAIL(user)))
			to_chat(user, "<span class='warning'>You are already performing an action!</span>")
		else
			user.do_hijack_notice()
	else
		to_chat(user, "<span class='warning'>There is no weapon charging. Click again to retry.</span>")

/mob/living/simple_animal/pulse_demon/proc/check_valid_recharger(obj/machinery/recharger/R)
	return R.charging

/mob/living/simple_animal/pulse_demon/proc/finish_hijack_recharger(obj/machinery/recharger/R)
	to_chat(src, "<span class='notice'>You are now inside [R.charging]. Click on a hijacked APC to return.</span>")
	forceMove(R.charging)
	current_weapon = R.charging

/obj/machinery/cell_charger/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	user.forceMove(src)
	if (user.check_valid_cell_charger(src))
		if (charging.rigged)
			user.finish_hijack_cell_charger(src)
			return
		if (!user.pb_helper.start(user, src, user.hijack_time, TRUE, PD_HIJACK_CB(user, check_valid_cell_charger), PD_HIJACK_CB(user, finish_hijack_cell_charger), PD_HIJACK_FAIL(user)))
			to_chat(user, "<span class='warning'>You are already performing an action!</span>")
		else
			user.do_hijack_notice()
	else
		to_chat(user, "<span class='warning'>There is no cell charging. Click again to retry.</span>")

/mob/living/simple_animal/pulse_demon/proc/check_valid_cell_charger(obj/machinery/cell_charger/C)
	return C.charging

/mob/living/simple_animal/pulse_demon/proc/finish_hijack_cell_charger(obj/machinery/cell_charger/C)
	to_chat(src, "<span class='notice'>You are now inside [C.charging]. Click on a hijacked APC to return.</span>")
	forceMove(C.charging)
	C.charging.rigged = TRUE

/obj/machinery/recharge_station/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	user.forceMove(src)
	if (user.check_valid_recharge_station(src))
		var/mob/living/silicon/robot/R = occupant
		if (R in user.hijacked_robots)
			user.finish_hijack_recharge_station(src)
			return
		if (!user.pb_helper.start(user, src, user.hijack_time, TRUE, PD_HIJACK_CB(user, check_valid_recharge_station), PD_HIJACK_CB(user, finish_hijack_recharge_station), PD_HIJACK_FAIL(user)))
			to_chat(user, "<span class='warning'>You are already performing an action!</span>")
		else
			user.do_hijack_notice()
			to_chat(R, "<span class='danger'>ALERT: ELECTRICAL MALEVOLENCE DETECTED, TARGETING SYSTEMS HIJACK IN PROGRESS</span>")
	else
		to_chat(user, "<span class='warning'>There is no silicon-based occupant inside. Click again to retry.</span>")

/mob/living/simple_animal/pulse_demon/proc/check_valid_recharge_station(obj/machinery/recharge_station/R)
	return R.occupant && istype(R.occupant, /mob/living/silicon/robot)

/mob/living/simple_animal/pulse_demon/proc/finish_hijack_recharge_station(obj/machinery/recharge_station/RS)
	do_hijack_robot(RS.occupant)

/mob/living/simple_animal/pulse_demon/proc/do_hijack_robot(mob/living/silicon/robot/R)
	to_chat(src, "<span class='notice'>You are now inside [R]. Click on a hijacked APC to return.</span>")
	forceMove(R)
	current_robot = R
	if (!(R in hijacked_robots))
		hijacked_robots += R
		to_chat(R, "<span class='userdanger'>TARGETING SYSTEMS HIJACKED, REPORT ALL UNWANTED ACTIVITY</span>")

/obj/machinery/camera/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if (user.loc != src)
		user.forceMove(src)
		to_chat(user, "<span class='notice'>You jump towards [src]. Click on a hijacked APC to return.</span>")

// see pulse_demon/say
/obj/machinery/hologram/holopad/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if (user.loc != src)
		user.forceMove(src)
		to_chat(user, "<span class='notice'>You jump towards [src]. You can now communicate via the holopad's speaker. Click on a hijacked APC to return.</span>")

/obj/item/radio/attack_pulsedemon(mob/living/simple_animal/pulse_demon/user)
	if (user.loc != src)
		user.forceMove(src)
		to_chat(user, "<span class='notice'>You jump towards [src]. You can now communicate via radio. Click on a hijacked APC to return.</span>")
	else
		attack_ai(user)

// for overrides on bots
/atom/proc/attack_integrated_pulsedemon(mob/living/simple_animal/pulse_demon/user, atom/A)
	return

/mob/living/simple_animal/bot/attack_integrated_pulsedemon(mob/living/simple_animal/pulse_demon/user, atom/A)
	if (!on)
		return
	if (Adjacent(A))
		UnarmedAttack(A)
	else
		RangedAttack(A)

/mob/living/simple_animal/bot/secbot/attack_integrated_pulsedemon(mob/living/simple_animal/pulse_demon/user, atom/A)
	if (!on)
		return
	if (Adjacent(A))
		UnarmedAttack(A)
	else if (iscarbon(A))
		speak("Level 10 infraction alert!")
		playsound(loc, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, 0)
		visible_message("<b>[src]</b> points at [A.name]!")

/mob/living/simple_animal/bot/floorbot/attack_integrated_pulsedemon(mob/living/simple_animal/pulse_demon/user, atom/A)
	if (!on)
		return
	if (isfloorturf(A) && Adjacent(A))
		var/turf/simulated/floor/F = A
		// there was originally a 1% chance to break to lattice, but that doesn't help a pulse demon, so I don't see the point
		F.break_tile_to_plating()
		audible_message("<span class='danger'>[src] makes an excited booping sound.</span>")

/mob/living/simple_animal/bot/cleanbot/attack_integrated_pulsedemon(mob/living/simple_animal/pulse_demon/user, atom/A)
	if (!on)
		return
	if (isfloorturf(A) && Adjacent(A))
		var/turf/simulated/floor/F = A
		if (prob(50))
			F.MakeSlippery(TURF_WET_WATER)
		if (prob(50))
			audible_message("<span class='warning'>Something flies out of [src]! He seems to be acting oddly.</span>")
			if (!(locate(/obj/effect/decal/cleanable/blood/gibs) in F))
				new /obj/effect/decal/cleanable/blood/gibs(F)

/mob/living/simple_animal/bot/mulebot/attack_integrated_pulsedemon(mob/living/simple_animal/pulse_demon/user, atom/A)
	if (!on)
		return
	if (istype(A) && Adjacent(A))
		if (ismovable(A))
			to_chat(user, "You try to load [A] onto [src].")
			load(A)
			return
	if (load)
		to_chat(user, "You unload [load].")
		unload(0)

#undef PD_HIJACK_CB
#undef PD_HIJACK_FAIL
