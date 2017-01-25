/mob/living/carbon/alien/gib()
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
	xgibs(loc, viruses)
	dead_mob_list -= src

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/carbon/alien/dust()
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

	flick("dust-a", animation)
	new /obj/effect/decal/remains/xeno(loc)
	dead_mob_list -= src

	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/living/carbon/alien/death(gibbed)
	if(stat == DEAD)	return
	if(healths)			healths.icon_state = "health6"
	stat = DEAD

	if(!gibbed)
		playsound(loc, 'sound/voice/hiss6.ogg', 80, 1, 1)
		for(var/mob/O in viewers(src, null))
			O.show_message("<B>[src]</B> lets out a waning guttural screech, green blood bubbling from its maw...", 1)
		update_canmove()
		update_icons()

	timeofdeath = world.time
	if(mind) 	mind.store_memory("Time of death: [worldtime2text(timeofdeath)]", 0)

	return ..(gibbed)
