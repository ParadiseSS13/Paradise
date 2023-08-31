//This is all Charlie's code, I'm putting it in before I forget but I'll have to actually figure out how to integrate it in
//Okay so we'd either need make it a subtype of /obj/effect/proc_holder/spell/flayer, refactor jaunts, or make this spell special
/obj/effect/proc_holder/spell/ethereal_jaunt/phase_shift
	name = "Phase Shift"
	desc = "Shift into the space between dimensions, making you invisible and invulnerable but unable to "
	base_cooldown = 10 SECONDS
	clothes_req = FALSE
	action_icon_state = "sacredflame"
	jaunt_water_effect = FALSE
	jaunt_in_time = 0
	jaunt_out_type = null
	jaunt_in_type = null
	var/sight_cache

/obj/effect/proc_holder/spell/ethereal_jaunt/phase_shift/create_jaunt_holder(turf/mobloc, mob/living/target)
	var/obj/effect/dummy/spell_jaunt/holder = ..()
	holder.movespeed = target.movement_delay()
	return holder

/obj/effect/proc_holder/spell/ethereal_jaunt/phase_shift/cast(list/targets, mob/user)
	. = ..()
	var/mob/living/target = targets[1]
	sight_cache = target.sight
	target.sight = SEE_TURFS | BLIND
	target.client.color = MATRIX_GREYSCALE
	addtimer(CALLBACK(src, PROC_REF(snap_back_to_reality), target), jaunt_duration)

/obj/effect/proc_holder/spell/ethereal_jaunt/phase_shift/proc/snap_back_to_reality(mob/living/target)
	target.sight = sight_cache
	target.client.color = null
	var/turf/T = get_turf(target)
	for(var/mob/living/L in T)
		if(L == target)
			continue
		L.gib() //lol, lmao even

/obj/effect/proc_holder/spell/ethereal_jaunt/do_jaunt(mob/living/target)
	target.notransform = TRUE
	var/turf/mobloc = get_turf(target)

	var/obj/effect/dummy/spell_jaunt/holder = create_jaunt_holder(mobloc, target)
	if(jaunt_out_type)
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
	ADD_TRAIT(target, TRAIT_IMMOBILIZED, "jaunt")
	holder.reappearing = 1
	playsound(get_turf(target), 'sound/magic/ethereal_exit.ogg', 50, 1, -1)
	sleep(jaunt_in_time * 4)
	if(jaunt_in_type)
		new jaunt_in_type(mobloc, holder.dir)
	target.setDir(holder.dir)
	sleep(jaunt_in_time)
	qdel(holder)
	if(QDELETED(target))
		return
	if(!is_blocked_turf(mobloc, TRUE))
		return
	for(var/turf/T in orange(7))
		if(isspaceturf(T))
			continue
		if(target.Move(T))
			target.remove_CC()
			REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, "jaunt")
			return
	for(var/turf/space/S in orange(7))
		if(target.Move(S))
			break
	REMOVE_TRAIT(target, TRAIT_IMMOBILIZED, "jaunt")
	target.remove_CC()

/obj/effect/proc_holder/spell/ethereal_jaunt/proc/create_jaunt_holder(turf/mobloc, mob/living/target)
	return new jaunt_type_path(mobloc)
