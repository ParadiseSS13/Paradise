/obj/effect/proc_holder/spell/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
	school = "transmutation"
	action_icon_state = "jaunt"
	base_cooldown = 30 SECONDS
	clothes_req = TRUE
	cooldown_min = 10 SECONDS //50 deciseconds reduction per rank
	nonabstract_req = TRUE
	centcom_cancast = FALSE //Prevent people from getting to centcom
	var/sound_in = 'sound/magic/ethereal_enter.ogg'
	var/sound_out = 'sound/magic/ethereal_exit.ogg'
	var/jaunt_duration = 5 SECONDS //in deciseconds
	var/jaunt_in_time = 0.5 SECONDS
	var/jaunt_in_type = /obj/effect/temp_visual/wizard
	var/jaunt_out_type = /obj/effect/temp_visual/wizard/out
	var/jaunt_type_path = /obj/effect/dummy/spell_jaunt
	var/jaunt_water_effect = TRUE


/obj/effect/proc_holder/spell/ethereal_jaunt/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/ethereal_jaunt/cast(list/targets, mob/user = usr) //magnets, so mostly hardcoded
	for(var/mob/living/target in targets)
		if(!target.can_safely_leave_loc()) // No more brainmobs hopping out of their brains
			to_chat(target, "<span class='warning'>You are somehow too bound to your current location to abandon it.</span>")
			continue
		INVOKE_ASYNC(src, PROC_REF(do_jaunt), target)


/obj/effect/proc_holder/spell/ethereal_jaunt/proc/do_jaunt(mob/living/target)
	playsound(get_turf(target), sound_in, 50, TRUE, -1)
	target.notransform = TRUE
	var/turf/mobloc = get_turf(target)
	var/obj/effect/dummy/spell_jaunt/holder = new jaunt_type_path(mobloc)
	new jaunt_out_type(mobloc, target.dir)
	target.ExtinguishMob()
	target.forceMove(holder)
	target.reset_perspective(holder)
	target.notransform = FALSE //mob is safely inside holder now, no need for protection.
	if(jaunt_water_effect)
		jaunt_steam(mobloc)

	sleep(jaunt_duration)

	if(target.loc != holder) //mob warped out of the warp
		qdel(holder)
		return
	mobloc = get_turf(target.loc)
	if(jaunt_water_effect)
		jaunt_steam(mobloc)

	target.canmove = FALSE
	holder.reappearing = TRUE
	playsound(mobloc, sound_out, 50, TRUE, -1)

	sleep(jaunt_in_time * 4)
	mobloc = get_turf(target.loc)
	new jaunt_in_type(mobloc, holder.dir)
	target.setDir(holder.dir)

	sleep(jaunt_in_time)
	qdel(holder)

	if(QDELETED(target))
		return

	mobloc = get_turf(target.loc)
	if(is_blocked_turf(mobloc, TRUE))
		for(var/turf/T in orange(7))
			if(isspaceturf(T))
				continue
			if(target.Move(T))
				target.remove_CC()
				target.canmove = TRUE
				return
		for(var/turf/space/space_turf in orange(7))
			if(target.Move(space_turf))
				break
	target.canmove = TRUE
	target.remove_CC()


/obj/effect/proc_holder/spell/ethereal_jaunt/proc/jaunt_steam(mobloc)
	var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
	steam.set_up(10, 0, mobloc)
	steam.start()


/obj/effect/dummy/spell_jaunt
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = 60
	density = FALSE
	anchored = TRUE
	var/reappearing = FALSE
	var/movedelay = 0
	var/movespeed = 2


/obj/effect/dummy/spell_jaunt/Destroy()
	// Eject contents if deleted somehow
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
	return ..()


/obj/effect/dummy/spell_jaunt/relaymove(mob/user, direction)
	if((movedelay > world.time) || reappearing || !direction)
		return
	var/turf/newLoc = get_step(src,direction)
	setDir(direction)
	if(can_move(newLoc))
		forceMove(newLoc)
	else
		to_chat(user, "<span class='warning'>Something is blocking the way!</span>")
	movedelay = world.time + movespeed


/obj/effect/dummy/spell_jaunt/proc/can_move(turf/target_turf)
	if(target_turf.flags & NOJAUNT)
		return FALSE
	return TRUE


/obj/effect/dummy/spell_jaunt/ex_act(blah)
	return


/obj/effect/dummy/spell_jaunt/bullet_act(blah)
	return


/obj/effect/dummy/spell_jaunt/blood_pool
	name = "sanguine pool"
	desc = "a pool of living blood."
	movespeed = 1.5


/obj/effect/dummy/spell_jaunt/blood_pool/relaymove(mob/user, direction)
	..()
	new /obj/effect/decal/cleanable/blood(loc)


/obj/effect/dummy/spell_jaunt/blood_pool/can_move(turf/target_turf)
	if(isspaceturf(target_turf) || target_turf.density)
		return FALSE
	return TRUE

