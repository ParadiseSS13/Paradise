/datum/dna/gene/monkey
	name = "Monkey"

/datum/dna/gene/monkey/New()
	..()
	block = GLOB.monkeyblock

/datum/dna/gene/monkey/can_activate(mob/M, flags)
	return ishuman(M)

/datum/dna/gene/monkey/activate(mob/living/carbon/human/H, connected, flags)
	if(!istype(H))
		return
	if(issmall(H))
		return
	for(var/obj/item/W in H)
		if(istype(W,/obj/item/organ))
			continue
		if(istype(W,/obj/item/implant))
			continue
		H.unEquip(W)

	H.regenerate_icons()
	H.SetStunned(1)
	H.canmove = FALSE
	H.icon = null
	H.invisibility = 101
	var/has_primitive_form = H.dna.species.primitive_form // cache this
	if(has_primitive_form)
		if(ispath(has_primitive_form, /mob/living/simple_animal)) // Simple animal form
			var/mob/living/simple_animal/S = simple_transformation(H, has_primitive_form)
			return S

		H.set_species(has_primitive_form)

	new /obj/effect/temp_visual/monkeyify(H.loc)
	sleep(22)

	H.SetStunned(0)
	H.invisibility = initial(H.invisibility)

	if(!has_primitive_form) //If the pre-change mob in question has no primitive set, this is going to be messy.
		H.gib()
		return

	to_chat(H, "<B>You are now a [H.dna.species.name].</B>")

	return H

/datum/dna/gene/monkey/deactivate(mob/living/carbon/human/H, connected, flags)
	if(!istype(H))
		return
	if(!issmall(H))
		return
	for(var/obj/item/W in H)
		if(W == H.w_uniform) // will be torn
			continue
		if(istype(W,/obj/item/organ))
			continue
		if(istype(W,/obj/item/implant))
			continue
		H.unEquip(W)
	H.regenerate_icons()
	H.SetStunned(1)
	H.canmove = 0
	H.icon = null
	H.invisibility = 101
	var/has_greater_form = H.dna.species.greater_form //cache this
	if(has_greater_form)
		H.set_species(has_greater_form)

	new /obj/effect/temp_visual/monkeyify/humanify(H.loc)
	sleep(22)

	H.SetStunned(0)
	H.invisibility = initial(H.invisibility)

	if(!has_greater_form) //If the pre-change mob in question has no primitive set, this is going to be messy.
		H.gib()
		return

	H.real_name = H.dna.real_name
	H.name = H.real_name

	to_chat(H, "<B>You are now a [H.dna.species.name].</B>")

	return H

/datum/dna/gene/monkey/proc/simple_transformation(mob/living/carbon/human/user, mob/living/simple_animal/new_species)
	var/mob/living/simple_animal/S = new new_species(get_turf(user))
	user.mind.transfer_to(S)
	QDEL_NULL(user.internal_organs_slot[BRAIN])
	user.gib()
	return S
