///Harvest
/mob/living/simple_animal/revenant/ClickOn(var/atom/A, var/params) //Copypaste from ghost code - revenants can't interact with the world directly.

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
	if(target in drained_mobs)
		to_chat(src, "<span class='revenwarning'>[target]'s soul is dead and empty.</span>")
		return
	if(!target.stat)
		to_chat(src, "<span class='revennotice'>This being's soul is too strong to harvest.</span>")
		if(prob(10))
			to_chat(target, "You feel as if you are being watched.")
		return
	draining = 1
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
					draining = 0
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
					drained_mobs.Add(target)
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
				draining = 0
				essence_drained = 0
				return
	draining = 0
	essence_drained = 0
	return

//Toggle night vision: lets the revenant toggle its night vision
/obj/effect/proc_holder/spell/targeted/night_vision/revenant
	charge_max = 0
	panel = "Revenant Abilities"
	message = "<span class='revennotice'>You toggle your night vision.</span>"
	action_icon_state = "r_nightvision"
	action_background_icon_state = "bg_revenant"

//Transmit: the revemant's only direct way to communicate. Sends a single message silently to a single mob
/obj/effect/proc_holder/spell/targeted/revenant_transmit
	name = "Transmit"
	desc = "Telepathically transmits a message to the target."
	panel = "Revenant Abilities"
	charge_max = 0
	clothes_req = 0
	range = 7
	include_user = 0
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_revenant"

/obj/effect/proc_holder/spell/targeted/revenant_transmit/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
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
	var/locked = 1 //If it's locked and needs to be unlocked before use
	var/unlock_amount = 100 //How much essence it costs to unlock
	var/cast_amount = 50 //How much essence it costs to use

/obj/effect/proc_holder/spell/aoe_turf/revenant/New()
	..()
	if(locked)
		name = "[initial(name)] ([unlock_amount]E)"
	else
		name = "[initial(name)] ([cast_amount]E)"

/obj/effect/proc_holder/spell/aoe_turf/revenant/can_cast(mob/living/simple_animal/revenant/user = usr)
	if(user.inhibited)
		return 0
	if(charge_counter < charge_max)
		return 0
	if(locked)
		if(user.essence <= unlock_amount)
			return 0
	if(user.essence <= cast_amount)
		return 0
	return 1

/obj/effect/proc_holder/spell/aoe_turf/revenant/proc/attempt_cast(mob/living/simple_animal/revenant/user = usr)
	if(locked)
		if(!user.castcheck(-unlock_amount))
			charge_counter = charge_max
			return 0
		name = "[initial(name)] ([cast_amount]E)"
		to_chat(user, "<span class='revennotice'>You have unlocked [initial(name)]!</span>")
		panel = "Revenant Abilities"
		locked = 0
		charge_counter = charge_max
		return 0
	if(!user.castcheck(-cast_amount))
		charge_counter = charge_max
		return 0
	name = "[initial(name)] ([cast_amount]E)"
	user.reveal(reveal)
	user.stun(stun)
	if(action)
		action.UpdateButtonIcon()
	return 1

//Overload Light: Breaks a light that's online and sends out lightning bolts to all nearby people.
/obj/effect/proc_holder/spell/aoe_turf/revenant/overload
	name = "Overload Lights"
	desc = "Directs a large amount of essence into nearby electrical lights, causing lights to shock those nearby."
	charge_max = 200
	range = 5
	stun = 30
	cast_amount = 45
	var/shock_range = 2
	var/shock_damage = 20
	action_icon_state = "overload_lights"

/obj/effect/proc_holder/spell/aoe_turf/revenant/overload/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			spawn(0)
				for(var/obj/machinery/light/L in T.contents)
					spawn(0)
						if(!L.on)
							return
						L.visible_message("<span class='warning'><b>\The [L] suddenly flares brightly and begins to spark!</span>")
						do_sparks(4, 0, L)
						new/obj/effect/temp_visual/revenant(L.loc)
						sleep(20)
						if(!L.on) //wait, wait, don't shock me
							return
						flick("[L.base_state]2", L)
						for(var/mob/living/M in view(shock_range, L))
							if(M == user)
								return
							M.Beam(L,icon_state="purple_lightning",icon='icons/effects/effects.dmi',time=5)
							M.electrocute_act(shock_damage, L, safety = TRUE)
							do_sparks(4, 0, M)
							playsound(M, 'sound/machines/defib_zap.ogg', 50, 1, -1)

//Defile: Corrupts nearby stuff, unblesses floor tiles.
/obj/effect/proc_holder/spell/aoe_turf/revenant/defile
	name = "Defile"
	desc = "Twists and corrupts the nearby area as well as dispelling holy auras on floors."
	charge_max = 150
	range = 4
	stun = 10
	reveal = 40
	unlock_amount = 75
	cast_amount = 30
	action_icon_state = "defile"
	var/stamdamage= 25
	var/toxdamage = 5
	var/confusion = 20
	var/maxconfusion = 30

/obj/effect/proc_holder/spell/aoe_turf/revenant/defile/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			spawn(0)
				if(T.flags & NOJAUNT)
					T.flags -= NOJAUNT
					new/obj/effect/temp_visual/revenant(T)
				for(var/mob/living/carbon/human/human in T.contents)
					to_chat(human, "<span class='warning'>You suddenly feel [pick("sick and tired", "tired and confused", "nauseated", "dizzy")].</span>")
					human.adjustStaminaLoss(stamdamage)
					human.adjustToxLoss(toxdamage)
					human.AdjustConfused(confusion, bound_lower = 0, bound_upper = maxconfusion)
					new/obj/effect/temp_visual/revenant(human.loc)
				if(!istype(T, /turf/simulated/shuttle) && !istype(T, /turf/simulated/wall/rust) && !istype(T, /turf/simulated/wall/r_wall) && istype(T, /turf/simulated/wall) && prob(15))
					new/obj/effect/temp_visual/revenant(T)
					T.ChangeTurf(/turf/simulated/wall/rust)
				if(!istype(T, /turf/simulated/wall/r_wall/rust) && istype(T, /turf/simulated/wall/r_wall) && prob(15))
					new/obj/effect/temp_visual/revenant(T)
					T.ChangeTurf(/turf/simulated/wall/r_wall/rust)
				for(var/obj/structure/window/window in T.contents)
					window.take_damage(rand(30,80))
					if(window && window.fulltile)
						new/obj/effect/temp_visual/revenant/cracks(window.loc)
				for(var/obj/structure/closet/closet in T.contents)
					closet.open()

				if(!istype(T, /turf/simulated/floor/plating) && !istype(T, /turf/simulated/floor/engine/cult) && istype(T, /turf/simulated/floor) && prob(15))
					var/turf/simulated/floor/floor = T
					if(floor.intact)
						floor.builtin_tile.loc = floor
					floor.broken = 0
					floor.burnt = 0
					floor.make_plating(1)
				for(var/obj/machinery/light/light in T.contents)
					light.flicker(30) //spooky

//Malfunction: Makes bad stuff happen to robots and machines.
/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction
	name = "Malfunction"
	desc = "Corrupts and damages nearby machines and mechanical objects."
	charge_max = 200
	range = 2
	cast_amount = 45
	unlock_amount = 150
	action_icon_state = "malfunction"

//A note to future coders: do not replace this with an EMP because it will wreck malf AIs and gang dominators and everyone will hate you.
/obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction/cast(list/targets, mob/living/simple_animal/revenant/user = usr)
	if(attempt_cast(user))
		for(var/turf/T in targets)
			spawn(0)
				for(var/mob/living/simple_animal/bot/bot in T.contents)
					if(!bot.emagged)
						new/obj/effect/temp_visual/revenant(bot.loc)
						bot.locked = 0
						bot.open = 1
						bot.emag_act(null)
				for(var/mob/living/carbon/human/human in T.contents)
					to_chat(human, "<span class='warning'>You feel [pick("your sense of direction flicker out", "a stabbing pain in your head", "your mind fill with static")].</span>")
					new/obj/effect/temp_visual/revenant(human.loc)
					human.emp_act(1)
				for(var/obj/thing in T.contents)
					if(istype(thing, /obj/machinery/power/apc) || istype(thing, /obj/machinery/power/smes)) //Doesn't work on dominators, SMES and APCs, to prevent kekkery
						continue
					if(prob(20))
						if(prob(50))
							new/obj/effect/temp_visual/revenant(thing.loc)
						thing.emag_act(null)
					else
						if(!istype(thing, /obj/machinery/clonepod)) //I hate everything but mostly the fact there's no better way to do this without just not affecting it at all
							thing.emp_act(1)
				for(var/mob/living/silicon/robot/S in T.contents) //Only works on cyborgs, not AI
					playsound(S, 'sound/machines/warning-buzzer.ogg', 50, 1)
					new/obj/effect/temp_visual/revenant(S.loc)
					S.spark_system.start()
					S.emp_act(1)
