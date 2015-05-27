/datum/dna/gene/monkey
	name="Monkey"

/datum/dna/gene/monkey/New()
	block=MONKEYBLOCK

/datum/dna/gene/monkey/can_activate(var/mob/M,var/flags)
	return istype(M, /mob/living/carbon/human)

/datum/dna/gene/monkey/activate(var/mob/living/carbon/human/H, var/connected, var/flags)
	if(!istype(H,/mob/living/carbon/human))
//		testing("Cannot monkey-ify [M], type is [M.type].")
		return
	for(var/obj/item/W in H)
		if (W==H.w_uniform) // will be torn
			continue
		H.unEquip(W)
	H.regenerate_icons()
	H.canmove = 0
	H.stunned = 1
	H.icon = null
	H.invisibility = 101
	for(var/t in H.organs)
		del(t)
	var/atom/movable/overlay/animation = new /atom/movable/overlay( H.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = H
	flick("h2monkey", animation)
	sleep(48)
	//animation = null

	H.stunned = 0
	H.update_canmove()
	H.invisibility = initial(H.invisibility)

	if(!H.species.primitive_form) //If the creature in question has no primitive set, this is going to be messy.
		H.gib()
		return

	for(var/obj/item/W in H)
		H.unEquip(W)
	H.set_species(H.species.primitive_form)

	if(H.hud_used)
		H.hud_used.monkey_hud()

	H << "<B>You are now [H.species.name]. </B>"
	qdel(animation)

	return H

/datum/dna/gene/monkey/deactivate(var/mob/living/carbon/human/H, var/connected, var/flags)
	if(!istype(H,/mob/living/carbon/human))
//		testing("Cannot monkey-ify [M], type is [M.type].")
		return
	for(var/obj/item/W in H)
		if (W==H.w_uniform) // will be torn
			continue
		H.unEquip(W)
	H.regenerate_icons()
	H.canmove = 0
	H.stunned = 1
	H.icon = null
	H.invisibility = 101
	for(var/t in H.organs)
		del(t)
	var/atom/movable/overlay/animation = new /atom/movable/overlay( H.loc )
	animation.icon_state = "blank"
	animation.icon = 'icons/mob/mob.dmi'
	animation.master = H
	flick("monkey2h", animation)
	sleep(48)
	//animation = null

	H.stunned = 0
	H.update_canmove()
	H.invisibility = initial(H.invisibility)

	if(!H.species.greater_form) //If the creature in question has no primitive set, this is going to be messy.
		H.gib()
		return

	if(H.hud_used)
		H.hud_used.human_hud()


	for(var/obj/item/W in H)
		H.unEquip(W)
	H.set_species(H.species.greater_form)

	H << "<B>You are now [H.species.name]. </B>"
	qdel(animation)

	return H