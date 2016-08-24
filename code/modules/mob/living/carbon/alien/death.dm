/mob/living/carbon/alien/death(gibbed)
	. = ..()
	if(!.)	return

	if(!gibbed)
		if(death_sound)
			playsound(loc, death_sound, 80, 1, 1)
		visible_message("<span class='name'>[src]</span> [death_message]")
		update_icons()

/mob/living/carbon/alien/gib()
	if(!death(1) && stat != DEAD)
		return
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
	xgibs(loc, viruses)
	dead_mob_list -= src

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/carbon/alien/dust()
	if(!death(1) && stat != DEAD)
		return
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

	flick("dust-a", animation)
	new /obj/effect/decal/remains/xeno(loc)
	dead_mob_list -= src

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)
