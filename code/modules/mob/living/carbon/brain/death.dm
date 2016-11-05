/mob/living/carbon/brain/death(gibbed)
	. = ..()
	if(!.)	return
	if(!gibbed && container && istype(container, /obj/item/device/mmi))//If not gibbed but in a container.
		visible_message("<span class='danger'>[src]'s MMI flatlines!</span>", "<span class='warning'>You hear something flatline.</span>")
		container.icon_state = "mmi_dead"

	sight |= SEE_TURFS|SEE_MOBS|SEE_OBJS
	see_in_dark = 8
	see_invisible = SEE_INVISIBLE_LEVEL_TWO


/mob/living/carbon/brain/gib()
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

//	flick("gibbed-m", animation)
	gibs(loc, viruses, dna)

	dead_mob_list -= src
	if(container && istype(container, /obj/item/device/mmi))
		qdel(container)//Gets rid of the MMI if there is one
	if(loc)
		if(istype(loc,/obj/item/organ/internal/brain))
			qdel(loc)//Gets rid of the brain item
	spawn(15)
		if(animation)	qdel(animation)
		if(src)			qdel(src)
