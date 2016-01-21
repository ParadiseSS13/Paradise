/datum/dna/gene/monkey
	name="Monkey"

/datum/dna/gene/monkey/New()
	block=MONKEYBLOCK

/datum/dna/gene/monkey/can_activate(var/mob/M,var/flags)
	return ishuman(M)

/datum/dna/gene/monkey/activate(var/mob/living/carbon/human/H, var/connected, var/flags)
	if(!istype(H,/mob/living/carbon/human))
		return
	if(issmall(H)) 
		return
	for(var/obj/item/W in H)
		if(istype(W,/obj/item/organ))
			continue
		if(istype(W,/obj/item/weapon/implant))
			continue
		H.unEquip(W)
		
	H.regenerate_icons()
	H.canmove = 0
	H.stunned = 1
	H.icon = null
	H.invisibility = 101
	
	var/atom/movable/overlay/animation = new /atom/movable/overlay(H.loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = H
	flick("h2monkey", animation)
	sleep(22)
	qdel(animation)
	
	H.stunned = 0
	H.update_canmove()
	H.invisibility = initial(H.invisibility)

	if(!H.species.primitive_form) //If the creature in question has no primitive set, this is going to be messy.
		H.gib()
		return

	H.set_species(H.species.primitive_form)

	if(H.hud_used)
		H.hud_used.instantiate()

	H << "<B>You are now a [H.species.name].</B>"

	return H

/datum/dna/gene/monkey/deactivate(var/mob/living/carbon/human/H, var/connected, var/flags)
	if(!istype(H,/mob/living/carbon/human))
		return
	for(var/obj/item/W in H)
		if (W == H.w_uniform) // will be torn
			continue
		if(istype(W,/obj/item/organ))
			continue
		if(istype(W,/obj/item/weapon/implant))
			continue
		H.unEquip(W)
	H.regenerate_icons()
	H.canmove = 0
	H.stunned = 1
	H.icon = null
	H.invisibility = 101
	
	var/atom/movable/overlay/animation = new /atom/movable/overlay(H.loc)
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = H
	flick("monkey2h", animation)
	sleep(22)
	qdel(animation)

	H.stunned = 0
	H.update_canmove()
	H.invisibility = initial(H.invisibility)

	if(!H.species.greater_form) //If the creature in question has no primitive set, this is going to be messy.
		H.gib()
		return

	H.set_species(H.species.greater_form)

	if(H.hud_used)
		H.hud_used.instantiate()

	H << "<B>You are now a [H.species.name].</B>"

	return H