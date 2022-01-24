///Harvest
/mob/living/simple_animal/revenant/ClickOn(atom/A, params) //Copypaste from ghost code - revenants can't interact with the world directly.

	if(client.click_intercept)
		client.click_intercept.InterceptClickOn(src, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
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
					to_chat(src, "<span class='revenboldnotice'>Such a feast! [target] will yield much essence to you.</span>")
				if(90 to INFINITY)
					to_chat(src, "<span class='revenbignotice'>Ah, the perfect soul. [target] will yield massive amounts of essence to you.</span>")
			if(do_after(src, 20, 0, target = target)) //how about now
				if(!target.stat)
					to_chat(src, "<span class='revenwarning'>They are now powerful enough to fight off your draining.</span>")
					to_chat(target, "<span class='boldannounce'>You feel something tugging across your body before subsiding.</span>")
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
						to_chat(src, "<span class='revenboldnotice'>The perfection of [target]'s soul has increased your maximum essence level. Your new maximum essence is [essence_regen_cap].</span>")
					to_chat(src, "<span class='revennotice'>[target]'s soul has been considerably weakened and will yield no more essence for the time being.</span>")
					target.visible_message("<span class='warning'>[target] slumps onto the ground.</span>", \
 										   "<span class='revenwarning'>Violets lights, dancing in your vision, getting clo--</span>")
					drained_mobs.Add(mob_UID)
					add_attack_logs(src, target, "revenant harvested soul")
					target.death(0)
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
/obj/effect/proc_holder/spell/night_vision/revenant
	charge_max = 0
	panel = "Revenant Abilities"
	message = "<span class='revennotice'>You toggle your night vision.</span>"
	action_icon_state = "r_nightvision"
	action_background_icon_state = "bg_revenant"

//Transmit: the revemant's only direct way to communicate. Sends a single message silently to a single mob
/obj/effect/proc_holder/spell/revenant_transmit
	name = "Transmit"
	desc = "Telepathically transmits a message to the target."
	panel = "Revenant Abilities"
	charge_max = 0
	clothes_req = 0
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_revenant"

/obj/effect/proc_holder/spell/revenant_transmit/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	return T

/obj/effect/proc_holder/spell/revenant_transmit/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	for(var/mob/living/M in targets)
		spawn(0)
			var/msg = stripped_input(user, "What do you wish to tell [M]?", null, "")
			if(!msg)
				charge_counter = charge_max
				return
			log_say("(REVENANT to [key_name(M)]) [msg]", user)
			to_chat(user, "<span class='revennotice'><b>You transmit to [M]:</b> [msg]</span>")
			to_chat(M, "<span class='revennotice'><b>An alien voice resonates from all around...</b></span><i> [msg]</I>")


/obj/effect/proc_holder/spell/aoe_turf/revenant
	clothes_req = 0
	action_background_icon_state = "bg_revenant"
	panel = "Revenant Abilities (Locked)"
	name = "Report this to a coder"
	var/reveal = 80 //How long it reveals the revenant in deciseconds
	var/stun = 20 //How long it stuns the revenant in deciseconds
	var/locked = TRUE //If it's locked and needs to be unlocked before use
	var/unlock_amount = 100 //How much essence it costs to unlock
	var/cast_amount = 50 //How much essence it costs to use

/obj/effect/proc_holder/spell/aoe_turf/revenant/New()
	..()
	if(locked)
		name = "[initial(name)] ([unlock_amount]E)"
	else
		name = "[initial(name)] ([cast_amount]E)"

/obj/effect/proc_holder/spell/aoe_turf/revenant/can_cast(mob/living/simple_animal/revenant/user = usr, charge_check = TRUE, show_message = FALSE)
	if(user.inhibited)
		return FALSE
	if(charge_counter < charge_max)
		return FALSE
	if(locked)
		if(user.essence <= unlock_amount)
			return FALSE
	if(user.essence <= cast_amount)
		return FALSE
	return TRUE

/obj/effect/proc_holder/spell/aoe_turf/revenant/proc/attempt_cast(mob/living/simple_animal/revenant/user = usr)
	if(locked)
		if(!user.castcheck(-unlock_amount))
			charge_counter = charge_max
			return FALSE
		name = "[initial(name)] ([cast_amount]E)"
		to_chat(user, "<span class='revennotice'>You have unlocked [initial(name)]!</span>")
		panel = "Revenant Abilities"
		locked = FALSE
		charge_counter = charge_max
		return FALSE
	if(!user.castcheck(-cast_amount))
		charge_counter = charge_max
		return FALSE
	name = "[initial(name)] ([cast_amount]E)"
	user.reveal(reveal)
	user.stun(stun)
	if(action)
		action.UpdateButtonIcon()
	return TRUE

//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/obj/effect/proc_holder/spell/aoe_turf/revenant/overload
	name = "Overload Lights"
	desc = "Directs a large amount of essence into nearby electrical lights, causing lights to shock those nearby."
	charge_max = 200
	stun = 30
	cast_amount = 45
	var/shock_range = 2
	var/shock_damage = 20
	action_icon_state = "overload_lights"

/obj/effect/proc_holder/spell/aoe_turf/revenant/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = 5
	return T

/obj/effect/proc_holder/spell/aoe_turf/revenant/overload/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			select_lights(T, user)

/obj/effect/proc_holder/spell/aoe_turf/revenant/overload/proc/select_lights(turf/T, mob/living/simple_animal/revenant/user)
	for(var/obj/machinery/light/L in T.contents)
		INVOKE_ASYNC(src, .proc/shock_lights, L, user)

/obj/effect/proc_holder/spell/aoe_turf/revenant/overload/proc/shock_lights(obj/machinery/light/L, mob/living/simple_animal/revenant/user)
	if(!L.on)
		return
	L.visible_message("<span class='warning'><b>\The [L] suddenly flares brightly and begins to spark!</span>")
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
		do_sparks(4, 0, M)
		playsound(M, 'sound/machines/defib_zap.ogg', 50, TRUE, -1)

//Defile: Corrupts nearby stuff, unblesses floor tiles.
/obj/effect/proc_holder/spell/aoe_turf/revenant/defile
	name = "Defile"
	desc = "Twists and corrupts the nearby area as well as dispelling holy auras on floors."
	charge_max = 150
	stun = 10
	reveal = 40
	unlock_amount = 75
	cast_amount = 30
	action_icon_state = "defile"

/obj/effect/proc_holder/spell/aoe_turf/revenant/defile/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = 4
	return T

/obj/effect/proc_holder/spell/aoe_turf/revenant/defile/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(!attempt_cast(user))
		return
	for(var/turf/T in targets)
		T.defile()
		for(var/atom/A in T.contents)
			A.defile()

//Malfunction: Makes bad stuff happen to robots and machines.
/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction
	name = "Malfunction"
	desc = "Corrupts and damages nearby machines and mechanical objects."
	charge_max = 200
	cast_amount = 45
	unlock_amount = 150
	action_icon_state = "malfunction"

/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = 2
	return T

//A note to future coders: do not replace this with an EMP because it will wreck malf AIs and gang dominators and everyone will hate you.
/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			INVOKE_ASYNC(src, .proc/effect, user, T)

/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction/proc/effect(mob/living/simple_animal/revenant/user, turf/T)
	T.rev_malfunction(TRUE)
	for(var/atom/A in T.contents)
		A.rev_malfunction(TRUE)


/atom/proc/defile()
	return

/atom/proc/rev_malfunction(cause_emp = TRUE)
	return

/mob/living/carbon/human/rev_malfunction(cause_emp = TRUE)
	to_chat(src, "<span class='warning'>You feel [pick("your sense of direction flicker out", "a stabbing pain in your head", "your mind fill with static")].</span>")
	new /obj/effect/temp_visual/revenant(loc)
	if(cause_emp)
		emp_act(1)

/mob/living/simple_animal/bot/rev_malfunction(cause_emp = TRUE)
	if(!emagged)
		new /obj/effect/temp_visual/revenant(loc)
		locked = FALSE
		open = TRUE
		emag_act(null)

/obj/rev_malfunction(cause_emp = TRUE)
	if(prob(20))
		if(prob(50))
			new /obj/effect/temp_visual/revenant(loc)
		emag_act(null)
	else if(cause_emp)
		emp_act(1)

/obj/machinery/clonepod/rev_malfunction(cause_emp = TRUE)
	..(cause_emp = FALSE)

/obj/machinery/power/apc/rev_malfunction(cause_emp = TRUE)
	return

/obj/machinery/power/smes/rev_malfunction(cause_emp = TRUE)
	return

/mob/living/silicon/robot/rev_malfunction(cause_emp = TRUE)
	playsound(src, 'sound/machines/warning-buzzer.ogg', 50, 1)
	new /obj/effect/temp_visual/revenant(loc)
	spark_system.start()
	if(cause_emp)
		emp_act(1)

/turf/defile()
	if(flags & NOJAUNT)
		flags &= ~NOJAUNT
		new /obj/effect/temp_visual/revenant(loc)

/turf/simulated/wall/defile()
	..()
	if(prob(15))
		new/obj/effect/temp_visual/revenant(loc)
		ChangeTurf(/turf/simulated/wall/rust)

/turf/simulated/wall/indestructible/defile()
	return

/turf/simulated/wall/r_wall/defile()
	..()
	if(prob(15))
		new/obj/effect/temp_visual/revenant(loc)
		ChangeTurf(/turf/simulated/wall/r_wall/rust)

/mob/living/carbon/human/defile()
	to_chat(src, "<span class='warning'>You suddenly feel [pick("sick and tired", "tired and confused", "nauseated", "dizzy")].</span>")
	adjustStaminaLoss(25)
	adjustToxLoss(5)
	AdjustConfused(20, bound_lower = 0, bound_upper = 30)
	new /obj/effect/temp_visual/revenant(loc)

/obj/structure/window/defile()
	take_damage(rand(30,80))
	if(fulltile)
		new /obj/effect/temp_visual/revenant/cracks(loc)

/obj/structure/closet/defile()
	open()

/turf/simulated/floor/defile()
	..()
	if(prob(15))
		if(intact && floor_tile)
			new floor_tile(src)
		broken = 0
		burnt = 0
		make_plating(1)

/turf/simulated/floor/plating/defile()
	if(flags & NOJAUNT)
		flags &= ~NOJAUNT
		new /obj/effect/temp_visual/revenant(loc)

/turf/simulated/floor/engine/cult/defile()
	if(flags & NOJAUNT)
		flags &= ~NOJAUNT
		new /obj/effect/temp_visual/revenant(loc)

/obj/machinery/light/defile()
	flicker(30)

