/obj/structure/blob/core
	name = "blob core"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blank_blob"
	max_integrity = 400
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 75, "acid" = 90)
	fire_resist = 2
	point_return = -1
	var/overmind_get_delay = 0 // we don't want to constantly try to find an overmind, do it every 5 minutes
	var/resource_delay = 0
	var/point_rate = 2
	var/is_offspring = null
	var/selecting = 0

/obj/structure/blob/core/New(loc, var/h = 200, var/client/new_overmind = null, var/new_rate = 2, offspring)
	GLOB.blob_cores += src
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src
	adjustcolors(color) //so it atleast appears
	if(!overmind)
		create_overmind(new_overmind)
	if(overmind)
		adjustcolors(overmind.blob_reagent_datum.color)
	if(offspring)
		is_offspring = 1
	point_rate = new_rate
	..(loc, h)


/obj/structure/blob/core/adjustcolors(var/a_color)
	overlays.Cut()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	I.color = a_color
	overlays += I
	var/image/C = new('icons/mob/blob.dmi', "blob_core_overlay")
	overlays += C


/obj/structure/blob/core/Destroy()
	GLOB.blob_cores -= src
	if(overmind)
		overmind.blob_core = null
	overmind = null
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list.Remove(src)
	return ..()

/obj/structure/blob/core/ex_act(severity)
	var/damage = 50 - 10 * severity //remember, the core takes half brute damage, so this is 20/15/10 damage based on severity
	take_damage(damage, BRUTE, "bomb", 0)

/obj/structure/blob/core/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, overmind_reagent_trigger = 1)
	. = ..()
	if(obj_integrity > 0)
		if(overmind) //we should have an overmind, but...
			overmind.update_health_hud()

/obj/structure/blob/core/RegenHealth()
	return // Don't regen, we handle it in Life()

/obj/structure/blob/core/Life(seconds, times_fired)
	if(!overmind)
		create_overmind()
	else
		if(resource_delay <= world.time)
			resource_delay = world.time + 10 // 1 second
			overmind.add_points(point_rate)
	obj_integrity = min(max_integrity, obj_integrity + 1)
	if(overmind)
		overmind.update_health_hud()
	if(overmind)
		for(var/i = 1; i < 8; i += i)
			Pulse(0, i, overmind.blob_reagent_datum.color)
	else
		for(var/i = 1; i < 8; i += i)
			Pulse(0, i, color)
	for(var/b_dir in GLOB.alldirs)
		if(!prob(5))
			continue
		var/obj/structure/blob/normal/B = locate() in get_step(src, b_dir)
		if(B)
			B.change_to(/obj/structure/blob/shield/core)
			if(B && overmind)
				B.color = overmind.blob_reagent_datum.color
			else
				B.color = color
	color = null
	..()


/obj/structure/blob/core/proc/create_overmind(var/client/new_overmind, var/override_delay)
	if(overmind_get_delay > world.time && !override_delay)
		return

	overmind_get_delay = world.time + 3000 // 5 minutes

	if(overmind)
		qdel(overmind)

	var/mob/C = null
	var/list/candidates = list()

	spawn()
		if(!new_overmind)
			if(is_offspring)
				candidates = pollCandidates("Do you want to play as a blob offspring?", ROLE_BLOB, 1)
			else
				candidates = pollCandidates("Do you want to play as a blob?", ROLE_BLOB, 1)

			if(candidates.len)
				C = pick(candidates)
		else
			C = new_overmind

		if(C)
			var/mob/camera/blob/B = new(src.loc)
			B.key = C.key
			B.blob_core = src
			src.overmind = B
			color = overmind.blob_reagent_datum.color
			if(B.mind && !B.mind.special_role)
				B.mind.make_Overmind()
			spawn(0)
				if(is_offspring)
					B.is_offspring = TRUE

/obj/structure/blob/core/proc/lateblobtimer()
	addtimer(CALLBACK(src, .proc/lateblobcheck), 50)

/obj/structure/blob/core/proc/lateblobcheck()
	if(overmind)
		overmind.add_points(60)
		if(overmind.mind)
			overmind.mind.make_Overmind()
		else
			log_debug("/obj/structure/blob/core/proc/lateblobcheck: Blob core lacks a overmind.mind.")
	else
		log_debug("/obj/structure/blob/core/proc/lateblobcheck: Blob core lacks an overmind.")

/obj/structure/blob/core/onTransitZ(old_z, new_z)
	if(overmind && is_station_level(new_z))
		overmind.forceMove(get_turf(src))
	return ..()
