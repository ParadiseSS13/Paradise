/mob/living/carbon/alien/gib()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	death(1)
	var/atom/movable/overlay/animation = null
	notransform = TRUE
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	playsound(loc, 'sound/goonstation/effects/gib.ogg', 50, TRUE)

	for(var/mob/M in stomach_contents) //Release eaten mobs when Beno is gibbed
		LAZYREMOVE(stomach_contents, M)
		M.forceMove(drop_location())
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			H.KnockDown(5 SECONDS)

	for(var/obj/item/organ/internal/I in internal_organs)
		if(isturf(loc))
			var/atom/movable/thing = I.remove(src)
			if(thing)
				thing.forceMove(get_turf(src))
				if(!QDELETED(thing)) // This is in case moving to the turf deletes the atom.
					thing.throw_at(get_edge_target_turf(src, pick(GLOB.alldirs)), rand(1, 3), 5)

	flick("gibbed-a", animation)
	xgibs(loc)
	GLOB.dead_mob_list -= src

	QDEL_IN(animation, 15)
	QDEL_IN(src, 15)
	return TRUE

/mob/living/carbon/alien/dust()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	notransform = TRUE
	icon = null
	invisibility = 101
	dust_animation()
	new /obj/effect/decal/remains/xeno(loc)
	GLOB.dead_mob_list -= src
	QDEL_IN(src, 15)
	return TRUE

/mob/living/carbon/alien/dust_animation()
	var/atom/movable/overlay/animation = null
	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src
	flick("dust-a", animation)
	new /obj/effect/decal/remains/xeno(loc)
	GLOB.dead_mob_list -= src
	QDEL_IN(animation, 15)

/mob/living/carbon/alien/death(gibbed)
	move_resist = null
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	if(healths)
		healths.icon_state = "health6"

	if(!gibbed)
		if(death_sound)
			playsound(loc, death_sound, 80, TRUE, 1)
		visible_message("<B>[src]</B> [death_message]")
		update_icons()

	deathrattle()
