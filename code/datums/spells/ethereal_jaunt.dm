/obj/effect/proc_holder/spell/ethereal_jaunt
	name = "Ethereal Jaunt"
	desc = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."

	school = "transmutation"
	charge_max = 300
	clothes_req = 1
	invocation = "none"
	invocation_type = "none"
	cooldown_min = 100 //50 deciseconds reduction per rank
	nonabstract_req = 1
	centcom_cancast = 0 //Prevent people from getting to centcom
	var/sound1 = 'sound/magic/ethereal_enter.ogg'
	var/jaunt_duration = 50 //in deciseconds
	var/jaunt_in_time = 5
	var/jaunt_in_type = /obj/effect/temp_visual/wizard
	var/jaunt_out_type = /obj/effect/temp_visual/wizard/out
	var/jaunt_type_path = /obj/effect/dummy/spell_jaunt
	var/jaunt_water_effect = TRUE

	action_icon_state = "jaunt"

/obj/effect/proc_holder/spell/ethereal_jaunt/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/ethereal_jaunt/cast(list/targets, mob/user = usr) //magnets, so mostly hardcoded
	playsound(get_turf(user), sound1, 50, 1, -1)
	for(var/mob/living/target in targets)
		if(!target.can_safely_leave_loc()) // No more brainmobs hopping out of their brains
			to_chat(target, "<span class='warning'>You are somehow too bound to your current location to abandon it.</span>")
			continue
		INVOKE_ASYNC(src, .proc/do_jaunt, target)

/obj/effect/proc_holder/spell/ethereal_jaunt/proc/do_jaunt(mob/living/target)
	target.notransform = 1
	var/turf/mobloc = get_turf(target)
	var/obj/effect/dummy/spell_jaunt/holder = new jaunt_type_path(mobloc)
	new jaunt_out_type(mobloc, target.dir)
	target.ExtinguishMob()
	target.forceMove(holder)
	target.reset_perspective(holder)
	target.notransform = 0 //mob is safely inside holder now, no need for protection.
	if(jaunt_water_effect)
		jaunt_steam(mobloc)

	sleep(jaunt_duration)

	if(target.loc != holder) //mob warped out of the warp
		qdel(holder)
		return
	mobloc = get_turf(target.loc)
	if(jaunt_water_effect)
		jaunt_steam(mobloc)
	target.canmove = 0
	holder.reappearing = 1
	playsound(get_turf(target), 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
	sleep(jaunt_in_time * 4)
	new jaunt_in_type(mobloc, holder.dir)
	target.setDir(holder.dir)
	sleep(jaunt_in_time)
	qdel(holder)
	if(!QDELETED(target))
		if(is_blocked_turf(mobloc, TRUE))
			for(var/turf/T in orange(7))
				if(isspaceturf(T))
					continue
				if(target.Move(T))
					target.remove_CC()
					return
			for(var/turf/space/S in orange(7))
				if(target.Move(S))
					break
		target.remove_CC()

/obj/effect/proc_holder/spell/ethereal_jaunt/proc/jaunt_steam(mobloc)
	var/datum/effect_system/steam_spread/steam = new /datum/effect_system/steam_spread()
	steam.set_up(10, 0, mobloc)
	steam.start()

/obj/effect/dummy/spell_jaunt
	name = "water"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	var/reappearing = 0
	var/movedelay = 0
	var/movespeed = 2
	density = 0
	anchored = 1
	invisibility = 60
	resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

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

/obj/effect/dummy/spell_jaunt/proc/can_move(turf/T)
	if(T.flags & NOJAUNT)
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


/obj/effect/dummy/spell_jaunt/blood_pool/can_move(turf/T)
	if(isspaceturf(T) || T.density)
		return FALSE
	return TRUE
