/obj/effect/immovablerod/demon
	name = "Demon"
	desc = "Oh no!"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	notify = FALSE
	var/mob/living/caster
	var/max_distance = 7
	var/turf/start_turf

/datum/spell/demon_charge
	name = "Demon Charge"
	desc = "Perform a powerful charge, crushing all in your path."
	clothes_req = FALSE
	human_req = FALSE
	base_cooldown = 5 SECONDS
	cooldown_min = 5 SECONDS
	action_icon_state = "immrod"
	centcom_cancast = FALSE
	///Used when casting, eating a mob with a mind resets this to active again
	var/bloodcharge = TRUE

/datum/spell/demon_charge/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/demon_charge/cast(list/targets, mob/user = usr)
	if(get_turf(user) != user.loc)
		to_chat(user, "<span class='warning'>You must be phased in to charge!</span>")
		revert_cast()
		return FALSE
	if(!bloodcharge)
		to_chat(user, "<span class='warning'>You need to consume a sentient new victim!</span>")
		return FALSE
	for(var/mob/living/M in targets)
		var/turf/start = get_turf(M)
		playsound(start, 'sound/effects/creepyshriek.ogg', 50, TRUE, -1)
		var/obj/effect/immovablerod/demon/D = new(start, get_ranged_target_turf(M, M.dir, 15), 2)
		D.caster = M
		D.max_distance = 7
		D.start_turf = start
		M.forceMove(D)
		M.notransform = TRUE
		M.status_flags |= GODMODE
	bloodcharge = FALSE

/obj/effect/immovablerod/demon/Move()
	if(!locate(/obj/effect/decal/cleanable/blood) in get_turf(src))
		createFootprintsFrom(src, src.dir, get_turf(src))
	if(get_dist(start_turf, get_turf(src)) >= max_distance)
		qdel(src)
	..()

/obj/effect/immovablerod/demon/Destroy()
	if(caster)
		caster.status_flags &= ~GODMODE
		caster.notransform = FALSE
		caster.forceMove(get_turf(src))
	return ..()

/datum/spell/demon_slam
	name = "Demon Slam"
	desc = "Slam the ground!"
	clothes_req = FALSE
	human_req = FALSE
	base_cooldown = 5 SECONDS
	cooldown_min = 5 SECONDS
	action_icon_state = "seismic_stomp"
	centcom_cancast = TRUE
	///Used when casting, eating a mob with a mind resets this to active again
	var/bloodcharge = TRUE

/datum/spell/demon_slam/create_new_targeting()
	return new /datum/spell_targeting/self

/datum/spell/demon_slam/cast(list/targets, mob/user = usr)
	if(get_turf(user) != user.loc)
		to_chat(user, "<span class='warning'>You must be phased in to slam!</span>")
		revert_cast()
		return FALSE
	if(!bloodcharge)
		to_chat(user, "<span class='warning'>You need to consume a sentient new victim!</span>")
		return FALSE
	var/turf/origin_point = get_turf(user)
	playsound(origin_point, 'sound/effects/bang.ogg', 100, TRUE, -1)
	user.visible_message("<span class='danger'>[user] slams the ground!</span>")
	for(var/mob/living/M in range(2, origin_point))
		if(M == user)
			continue
		M.adjustBruteLoss(20)
		M.Weaken(5 SECONDS)
	for(var/turf/T in range(2, origin_point))
		new /obj/effect/decal/cleanable/blood/splatter(T)
	bloodcharge = FALSE

