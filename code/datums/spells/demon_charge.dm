/obj/effect/immovablerod/demon
	name = "Demon"
	desc = "Oh no!"
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	var/mob/living/caster
	var/max_distance = 7
	var/turf/start_turf
	notify = FALSE

/obj/effect/proc_holder/spell/demon_charge
	name = "Demon Charge"
	desc = "Take on the form of an immovable rod, destroying all in your path."
	clothes_req = FALSE
	human_req = FALSE
	base_cooldown = 50
	cooldown_min = 50
	action_icon_state = "immrod"
	centcom_cancast = FALSE
	var/bloodcharge = TRUE
	var/rod_delay = 2

/obj/effect/proc_holder/spell/demon_charge/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/demon_charge/cast(list/targets,mob/user = usr)
	if(get_turf(user) != user.loc)
		to_chat(user, "<span class='warning'>You must be phased in to charge!</span>")
		revert_cast()
		return FALSE
	if(!bloodcharge)
		to_chat(user, "<span class='warning'>You need to consume a sentient new victim!</span>")
		return FALSE
	for(var/mob/living/M in targets)
		var/turf/start = get_turf(M)
		var/list/voice = list('sound/hallucinations/behind_you1.ogg', 'sound/hallucinations/im_here1.ogg', 'sound/hallucinations/turn_around1.ogg', 'sound/hallucinations/i_see_you1.ogg')
		playsound(start, pick(voice), 50, TRUE, -1)
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

/obj/effect/proc_holder/spell/demon_slam
	name = "Demon Slam"
	desc = "Slam the ground!"
	clothes_req = FALSE
	human_req = FALSE
	base_cooldown = 50
	cooldown_min = 50
	action_icon_state = "immrod"
	centcom_cancast = TRUE
	var/bloodcharge = TRUE

/obj/effect/proc_holder/spell/demon_slam/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/demon_slam/cast(list/targets,mob/user = usr)
	if(get_turf(user) != user.loc)
		to_chat(user, "<span class='warning'>You must be phased in to slam!</span>")
		revert_cast()
		return FALSE
	if(!bloodcharge)
		to_chat(user, "<span class='warning'>You need to consume a sentient new victim!</span>")
		return FALSE
	var/turf/origin_point = get_turf(user)
	for(var/mob/living/M in range(2, origin_point))
		if(M == user)
			continue
		M.adjustBruteLoss(20)
		M.Weaken(5 SECONDS)
	for(var/turf/T in range(2, origin_point))
		new /obj/effect/decal/cleanable/blood/splatter(T)
	bloodcharge = FALSE

