/mob/living/carbon/alien/gib()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	death(1)
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	playsound(src.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)

	flick("gibbed-a", animation)
	xgibs(loc)
	GLOB.dead_mob_list -= src

	QDEL_IN(animation, 15)
	QDEL_IN(src, 15)
	return TRUE

/mob/living/carbon/alien/dust()
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	notransform = 1
	canmove = 0
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
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	if(healths)
		healths.icon_state = "health6"

	if(!gibbed)
		if(death_sound)
			playsound(loc, death_sound, 80, 1, 1)
		visible_message("<B>[src]</B> [death_message]")
		update_icons()
