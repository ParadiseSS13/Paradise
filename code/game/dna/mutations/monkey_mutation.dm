/datum/mutation/monkey
	name = "Monkey"

/datum/mutation/monkey/New()
	..()
	block = GLOB.monkeyblock

/datum/mutation/monkey/can_activate(mob/M, flags)
	return ishuman(M)

/datum/mutation/monkey/activate(mob/living/carbon/human/H)
	..()
	if(!istype(H))
		return
	if(issmall(H))
		return
	for(var/obj/item/W in H)
		if(istype(W, /obj/item/implant))
			continue
		H.unEquip(W)

	H.regenerate_icons()
	ADD_TRAIT(H, TRAIT_IMMOBILIZED, TRANSFORMING_TRAIT)
	ADD_TRAIT(H, TRAIT_HANDS_BLOCKED, TRANSFORMING_TRAIT)
	H.icon = null
	H.invisibility = 101
	var/has_primitive_form = H.dna.species.primitive_form // cache this
	if(has_primitive_form)
		H.set_species(has_primitive_form, keep_missing_bodyparts = TRUE)

	new /obj/effect/temp_visual/monkeyify(H.loc)
	sleep(22)

	H.invisibility = initial(H.invisibility)

	if(!has_primitive_form) //If the pre-change mob in question has no primitive set, this is going to be messy.
		H.gib()
		return
	REMOVE_TRAITS_IN(H, TRANSFORMING_TRAIT)
	to_chat(H, "<B>You are now a [H.dna.species.name].</B>")

	return H

/datum/mutation/monkey/deactivate(mob/living/carbon/human/H)
	..()
	if(!istype(H))
		return
	if(!issmall(H))
		return
	for(var/obj/item/W in H)
		if(W == H.w_uniform) // will be torn
			continue
		if(istype(W, /obj/item/implant))
			continue
		H.unEquip(W)
	H.regenerate_icons()
	ADD_TRAIT(H, TRAIT_IMMOBILIZED, TRANSFORMING_TRAIT)
	ADD_TRAIT(H, TRAIT_HANDS_BLOCKED, TRANSFORMING_TRAIT)
	H.icon = null
	H.invisibility = 101
	var/has_greater_form = H.dna.species.greater_form //cache this
	if(has_greater_form)
		H.set_species(has_greater_form, keep_missing_bodyparts = TRUE)

	new /obj/effect/temp_visual/monkeyify/humanify(H.loc)
	sleep(22)
	REMOVE_TRAITS_IN(H, TRANSFORMING_TRAIT)
	H.invisibility = initial(H.invisibility)

	if(!has_greater_form) //If the pre-change mob in question has no primitive set, this is going to be messy.
		H.gib()
		return

	H.real_name = H.dna.real_name
	H.name = H.real_name

	to_chat(H, "<B>You are now a [H.dna.species.name].</B>")

	return H
