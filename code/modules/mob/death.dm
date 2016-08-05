//This is the proc for gibbing a mob. Cannot gib ghosts.
//added different sort of gibs and animations. N
/mob/proc/gib()
	death(1)
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
	dead_mob_list -= src
	if(client)
		respawnable_list += src
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)


//This is the proc for turning a mob into ash. Mostly a copy of gib code (above).
//Originally created for wizard disintegrate. I've removed the virus code since it's irrelevant here.
//Dusting robots does not eject the MMI, so it's a bit more powerful than gib() /N
/mob/proc/dust()
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

//	flick("dust-m", animation)
	new /obj/effect/decal/cleanable/ash(loc)

	dead_mob_list -= src
	if(client)
		respawnable_list += src
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/proc/melt()
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

//	flick("liquify", animation)
//	new /obj/effect/decal/cleanable/ash(loc)

	dead_mob_list -= src
	if(client)
		respawnable_list += src
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)

/mob/proc/death(gibbed)

	//Makes it so gib/dust/melt all unbuckle their victims from anything they may be buckled to to avoid breaking beds/chairs/etc
	if(gibbed && buckled)
		buckled.unbuckle_mob()

	//Quick fix for corpses kept propped up in chairs. ~Z
	drop_r_hand()
	drop_l_hand()
	//End of fix.

	timeofdeath = world.time

	living_mob_list -= src
	dead_mob_list += src
	if(client)
		respawnable_list += src
	return ..(gibbed)
