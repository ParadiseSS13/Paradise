/mob/living/carbon/brain/death(gibbed)
	if(stat == DEAD)	return
	if(!gibbed && container && istype(container, /obj/item/device/mmi))//If not gibbed but in a container.
		for(var/mob/O in viewers(container, null))
			O.show_message(text("\red <B>[]'s MMI flatlines!</B>", src), 1, "\red You hear something flatline.", 2)
		container.icon_state = "mmi_dead"
	stat = DEAD

	if(blind)	blind.layer = 0
	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO

	timeofdeath = worldtime2text()
	if(mind)	mind.store_memory("Time of death: [timeofdeath]", 0)	//mind. ?

	return ..(gibbed)

/mob/living/carbon/brain/gib()
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

//	flick("gibbed-m", animation)
	gibs(loc, viruses, dna)

	dead_mob_list -= src
	if(container && istype(container, /obj/item/device/mmi))
		qdel(container)//Gets rid of the MMI if there is one
	if(loc)
		if(istype(loc,/obj/item/organ/brain))
			qdel(loc)//Gets rid of the brain item
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)