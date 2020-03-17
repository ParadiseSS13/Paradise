/mob/living/carbon/brain/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	if(!gibbed && container && istype(container, /obj/item/mmi))//If not gibbed but in a container.
		var/obj/item/mmi/mmi = container
		visible_message("<span class='danger'>[src]'s MMI flatlines!</span>", "<span class='warning'>You hear something flatline.</span>")
		mmi.icon_state = mmi.dead_icon

/mob/living/carbon/brain/gib()
	// can we muster a parent call here?
	if(!death(TRUE) && stat != DEAD)
		return FALSE
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101

	gibs(loc, dna)

	if(container && istype(container, /obj/item/mmi))
		qdel(container)//Gets rid of the MMI if there is one
	if(loc)
		if(istype(loc,/obj/item/organ/internal/brain))
			qdel(loc)//Gets rid of the brain item
	QDEL_IN(src, 0)
