/obj/item/organ/internal/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	origin_tech = "biotech=5"
	parent_organ = "chest"
	slot = "parasite_egg"

/obj/item/organ/internal/body_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, "<span class='warning'>You found an unknown alien organism in [owner]'s [parent_organ]!</span>")

/obj/item/organ/internal/body_egg/insert(mob/living/carbon/M, special = 0)
	..()
	ADD_TRAIT(owner, TRAIT_XENO_HOST, TRAIT_GENERIC)
	ADD_TRAIT(owner, TRAIT_XENO_IMMUNE, "xeno immune")
	START_PROCESSING(SSobj, src)
	owner.med_hud_set_status()
	INVOKE_ASYNC(src, .proc/AddInfectionImages, owner)

/obj/item/organ/internal/body_egg/remove(mob/living/carbon/M, special = 0)
	STOP_PROCESSING(SSobj, src)
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_XENO_HOST, TRAIT_GENERIC)
		REMOVE_TRAIT(owner, TRAIT_XENO_IMMUNE, "xeno immune")
		owner.med_hud_set_status()
		INVOKE_ASYNC(src, .proc/RemoveInfectionImages, owner)
	. = ..()

/obj/item/organ/internal/body_egg/process()
	if(!owner)
		return
	if(!(src in owner.internal_organs))
		remove(owner)
		return
	egg_process()

/obj/item/organ/internal/body_egg/proc/egg_process()
	return

/obj/item/organ/internal/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/internal/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/internal/body_egg/proc/RemoveInfectionImages()
	return
