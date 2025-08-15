
/**
  * # Hallucination - Fake Grenade
  *
  * A random grenade is thrown near the target from offscreen.
  */
/obj/effect/hallucination/fake_grenade
	hallucination_layer = 3.1
	///A list of potential grenades to pick from, one is picked at random to copy
	var/list/grenade_type = list(/obj/item/grenade/chem_grenade, /obj/item/grenade/clusterbuster, /obj/item/grenade/spawnergrenade, /obj/item/grenade/empgrenade, /obj/item/grenade/flashbang, /obj/item/grenade/chem_grenade/large, /obj/item/grenade/syndieminibomb, /obj/item/grenade/chem_grenade/cryo, /obj/item/grenade/chem_grenade/pyro)
	///The turf the grenade will land on, and that sounds will play from
	var/turf/grenade_turf

/obj/effect/hallucination/fake_grenade/Destroy()
	grenade_turf = null
	return ..()

/obj/effect/hallucination/fake_grenade/Initialize(mapload, mob/living/carbon/hallucination_target, override_direction, distance = 9)
	var/obj/item/grenade/grenade_path = pick(grenade_type)
	duration = grenade_path::det_time
	. = ..()
	var/direction = override_direction ? override_direction : pick(GLOB.alldirs)
	grenade_turf = get_step(get_turf(src), direction)
	hallucination_icon = grenade_path::icon
	hallucination_icon_state = "[grenade_path::icon_state]_active"
	hallucination_layer = grenade_path::layer
	addtimer(CALLBACK(src, PROC_REF(ending_effect)), duration)
	switch(direction)
		if(NORTH)
			pixel_y = 32 * distance
		if(NORTHEAST)
			pixel_x = 32 * distance
			pixel_y = 32 * distance
		if(EAST)
			pixel_x = 32 * distance
		if(SOUTHEAST)
			pixel_x = 32 * distance
			pixel_y = -32 * distance
		if(SOUTH)
			pixel_y = -32 * distance
		if(SOUTHWEST)
			pixel_x = -32 * distance
			pixel_y = -32 * distance
		if(WEST)
			pixel_x = -32 * distance
		if(NORTHWEST)
			pixel_x = -32 * distance
			pixel_y = 32 * distance
	var/image/grenade = image(hallucination_icon, grenade_turf, hallucination_icon_state, pixel_x = pixel_x, pixel_y = pixel_y)
	target.playsound_local(grenade_turf, 'sound/weapons/armbomb.ogg', 75, TRUE)
	animate(grenade, 9, pixel_x = 0, pixel_y = 0, flags = ANIMATION_PARALLEL)
	animate(transform = matrix(120, MATRIX_ROTATE), time = 3, flags = ANIMATION_PARALLEL)
	animate(transform = matrix(240, MATRIX_ROTATE), time = 3)
	animate(transform = matrix(360, MATRIX_ROTATE), time = 3)
	add_icon(grenade)

///Additional effects that occur after the grenade hallucination disappears to mimic the grenade detonating
/obj/effect/hallucination/fake_grenade/proc/ending_effect(distance)
	distance = get_dist(src, target)
	return distance <= 4

/**
  * # Hallucination - Fake Grenade Flashbang
  *
  * A random grenade is thrown near the target from offscreen.
  * The target will get flashbanged on 'detonation' if too close.
  */
/obj/effect/hallucination/fake_grenade/flashbang
	grenade_type = list(/obj/item/grenade/flashbang)

/obj/effect/hallucination/fake_grenade/flashbang/ending_effect(distance)
	. = ..()
	if(!.)
		return
	target.playsound_local(grenade_turf, 'sound/effects/bang.ogg', 60, TRUE)
	target.show_message("<span class='warning'>BANG</span>", 2)
	var/weaken_time = 6 SECONDS
	if(target.flash_eyes(visual = TRUE))
		weaken_time /= 2
	target.Weaken(weaken_time)

	if(target.check_ear_prot())
		return
	switch(rand(1, 5))
		if(1, 2)
			to_chat(target, "<span class='warning'>Your ears start to ring!</span>")
		if(3, 4)
			to_chat(target, "<span class='warning'>Your ears start to ring badly!</span>")
		if(5)
			to_chat(target, "<span class='warning'>You can't hear anything!</span>")
			target.Deaf(2 SECONDS)

/**
  * # Hallucination - Fake Grenade Spawner
  *
  * A random grenade is thrown near the target from offscreen.
  * A space carp will spawn on the grenade upon 'detonation'.
  */
/obj/effect/hallucination/fake_grenade/spawner
	grenade_type = list(/obj/item/grenade/spawnergrenade)

/obj/effect/hallucination/fake_grenade/spawner/ending_effect(distance)
	target.playsound_local(grenade_turf, 'sound/effects/phasein.ogg', 60, TRUE)
	target.flash_eyes(visual = TRUE)
	new /obj/effect/hallucination/chaser/attacker/space_carp(grenade_turf, target)

/**
  * # Hallucination - Space Carp
  */
/obj/effect/hallucination/chaser/attacker/space_carp
	hallucination_icon = 'icons/mob/carp.dmi'
	hallucination_icon_state = "base"
	duration = 30 SECONDS

/obj/effect/hallucination/chaser/attacker/space_carp/Initialize(mapload, mob/living/carbon/hallucination_target)
	. = ..()
	name = "space carp"

/obj/effect/hallucination/chaser/attacker/space_carp/attack_effects()
	do_attack_animation(target, ATTACK_EFFECT_BITE)
	target.playsound_local(get_turf(src), 'sound/weapons/bite.ogg', 50, TRUE)
	to_chat(target, "<span class='userdanger'>[name] bites you!</span>")

/obj/effect/hallucination/chaser/attacker/space_carp/on_knockdown()
	target.visible_message("<span class='warning'>[target] recoils as if hit by something, before suddenly collapsing!</span>", "<span class='userdanger'>[name] bites you!</span>")
