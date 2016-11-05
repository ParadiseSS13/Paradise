// Returns 1 if the mob successfully transitioned from alive to dead
/mob/living/death(gibbed)
	if(stat == DEAD)	return 0
	if(status_flags & GODMODE)	return 0
	if(deathgasp_on_death)
		emote("deathgasp")
	stat = DEAD
	add_logs(src, null, "died at [atom_loc_line(get_turf(src))]")

	timeofdeath = world.time
	if(mind) 	mind.store_memory("Time of death: [worldtime2text(timeofdeath)]", 0)

	SetDizzy(0)
	SetJitter(0)

	if(!gibbed)
		update_canmove()

	if(ticker && ticker.mode)
		ticker.mode.check_win()

	clear_fullscreens()
	update_health_hud()
	update_action_buttons_icon()

	timeofdeath = world.time

	living_mob_list -= src
	dead_mob_list += src
	if(client)
		respawnable_list += src
	return 1


/mob/living/gib()
	if(!death(1) && stat != DEAD)
		// I refuse to die!
		return
	var/atom/movable/overlay/animation = null
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101

	playsound(src.loc, 'sound/goonstation/effects/gib.ogg', 50, 1)

	animation = new(loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = src

//	flick("gibbed-m", animation)
	gibs(loc, viruses, dna)
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)


/mob/living/dust()
	if(!death(1) && stat != DEAD)
		// I refuse to die!
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

//	flick("dust-m", animation)
	new /obj/effect/decal/cleanable/ash(loc)
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)


/mob/living/melt()
	if(!death(1) && stat != DEAD)
		// I refuse to die!
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

//	flick("liquify", animation)
//	new /obj/effect/decal/cleanable/ash(loc)
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)
